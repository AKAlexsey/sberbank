defmodule SberbankWeb.EmployerCompetenceControllerTest do
  use SberbankWeb.ConnCase

  alias Sberbank.Staff

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:employer_competence) do
    {:ok, employer_competence} = Staff.create_employer_competence(@create_attrs)
    employer_competence
  end

  describe "index" do
    test "lists all employer_competencies", %{conn: conn} do
      conn = get(conn, Routes.employer_competence_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Employer competencies"
    end
  end

  describe "new employer_competence" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.employer_competence_path(conn, :new))
      assert html_response(conn, 200) =~ "New Employer competence"
    end
  end

  describe "create employer_competence" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.employer_competence_path(conn, :create), employer_competence: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.employer_competence_path(conn, :show, id)

      conn = get(conn, Routes.employer_competence_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Employer competence"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.employer_competence_path(conn, :create), employer_competence: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Employer competence"
    end
  end

  describe "edit employer_competence" do
    setup [:create_employer_competence]

    test "renders form for editing chosen employer_competence", %{conn: conn, employer_competence: employer_competence} do
      conn = get(conn, Routes.employer_competence_path(conn, :edit, employer_competence))
      assert html_response(conn, 200) =~ "Edit Employer competence"
    end
  end

  describe "update employer_competence" do
    setup [:create_employer_competence]

    test "redirects when data is valid", %{conn: conn, employer_competence: employer_competence} do
      conn = put(conn, Routes.employer_competence_path(conn, :update, employer_competence), employer_competence: @update_attrs)
      assert redirected_to(conn) == Routes.employer_competence_path(conn, :show, employer_competence)

      conn = get(conn, Routes.employer_competence_path(conn, :show, employer_competence))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, employer_competence: employer_competence} do
      conn = put(conn, Routes.employer_competence_path(conn, :update, employer_competence), employer_competence: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Employer competence"
    end
  end

  describe "delete employer_competence" do
    setup [:create_employer_competence]

    test "deletes chosen employer_competence", %{conn: conn, employer_competence: employer_competence} do
      conn = delete(conn, Routes.employer_competence_path(conn, :delete, employer_competence))
      assert redirected_to(conn) == Routes.employer_competence_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.employer_competence_path(conn, :show, employer_competence))
      end
    end
  end

  defp create_employer_competence(_) do
    employer_competence = fixture(:employer_competence)
    %{employer_competence: employer_competence}
  end
end
