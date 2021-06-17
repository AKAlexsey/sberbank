defmodule SberbankWeb.EmployerController do
  use SberbankWeb, :controller

  alias Sberbank.Staff
  alias Sberbank.Staff.Employer

  def index(conn, _params) do
    employers = Staff.list_employers()
    render(conn, "index.html", employers: employers)
  end

  def new(conn, _params) do
    changeset =
      %Employer{}
      |> Map.put(:employer_competencies, [])
      |> Staff.change_employer()

    competences = Staff.list_competencies()
    render(conn, "new.html", changeset: changeset, competences: competences)
  end

  def create(conn, %{"employer" => employer_params}) do
    case Staff.create_employer(employer_params) do
      {:ok, employer} ->
        conn
        |> put_flash(:info, "Employer created successfully.")
        |> redirect(to: Routes.employer_path(conn, :show, employer))

      {:error, %Ecto.Changeset{} = changeset} ->
        competences = Staff.list_competencies()
        render(conn, "new.html", changeset: changeset, competences: competences)
    end
  end

  def show(conn, %{"id" => id}) do
    employer = Staff.get_employer!(id, [:competencies])
    render(conn, "show.html", employer: employer)
  end

  def edit(conn, %{"id" => id}) do
    employer = Staff.get_employer!(id, [:competencies])
    changeset = Staff.change_employer(employer)
    competences = Staff.list_competencies()
    render(conn, "edit.html", employer: employer, changeset: changeset, competences: competences)
  end

  def update(conn, %{"id" => id, "employer" => employer_params}) do
    employer = Staff.get_employer!(id, [:competencies])
    update_params = make_update_params(id, employer_params)

    case Staff.update_employer(employer, update_params) do
      {:ok, employer} ->
        conn
        |> put_flash(:info, "Employer updated successfully.")
        |> redirect(to: Routes.employer_path(conn, :show, employer))

      {:error, %Ecto.Changeset{} = changeset} ->
        competences = Staff.list_competencies()

        render(conn, "edit.html",
          employer: employer,
          changeset: changeset,
          competences: competences
        )
    end
  end

  defp make_update_params(employer_id, %{"employer_competencies_list" => competence_ids} = params) do
    employer_competencies_params =
      competence_ids
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.map(fn competence_id ->
        %{"competence_id" => competence_id, "employer_id" => employer_id}
      end)

    params
    |> Map.put("employer_competencies", employer_competencies_params)
  end

  def delete(conn, %{"id" => id}) do
    employer = Staff.get_employer!(id)
    {:ok, _employer} = Staff.delete_employer(employer)

    conn
    |> put_flash(:info, "Employer deleted successfully.")
    |> redirect(to: Routes.employer_path(conn, :index))
  end
end
