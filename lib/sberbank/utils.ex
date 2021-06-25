defmodule Sberbank.Utils do
  @moduledoc """
  Contains functions that could be used in several parts of the project
  """

  @spec traverse_errors(Ecto.Changeset.t()) :: map()
  def traverse_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "#{key}", to_string(value))
      end)
    end)
  end

  def safe_to_integer(value) when is_integer(value), do: value

  def safe_to_integer(value) when is_binary(value) do
    {int, _} = Integer.parse(value)
    int
  end

  def safe_to_integer(value), do: value
end
