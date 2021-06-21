defmodule Sberbank.Pipeline.OperatorClient do
  @moduledoc """
  Represent behaviour of Operator client. Should be responsible for the connection
  of one operator
  """

  use GenServer

  alias Sberbank.Customers.Ticket
  alias Sberbank.Staff
  alias Sberbank.Staff.Employer
  alias Sberbank.Pipeline.{RabbitClient, Toolkit}

  def push_ticket(%Ticket{} = ticket) do
    GenServer.cast(__MODULE__, {:push_ticket, ticket})
  end

  # Users API
  def start_link(%{operator: %Employer{} = operator} = params) do
    server_name = make_server_name(operator)
    GenServer.start_link(__MODULE__, params, name: server_name)
  end

  defp make_server_name(%Employer{id: id})   do
    "#{__MODULE__}_#{id}"
    |> String.to_atom()
  end

  def init(%{operator: operator}) do
    RabbitClient.subscribe_operator(operator)
    {:ok, %{operator: operator}}
  end
end