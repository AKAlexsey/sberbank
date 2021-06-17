defmodule SberbankWeb.EmployerControllerTest do
  use SberbankWeb.ConnCase

  alias Sberbank.Staff

  @create_attrs %{admin: true, name: "some name"}
  @update_attrs %{admin: false, name: "some updated name"}
  @invalid_attrs %{admin: nil, name: nil}

  def fixture(:employer) do
    {:ok, employer} = Staff.create_employer(@create_attrs)
    employer
  end

  describe "index" do
    test "lists all employers", %{conn: conn} do
      conn = get(conn, Routes.employer_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Employers"
    end
  end

  describe "new employer" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.employer_path(conn, :new))
      assert html_response(conn, 200) =~ "New Employer"
    end
  end

  describe "create employer" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.employer_path(conn, :create), employer: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.employer_path(conn, :show, id)

      conn = get(conn, Routes.employer_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Employer"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.employer_path(conn, :create), employer: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Employer"
    end
  end

  describe "edit employer" do
    setup [:create_employer]

    test "renders form for editing chosen employer", %{conn: conn, employer: employer} do
      conn = get(conn, Routes.employer_path(conn, :edit, employer))
      assert html_response(conn, 200) =~ "Edit Employer"
    end
  end

  describe "update employer" do
    setup [:create_employer]

    test "redirects when data is valid", %{conn: conn, employer: employer} do
      conn = put(conn, Routes.employer_path(conn, :update, employer), employer: @update_attrs)
      assert redirected_to(conn) == Routes.employer_path(conn, :show, employer)

      conn = get(conn, Routes.employer_path(conn, :show, employer))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, employer: employer} do
      conn = put(conn, Routes.employer_path(conn, :update, employer), employer: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Employer"
    end
  end

  describe "delete employer" do
    setup [:create_employer]

    test "deletes chosen employer", %{conn: conn, employer: employer} do
      conn = delete(conn, Routes.employer_path(conn, :delete, employer))
      assert redirected_to(conn) == Routes.employer_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.employer_path(conn, :show, employer))
      end
    end
  end

  defp create_employer(_) do
    employer = fixture(:employer)
    %{employer: employer}
  end
end
