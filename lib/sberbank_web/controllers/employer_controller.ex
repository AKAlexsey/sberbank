defmodule SberbankWeb.EmployerController do
  use SberbankWeb, :controller

  alias Sberbank.Staff
  alias Sberbank.Staff.Employer

  def index(conn, _params) do
    employers = Staff.list_employers()
    render(conn, "index.html", employers: employers)
  end

  def new(conn, _params) do
    changeset = Staff.change_employer(%Employer{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"employer" => employer_params}) do
    case Staff.create_employer(employer_params) do
      {:ok, employer} ->
        conn
        |> put_flash(:info, "Employer created successfully.")
        |> redirect(to: Routes.employer_path(conn, :show, employer))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    employer = Staff.get_employer!(id)
    render(conn, "show.html", employer: employer)
  end

  def edit(conn, %{"id" => id}) do
    employer = Staff.get_employer!(id)
    changeset = Staff.change_employer(employer)
    render(conn, "edit.html", employer: employer, changeset: changeset)
  end

  def update(conn, %{"id" => id, "employer" => employer_params}) do
    employer = Staff.get_employer!(id)

    case Staff.update_employer(employer, employer_params) do
      {:ok, employer} ->
        conn
        |> put_flash(:info, "Employer updated successfully.")
        |> redirect(to: Routes.employer_path(conn, :show, employer))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", employer: employer, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    employer = Staff.get_employer!(id)
    {:ok, _employer} = Staff.delete_employer(employer)

    conn
    |> put_flash(:info, "Employer deleted successfully.")
    |> redirect(to: Routes.employer_path(conn, :index))
  end
end
