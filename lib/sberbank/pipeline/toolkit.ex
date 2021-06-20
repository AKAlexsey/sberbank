defmodule Sberbank.Pipeline.Toolkit do
  @moduledoc """
  Represent all necessary functions to publish and subscribe to channels
  """

  alias Sberbank.Customers
  alias Sberbank.Customers.Ticket
  alias Sberbank.Staff
  alias Sberbank.Staff.{Competence, Employer}

  # Users API
  @spec put_customer_ticket(map, Ticket.t) :: :ok | {:error, binary}
  def put_customer_ticket(channel, %Ticket{id: id, topic: topic}) do
    ticket = Customers.get_ticket!(id, [:competence, :customer])
    %{competence: competence} = ticket
    routing_key = get_routing_key(competence)
    exchange_name = make_exchange_name(competence)
    payload = Jason.encode!(%{id: id, topic: topic})

    AMQP.Basic.publish(channel, exchange_name, routing_key, payload)
  end

  @spec subscribe_operator_to_exchanges(map, Employer.t) :: :ok | {:error, binary}
  def subscribe_operator_to_exchanges(channel, %Employer{id: id} = employer) do
    %{competencies: competencies} = employer = Staff.get_employer!(id, [:competencies])

    queue_name = get_operator_queue_name(employer)

    {:ok, queue_data} = AMQP.Queue.declare(channel, queue_name, durable: false)
    %{queue: operator_queue} = queue_data

    competencies
    |> Enum.map(fn %{} = competence ->
      exchange_name = make_exchange_name(competence)
      routing_key = get_routing_key(competence)

      AMQP.Queue.bind(channel, queue_name, exchange_name, routing_key: routing_key)
    end)
    |> (fn res ->
        IO.puts("!!! subscribe operator res: #{inspect(res, pretty: true)}\n!!! queue_data #{inspect(queue_data, pretty: true)}")
        end).()
  end

  defp get_operator_queue_name(%Employer{id: id, name: name}) do
    String.downcase("operator_#{name}_#{id}_queue")
  end

  defp get_routing_key(%Competence{letter: letter}) do
    String.downcase("competence.#{letter}")
  end

  # Rabbit interaction API
  @spec open_connection :: {:ok, %{channel: AMQP.Channel.t, connection: AMQP.Connection.t}}
  def open_connection do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)

    {:ok, %{connection: connection, channel: channel}}
  end

  @spec declare_exchange(map, Competence.t, list) :: {:ok, map} | {:error, atom}
  def declare_exchange(rabbit_channel, %Competence{} = competence, opts \\ []) do
    exchange_name = make_exchange_name(competence)

    default_opts = [durable: true]

    AMQP.Exchange.topic(rabbit_channel, exchange_name, Keyword.merge(default_opts, opts))
  end

  defp make_exchange_name(%Competence{letter: letter, name: name}) do
    String.downcase("exchange_#{name}_letter_#{letter}")
  end
end