defmodule SberbankWeb.CommonView do
  def form_is_new?(form) do
    is_nil(form.data.id)
  end

  @doc """
  Fetch error from given form errors fields " is-invalid " if there are some errors.
  Counts only errors from form to prevent errors for new entities.
  """
  @spec form_input_error_class(map, atom) :: binary
  def form_input_error_class(form, field) do
    form
    |> get_field_changeset_errors(field)
    |> Enum.any?()
    |> if(do: " is-invalid ", else: "")
  end

  defp get_field_changeset_errors(form, field) do
    Keyword.get_values(form.errors, field)
  end
end
