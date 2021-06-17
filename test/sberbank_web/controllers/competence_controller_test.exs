defmodule SberbankWeb.CompetenceControllerTest do
  use SberbankWeb.ConnCase

  alias Sberbank.Staff

  @create_attrs %{letter: "some letter", name: "some name"}
  @update_attrs %{letter: "some updated letter", name: "some updated name"}
  @invalid_attrs %{letter: nil, name: nil}

  def fixture(:competence) do
    {:ok, competence} = Staff.create_competence(@create_attrs)
    competence
  end

  describe "index" do
    test "lists all competencies", %{conn: conn} do
      conn = get(conn, Routes.competence_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Competencies"
    end
  end

  describe "new competence" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.competence_path(conn, :new))
      assert html_response(conn, 200) =~ "New Competence"
    end
  end

  describe "create competence" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.competence_path(conn, :create), competence: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.competence_path(conn, :show, id)

      conn = get(conn, Routes.competence_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Competence"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.competence_path(conn, :create), competence: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Competence"
    end
  end

  describe "edit competence" do
    setup [:create_competence]

    test "renders form for editing chosen competence", %{conn: conn, competence: competence} do
      conn = get(conn, Routes.competence_path(conn, :edit, competence))
      assert html_response(conn, 200) =~ "Edit Competence"
    end
  end

  describe "update competence" do
    setup [:create_competence]

    test "redirects when data is valid", %{conn: conn, competence: competence} do
      conn =
        put(conn, Routes.competence_path(conn, :update, competence), competence: @update_attrs)

      assert redirected_to(conn) == Routes.competence_path(conn, :show, competence)

      conn = get(conn, Routes.competence_path(conn, :show, competence))
      assert html_response(conn, 200) =~ "some updated letter"
    end

    test "renders errors when data is invalid", %{conn: conn, competence: competence} do
      conn =
        put(conn, Routes.competence_path(conn, :update, competence), competence: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Competence"
    end
  end

  describe "delete competence" do
    setup [:create_competence]

    test "deletes chosen competence", %{conn: conn, competence: competence} do
      conn = delete(conn, Routes.competence_path(conn, :delete, competence))
      assert redirected_to(conn) == Routes.competence_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.competence_path(conn, :show, competence))
      end
    end
  end

  defp create_competence(_) do
    competence = fixture(:competence)
    %{competence: competence}
  end
end
