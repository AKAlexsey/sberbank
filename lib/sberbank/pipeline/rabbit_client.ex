defmodule Sberbank.Pipeline.RabbitClient do
  @moduledoc """
  Represent client to interact with toolkit
  """

  require Logger

  use GenServer

  alias Sberbank.Customers
  alias Sberbank.Customers.Ticket
  alias Sberbank.Staff.Employer
  alias Sberbank.Pipeline.Toolkit

  def initial_push_ticket(ticket_id) when is_integer(ticket_id) or is_binary(ticket_id) do
    ticket_id
    |> Customers.get_ticket()
    |> initial_push_ticket()
  end

  def initial_push_ticket(%Ticket{} = ticket) do
    GenServer.cast(__MODULE__, {:initial_push_customer_ticket, ticket})
  end

  def initial_push_ticket(unexpected_argument) do
    {:error,
     "Unexpected argument. Expected #{inspect(Ticket)}, integer or binary, given: #{
       unexpected_argument
     }"}
  end

  def repeat_push_ticket(ticket_id) when is_integer(ticket_id) or is_binary(ticket_id) do
    ticket_id
    |> Customers.get_ticket()
    |> repeat_push_ticket()
  end

  def repeat_push_ticket(%Ticket{} = ticket) do
    GenServer.cast(__MODULE__, {:repeat_push_customer_ticket, ticket})
  end

  def repeat_push_ticket(unexpected_argument) do
    {:error,
     "Unexpected argument. Expected #{inspect(Ticket)}, integer or binary, given: #{
       unexpected_argument
     }"}
  end

  def declare_exchange(exchange_name) do
    GenServer.cast(__MODULE__, {:declare_exchange, exchange_name})
  end

  def subscribe_operator_to_exchanges(%Employer{} = operator) do
    GenServer.cast(__MODULE__, {:subscribe_operator_to_exchanges, operator})
  end

  def subscribe_to_operator_queue(%Employer{} = operator, process_pid) do
    GenServer.cast(__MODULE__, {:subscribe_to_operator_queue, operator, process_pid})
  end

  def delete_competence_exchange(competence) do
    GenServer.cast(__MODULE__, {:delete_competence_exchange, competence})
  end

  def acknowledge_message(delivery_tag) when is_integer(delivery_tag) do
    GenServer.cast(__MODULE__, {:acknowledge_message, delivery_tag})
  end

  def fetch_ticket_for_operator(operator) do
    GenServer.call(__MODULE__, {:fetch_ticket_for_operator, operator})
  end

  # Users API
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{connection: connection, channel: channel}} = Toolkit.open_connection()
    {:ok, %{connection: connection, channel: channel}, {:continue, :after_start_functions}}
  end

  def handle_continue(:after_start_functions, state) do
    Toolkit.declare_exchanges()
    {:noreply, state}
  end

  def handle_cast(
        {:initial_push_customer_ticket, %Ticket{id: id, topic: topic} = ticket},
        %{channel: channel} = state
      ) do
    result = Toolkit.initial_push_customer_ticket(channel, ticket)

    Logger.info(fn ->
      "#{__MODULE__} Push ticket #{id} #{topic}. Result: #{inspect(result, pretty: true)}"
    end)

    {:noreply, state}
  end

  def handle_cast(
        {:declare_exchange, exchange_name},
        %{channel: channel} = state
      ) do
    result = Toolkit.declare_exchange(channel, exchange_name)

    Logger.info(fn ->
      "#{__MODULE__} Declaring exchange #{exchange_name} result: #{inspect(result, pretty: true)}"
    end)

    {:noreply, state}
  end

  def handle_cast(
        {:repeat_push_customer_ticket, %Ticket{id: id, topic: topic} = ticket},
        %{channel: channel} = state
      ) do
    result = Toolkit.repeat_push_customer_ticket(channel, ticket)

    Logger.info(fn ->
      "#{__MODULE__} Push ticket #{id} #{topic}. Result: #{inspect(result, pretty: true)}"
    end)

    {:noreply, state}
  end

  def handle_cast(
        {:subscribe_operator_to_exchanges, %Employer{id: id, name: name} = operator},
        %{channel: channel} = state
      ) do
    result = Toolkit.subscribe_operator_to_exchanges(channel, operator)

    Logger.info(fn ->
      "#{__MODULE__} Subscribed operator #{id} #{name}. Result: #{inspect(result, pretty: true)}"
    end)

    {:noreply, state}
  end

  def handle_cast(
        {:subscribe_to_operator_queue, %Employer{id: id, name: name} = operator, process_pid},
        %{channel: channel} = state
      ) do
    result = Toolkit.subscribe_to_operator_queue(channel, operator, process_pid)

    Logger.info(fn ->
      "#{__MODULE__} Subscription operator #{id} #{name} to queue result: #{
        inspect(result, pretty: true)
      }"
    end)

    {:noreply, state}
  end

  def handle_cast(
        {:delete_competence_exchange, %{id: id, name: name} = competence},
        %{channel: channel} = state
      ) do
    result = Toolkit.delete_exchange(channel, competence)

    Logger.info(fn ->
      "#{__MODULE__} Termination exchange for #{id} #{name}. Result: #{
        inspect(result, pretty: true)
      }"
    end)

    {:noreply, state}
  end

  def handle_cast(
        {:acknowledge_message, delivery_tag},
        %{channel: channel} = state
      ) do
    result = Toolkit.acknowledge_message(channel, delivery_tag)

    Logger.info(fn ->
      "#{__MODULE__} Acknowledgement result: #{inspect(result, pretty: true)}"
    end)

    {:noreply, state}
  end

  def handle_call(
        {:fetch_ticket_for_operator, %Employer{id: id, name: name} = operator},
        _from,
        %{channel: channel} = state
      ) do
    channel
    |> Toolkit.fetch_ticket_for_operator(operator)
    |> case do
      {:ok, %Ticket{id: ticket_id, topic: topic} = ticket} ->
        Logger.info(fn ->
          "#{__MODULE__} Fetched Ticket with id: #{ticket_id} and topic #{topic} for Operator: #{
            id
          } #{name}."
        end)

        {:reply, {:ok, ticket}, state}

      {:ok, :no_ticket} ->
        {:reply, {:ok, :no_ticket}, state}

      {:error, reason} ->
        Logger.error(fn ->
          "#{__MODULE__} Error fetching data for for Operator: #{id} #{name}: #{reason}"
        end)

        {:reply, {:error, reason}, state}
    end
  end

  def handle_info({:basic_deliver, _, _}, state) do
    {:noreply, state}
  end

  def handle_info({:basic_consume_ok, _}, state) do
    {:noreply, state}
  end
end
