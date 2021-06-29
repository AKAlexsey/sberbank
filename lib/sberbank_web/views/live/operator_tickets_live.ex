defmodule SberbankWeb.OperatorTicketsLive do
  use SberbankWeb, :live_view

  alias Sberbank.Staff

  alias Sberbank.Pipeline.{OperatorClient, OperatorDynamicSupervisor, RabbitClient}

  @refresh_interval 500

  def mount(%{"employer_id" => employer_id}, session, socket) do
    operator = Staff.get_employer!(employer_id, [:competencies])

    OperatorDynamicSupervisor.start_for_operator(operator)
    |> case do
      {:error, {:already_started, _}} ->
        # TODO move action to operator client
        RabbitClient.subscribe_operator_to_exchanges(operator)

      _ ->
        nil
    end

    competences = operator.competencies

    assigned_socket =
      socket
      |> assign(:operator, operator)
      |> assign(:competences, Enum.map(operator.competencies, &Map.from_struct/1))
      |> assign_socket_data()

    schedule_interval_rendering()

    {:ok, assigned_socket}
  end

  def handle_info(:render, socket) do
    schedule_interval_rendering()
    {:noreply, assign_socket_data(socket)}
  end

  defp schedule_interval_rendering do
    Process.send_after(self(), :render, @refresh_interval)
  end

  def handle_event(
        "leave_ticket",
        %{"ticket-id" => ticket_id},
        %{assigns: %{operator: operator}} = socket
      ) do
    # TODO legacy rewrite to broadcast
    OperatorClient.leave_ticket(operator, ticket_id)
    {:noreply, assign_socket_data(socket)}
  end

  def handle_event(
        "deactivate_ticket",
        %{"ticket-id" => ticket_id},
        %{assigns: %{operator: operator}} = socket
      ) do
    # TODO legacy rewrite to broadcast
    OperatorClient.deactivate_ticket(operator, ticket_id)
    {:noreply, assign_socket_data(socket)}
  end

  defp assign_socket_data(%{assigns: %{operator: operator}} = socket) do
    tickets = OperatorClient.get_active_tickets(operator)
    current_tickets = Enum.map(tickets, fn {ticket, _} -> ticket end)

    socket
    |> assign(:current_tickets, current_tickets)
  end
end
