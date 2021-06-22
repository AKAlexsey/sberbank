defmodule Sberbank.Pipeline.RabbitClient do
  @moduledoc """
  Represent client to interact with toolkit
  """

  require Logger

  use GenServer

  alias Sberbank.Customers.Ticket
  alias Sberbank.Staff.Employer
  alias Sberbank.Pipeline.Toolkit

  def push_ticket(%Ticket{} = ticket) do
    GenServer.cast(__MODULE__, {:push_ticket, ticket})
  end

  def subscribe_operator(%Employer{} = operator) do
    GenServer.cast(__MODULE__, {:susbscribe_operator, operator})
  end

  def declare_competence_exchanges(competence) do
    GenServer.cast(__MODULE__, {:declare_competence_exchanges, competence})
  end

  def delete_competence_exchange(competence) do
    GenServer.cast(__MODULE__, {:delete_competence_exchange, competence})
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
    Toolkit.declare_competence_exchanges()
    {:noreply, state}
  end

  def handle_cast(
        {:push_ticket, %Ticket{id: id, topic: topic} = ticket},
        %{channel: channel} = state
      ) do
    result = Toolkit.put_customer_ticket(channel, ticket)

    Logger.info(fn ->
      "#{__MODULE__} Push ticket #{id} #{topic}. Result: #{inspect(result, pretty: true)}"
    end)

    {:noreply, state}
  end

  def handle_cast(
        {:susbscribe_operator, %Employer{id: id, name: name} = operator},
        %{channel: channel} = state
      ) do
    result = Toolkit.subscribe_operator_to_exchanges(channel, operator)

    Logger.info(fn ->
      "#{__MODULE__} Subscribed operator #{id} #{name}. Result: #{inspect(result, pretty: true)}"
    end)

    {:noreply, state}
  end

  def handle_cast(
        {:declare_competence_exchanges, %{id: id, name: name} = competence},
        %{channel: channel} = state
      ) do
    result = Toolkit.declare_exchange(channel, competence)

    Logger.info(fn ->
      "#{__MODULE__} Started exchange for #{id} #{name}. Result: #{inspect(result, pretty: true)}"
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
end
