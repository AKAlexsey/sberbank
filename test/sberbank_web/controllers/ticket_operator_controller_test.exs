defmodule SberbankWeb.TicketOperatorControllerTest do
  use SberbankWeb.ConnCase

  alias Sberbank.Customers

  @create_attrs %{active: true}
  @update_attrs %{active: false}
  @invalid_attrs %{active: nil}

  def fixture(:ticket_operator) do
    {:ok, ticket_operator} = Customers.create_ticket_operator(@create_attrs)
    ticket_operator
  end

  describe "index" do
    test "lists all ticket_operators", %{conn: conn} do
      conn = get(conn, Routes.ticket_operator_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Ticket operators"
    end
  end

  describe "new ticket_operator" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.ticket_operator_path(conn, :new))
      assert html_response(conn, 200) =~ "New Ticket operator"
    end
  end

  describe "create ticket_operator" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.ticket_operator_path(conn, :create), ticket_operator: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.ticket_operator_path(conn, :show, id)

      conn = get(conn, Routes.ticket_operator_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Ticket operator"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.ticket_operator_path(conn, :create), ticket_operator: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Ticket operator"
    end
  end

  describe "edit ticket_operator" do
    setup [:create_ticket_operator]

    test "renders form for editing chosen ticket_operator", %{conn: conn, ticket_operator: ticket_operator} do
      conn = get(conn, Routes.ticket_operator_path(conn, :edit, ticket_operator))
      assert html_response(conn, 200) =~ "Edit Ticket operator"
    end
  end

  describe "update ticket_operator" do
    setup [:create_ticket_operator]

    test "redirects when data is valid", %{conn: conn, ticket_operator: ticket_operator} do
      conn = put(conn, Routes.ticket_operator_path(conn, :update, ticket_operator), ticket_operator: @update_attrs)
      assert redirected_to(conn) == Routes.ticket_operator_path(conn, :show, ticket_operator)

      conn = get(conn, Routes.ticket_operator_path(conn, :show, ticket_operator))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, ticket_operator: ticket_operator} do
      conn = put(conn, Routes.ticket_operator_path(conn, :update, ticket_operator), ticket_operator: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Ticket operator"
    end
  end

  describe "delete ticket_operator" do
    setup [:create_ticket_operator]

    test "deletes chosen ticket_operator", %{conn: conn, ticket_operator: ticket_operator} do
      conn = delete(conn, Routes.ticket_operator_path(conn, :delete, ticket_operator))
      assert redirected_to(conn) == Routes.ticket_operator_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.ticket_operator_path(conn, :show, ticket_operator))
      end
    end
  end

  defp create_ticket_operator(_) do
    ticket_operator = fixture(:ticket_operator)
    %{ticket_operator: ticket_operator}
  end
end
