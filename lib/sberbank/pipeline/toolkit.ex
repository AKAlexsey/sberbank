defmodule Sberbank.Pipeline.Toolkit do
  @moduledoc """
  Represent all necessary functions to publish and subscribe to channels
  """

  alias Sberbank.Customers
  alias Sberbank.Customers.Ticket
  alias Sberbank.Pipeline.RabbitClient
  alias Sberbank.Staff
  alias Sberbank.Staff.{Competence, Employer}

  @spec subscribe_operator_to_exchanges(map, Employer.t()) :: :ok | {:error, binary}
  def subscribe_operator_to_exchanges(channel, %Employer{id: id}) do
    %{competencies: operator_competencies} = employer = Staff.get_employer!(id, [:competencies])

    queue_name = get_operator_queue_name(employer)

    {:ok, _queue_data} = AMQP.Queue.declare(channel, queue_name, durable: false)

    Staff.list_competencies()
    |> perform_action_on_queue(fn exchange_name, routing_key ->
      AMQP.Queue.unbind(channel, queue_name, exchange_name, routing_key: routing_key)
    end)

    operator_competencies
    |> perform_action_on_queue(fn exchange_name, routing_key ->
      AMQP.Queue.bind(channel, queue_name, exchange_name, routing_key: routing_key)
    end)
  end

  defp perform_action_on_queue(competencies, action_function) do
    competencies
    |> Enum.each(fn competence ->
      all_exchanges()
      |> Enum.map(fn exchange_name ->
        routing_key = get_routing_key(competence)

        action_function.(exchange_name, routing_key)
      end)
    end)
  end

  defp get_operator_queue_name(%Employer{id: id, name: name}) do
    String.downcase("operator_#{name}_#{id}_queue")
  end

  defp get_routing_key(%Competence{letter: letter}) do
    String.downcase("competence.#{letter}")
  end

  # Rabbit interaction API
  @spec open_connection :: {:ok, %{channel: AMQP.Channel.t(), connection: AMQP.Connection.t()}}
  def open_connection do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)

    {:ok, %{connection: connection, channel: channel}}
  end

  @spec declare_exchange(map, binary, list) :: {:ok, map} | {:error, atom}
  def declare_exchange(channel, exchange_name, opts \\ []) do
    default_opts = [durable: true]

    AMQP.Exchange.topic(channel, exchange_name, Keyword.merge(default_opts, opts))
  end

  @spec unbind_operator_topic(map, Employer.t(), Competence.t()) :: {:ok, map} | {:error, atom}
  def unbind_operator_topic(channel, %Employer{} = operator, %Competence{} = competence) do
    queue_name = get_operator_queue_name(operator)

    [competence]
    |> perform_action_on_queue(fn exchange_name, routing_key ->
      AMQP.Queue.unbind(channel, queue_name, exchange_name, routing_key: routing_key)
    end)
  end

  @initial_tickets_exchange "initial_tickets_exchange"
  @repeating_tickets_exchange "repeating_tickets_exchange"

  def all_exchanges do
    [
      @initial_tickets_exchange,
      @repeating_tickets_exchange
    ]
  end

  def declare_exchanges do
    all_exchanges()
    |> Enum.each(&RabbitClient.declare_exchange/1)
  end

  @spec initial_push_customer_ticket(map, Ticket.t()) :: :ok | {:error, binary}
  def initial_push_customer_ticket(channel, %Ticket{} = ticket) do
    %{routing_key: routing_key, payload: payload} = put_ticket_params(ticket)

    AMQP.Basic.publish(channel, @initial_tickets_exchange, routing_key, payload)
  end

  @spec repeat_push_customer_ticket(map, Ticket.t()) :: :ok | {:error, binary}
  def repeat_push_customer_ticket(channel, %Ticket{} = ticket) do
    %{routing_key: routing_key, payload: payload} = put_ticket_params(ticket)

    AMQP.Basic.publish(channel, @repeating_tickets_exchange, routing_key, payload)
  end

  @spec put_ticket_params(Ticket.t()) :: %{routing_key: binary, payload: binary}
  defp put_ticket_params(%Ticket{id: id}) do
    ticket = Customers.get_ticket!(id, [:competence])
    %{competence: competence} = ticket
    routing_key = get_routing_key(competence)
    payload = Jason.encode!(%{id: id})
    %{routing_key: routing_key, payload: payload}
  end

  @spec subscribe_to_operator_queue(map, Competence.t(), pid()) ::
          {:ok, map} | {:ok, :no_ticket} | {:error, binary}
  def subscribe_to_operator_queue(channel, %Employer{} = operator, process_pid) do
    queue_name = get_operator_queue_name(operator)
    # play with acknowledgement
    AMQP.Basic.consume(channel, queue_name, process_pid)
  end

  @spec acknowledge_message(map, integer, list) :: :ok | {:error, reason :: :blocked | :closing}
  def acknowledge_message(channel, delivery_tag, opts \\ []) do
    AMQP.Basic.ack(channel, delivery_tag, opts)
  end

  @spec fetch_ticket_for_operator(map, Competence.t()) ::
          {:ok, map} | {:ok, :no_ticket} | {:error, binary}
  def fetch_ticket_for_operator(channel, %Employer{} = operator) do
    queue_name = get_operator_queue_name(operator)

    with {:basic_deliver, json_ticket_data} <- AMQP.Basic.consume(channel, queue_name),
         {:ok, %{"id" => ticket_id}} <- Jason.decode(json_ticket_data),
         {:ok, ticket} <- Customers.get_ticket(ticket_id) do
      {:ok, ticket}
    else
      {:error, %Jason.DecodeError{} = error} ->
        {:error, Jason.DecodeError.message(error)}

      {:basic_consume_ok, _} ->
        {:ok, :no_ticket}

      unexpected_error ->
        {:error, inspect(unexpected_error, pretty: true)}
    end
  end
end
