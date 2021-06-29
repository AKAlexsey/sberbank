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

  def handle_info(:operator_updated, socket) do
    {:noreply, assign_socket_data(socket)}
  end

  def handle_info({:operator_tickets_updated, new_active_tickets}, socket) do
    current_tickets =
      new_active_tickets
      |> make_current_tickets()

    updated_socket =
      socket
      |> assign(:current_tickets, current_tickets)

    {:noreply, updated_socket}
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
        socket
      ) do
    # TODO legacy rewrite to broadcast
    Eventbus.broadcast_ticket_deactivated(ticket_id)
    {:noreply, assign_socket_data(socket)}
  end

  defp assign_socket_data(%{assigns: %{operator: %{id: operator_id}}} = socket) do
    operator = Staff.get_employer!(operator_id, [:competencies])

    current_tickets =
      operator
      |> OperatorClient.get_active_tickets()
      |> make_current_tickets()

    %{competencies: competencies} = operator

    socket
    |> assign(:operator, operator)
    |> assign(:competencies, Enum.map(competencies, &Map.from_struct/1))
    |> assign(:current_tickets, current_tickets)
  end

  def make_current_tickets(tickets) do
    tickets
    |> Enum.map(fn {ticket, _} -> ticket end)
  end
end
