defmodule Sberbank.Pipeline.OperatorDynamicSupervisor do
  @moduledoc """
  Contains functions to start GenServers for Operator
  """

  require Logger

  alias Sberbank.Pipeline.OperatorClient
  alias Sberbank.Staff.Employer

  def start_for_operator(%Employer{id: id, name: name} = operator) do
    res =
      DynamicSupervisor.start_child(
        __MODULE__,
        OperatorClient.child_spec(%{operator: operator})
      )

    Logger.info(fn ->
      "#{__MODULE__} Starting GenServer for #{id} #{name} operator: #{inspect(res, pretty: true)}"
    end)

    res
  end
end
