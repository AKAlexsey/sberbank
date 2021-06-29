defmodule SberbankWeb.CompetenceController do
  use SberbankWeb, :controller

  alias Sberbank.Eventbus
  alias Sberbank.Pipeline.{RabbitClient, Toolkit}
  alias Sberbank.Staff
  alias Sberbank.Staff.Competence

  def index(conn, _params) do
    competencies = Staff.list_competencies()
    render(conn, "index.html", competencies: competencies)
  end

  def new(conn, _params) do
    changeset = Staff.change_competence(%Competence{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"competence" => competence_params}) do
    case Staff.create_competence(competence_params) do
      {:ok, competence} ->
        # TODO move to exchanges pubsub
        Toolkit.declare_exchanges()

        conn
        |> put_flash(:info, "Competence created successfully.")
        |> redirect(to: Routes.competence_path(conn, :show, competence))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    competence = Staff.get_competence!(id)
    render(conn, "show.html", competence: competence)
  end

  def edit(conn, %{"id" => id}) do
    competence = Staff.get_competence!(id)
    changeset = Staff.change_competence(competence)
    render(conn, "edit.html", competence: competence, changeset: changeset)
  end

  def update(conn, %{"id" => id, "competence" => competence_params}) do
    old_competence = Staff.get_competence!(id)

    case Staff.update_competence(old_competence, competence_params) do
      {:ok, updated_competence} ->
        Eventbus.broadcast_competence_updated(old_competence, updated_competence)

        conn
        |> put_flash(:info, "Competence updated successfully.")
        |> redirect(to: Routes.competence_path(conn, :show, updated_competence))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", competence: old_competence, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    competence = Staff.get_competence!(id)
    {:ok, _competence} = Staff.delete_competence(competence)
    Eventbus.broadcast_competence_deleted(competence)

    conn
    |> put_flash(:info, "Competence deleted successfully.")
    |> redirect(to: Routes.competence_path(conn, :index))
  end
end
