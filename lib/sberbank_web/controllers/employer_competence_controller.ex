defmodule SberbankWeb.EmployerCompetenceController do
  use SberbankWeb, :controller

  alias Sberbank.Staff
  alias Sberbank.Staff.EmployerCompetence

  def index(conn, _params) do
    employer_competencies = Staff.list_employer_competencies()
    render(conn, "index.html", employer_competencies: employer_competencies)
  end

  def new(conn, _params) do
    changeset = Staff.change_employer_competence(%EmployerCompetence{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"employer_competence" => employer_competence_params}) do
    case Staff.create_employer_competence(employer_competence_params) do
      {:ok, employer_competence} ->
        conn
        |> put_flash(:info, "Employer competence created successfully.")
        |> redirect(to: Routes.employer_competence_path(conn, :show, employer_competence))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    employer_competence = Staff.get_employer_competence!(id)
    render(conn, "show.html", employer_competence: employer_competence)
  end

  def edit(conn, %{"id" => id}) do
    employer_competence = Staff.get_employer_competence!(id)
    changeset = Staff.change_employer_competence(employer_competence)
    render(conn, "edit.html", employer_competence: employer_competence, changeset: changeset)
  end

  def update(conn, %{"id" => id, "employer_competence" => employer_competence_params}) do
    employer_competence = Staff.get_employer_competence!(id)

    case Staff.update_employer_competence(employer_competence, employer_competence_params) do
      {:ok, employer_competence} ->
        conn
        |> put_flash(:info, "Employer competence updated successfully.")
        |> redirect(to: Routes.employer_competence_path(conn, :show, employer_competence))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", employer_competence: employer_competence, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    employer_competence = Staff.get_employer_competence!(id)
    {:ok, _employer_competence} = Staff.delete_employer_competence(employer_competence)

    conn
    |> put_flash(:info, "Employer competence deleted successfully.")
    |> redirect(to: Routes.employer_competence_path(conn, :index))
  end
end
