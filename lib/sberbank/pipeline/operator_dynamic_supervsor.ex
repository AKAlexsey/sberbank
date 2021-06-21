defmodule Sberbank.Pipeline.OperatorDynamicSupervisor do
  @moduledoc """
  Contains functions to start GenServers for Operator
  """

  alias Sberbank.Pipeline.OperatorClient
  alias Sberbank.Staff.Employer

  def start_for_operator(%Employer{} = operator) do
    DynamicSupervisor.start_child(KV.BucketSupervisor, __MODULE__)
  end
end