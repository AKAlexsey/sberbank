defmodule SberbankWeb.CustomerTicketsView do
  use SberbankWeb, :view

  def make_competence_name(%{name: name, letter: letter}) do
    "#{name} <#{letter}>"
  end

  def ticket_active_label(%{active: active}) do
    if active do
      content_tag(:span, "active", class: "text-success")
    else
      content_tag(:span, "not_active", class: "text-danger")
    end
  end

  def make_operators_list(%{ticket_operators: ticket_operators}) do
    operators_data =
      Enum.sort_by(ticket_operators, fn %{id: ticket_operator_id, active: active} ->
        if(active, do: true, else: ticket_operator_id)
      end)

    content_tag(
      :ul,
      Enum.map(operators_data, fn %{employer: %{id: id, name: name}, active: active} ->
        content_tag(:li, [
          content_tag(:span, "Operator #{id} #{name}  "),
          if active do
            content_tag(:span, "active", class: "text-success")
          else
            content_tag(:span, "finished", class: "text-danger")
          end
        ])
      end)
    )
  end
end
