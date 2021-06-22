defmodule SberbankWeb.CustomerTicketsView do
  use SberbankWeb, :view

  def make_competence_name(%{name: name, letter: letter}) do
    "#{name} <#{letter}>"
  end

  def make_operators_list(%{ticket_operators: ticket_operators}) do
    operators_data =
      Enum.sort_by(ticket_operators, fn %{operator: %{id: operator_id}, active: active} ->
        if(active, do: 1000, else: operator_id)
      end)

    content_tag(
      :ul,
      Enum.map(operators_data, fn %{operator: %{id: id, email: email}, active: active} ->
        content_tag(:li, [
          content_tag(:span, "Operator #{id} #{email}  "),
          content_tag(:span, "#{if(active, do: "active", else: "finished")}",
            class: if(active, do: "text-success", else: "text-danger")
          )
        ])
      end)
    )
  end
end
