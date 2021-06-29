defmodule SberbankWeb.OperatorTicketsLive do
  use SberbankWeb, :live_view

  alias Sberbank.{Eventbus, Staff}
  alias Sberbank.Pipeline.{OperatorClient, OperatorDynamicSupervisor, RabbitClient}

  @refresh_interval 500

  def mount(%{"employer_id" => employer_id}, session, socket) do
    operator = Staff.get_employer!(employer_id)

    Eventbus.subscribe_exchanges()
    Eventbus.subscribe_operator(operator)

    OperatorDynamicSupervisor.start_for_operator(operator)
    |> case do
      {:error, {:already_started, _}} ->
        # TODO move action to operator client
        RabbitClient.subscribe_operator_to_exchanges(operator)

      _ ->
        nil
    end

    assigned_socket =
      socket
      |> assign(:operator, operator)
      |> assign_socket_data()

    {:ok, assigned_socket}
  end

  def handle_info({:competence_updated, _old_competence, _new_competence}, socket) do
    {:noreply, assign_socket_data(socket)}
  end

  def handle_info({:competence_deleted, _competence}, socket) do
    {:noreply, assign_socket_data(socket)}
  end

  def handle_info({:operator_updated, _updated_operator_id}, socket) do
    {:noreply, assign_socket_data(socket)}
  end

  def handle_info(:render, %{} = socket) do
    {:noreply, assign_socket_data(socket)}
  end

  defp render_after(time_interval \\ @refresh_interval) do
    Process.send_after(self(), :render, time_interval)
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

  defp assign_socket_data(%{assigns: %{operator: %{id: operator_id}}} = socket) do
    operator = Staff.get_employer!(operator_id, [:competencies])
    tickets = OperatorClient.get_active_tickets(operator)
    current_tickets = Enum.map(tickets, fn {ticket, _} -> ticket end)
    %{competencies: competencies} = operator

    socket
    |> assign(:operator, operator)
    |> assign(:competencies, Enum.map(competencies, &Map.from_struct/1))
    |> assign(:current_tickets, current_tickets)
  end
end
