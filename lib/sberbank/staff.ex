defmodule Sberbank.Staff do
  @moduledoc """
  The Staff context.
  """

  import Ecto.Query, warn: false
  alias Sberbank.Repo

  alias Sberbank.Staff.Employer

  @doc """
  Returns the list of employers.

  ## Examples

      iex> list_employers()
      [%Employer{}, ...]

  """
  def list_employers(preload \\ []) do
    Employer
    |> Repo.all()
    |> Repo.preload(preload)
  end

  @doc """
  Gets a single employer.

  Raises `Ecto.NoResultsError` if the Employer does not exist.

  ## Examples

      iex> get_employer!(123)
      %Employer{}

      iex> get_employer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_employer!(id, preload \\ []) do
    Employer
    |> Repo.get!(id)
    |> Repo.preload(preload)
  end

  @doc """
  Creates a employer.

  ## Examples

      iex> create_employer(%{field: value})
      {:ok, %Employer{}}

      iex> create_employer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_employer(attrs \\ %{}) do
    %Employer{}
    |> Employer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a employer.

  ## Examples

      iex> update_employer(employer, %{field: new_value})
      {:ok, %Employer{}}

      iex> update_employer(employer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_employer(%Employer{} = employer, attrs) do
    employer
    |> Employer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a employer.

  ## Examples

      iex> delete_employer(employer)
      {:ok, %Employer{}}

      iex> delete_employer(employer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_employer(%Employer{} = employer) do
    Repo.delete(employer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking employer changes.

  ## Examples

      iex> change_employer(employer)
      %Ecto.Changeset{data: %Employer{}}

  """
  def change_employer(%Employer{} = employer, attrs \\ %{}) do
    Employer.changeset(employer, attrs)
  end

  alias Sberbank.Staff.Competence

  @doc """
  Returns the list of competencies.

  ## Examples

      iex> list_competencies()
      [%Competence{}, ...]

  """
  def list_competencies do
    Repo.all(Competence)
  end

  @doc """
  Gets a single competence.

  Raises `Ecto.NoResultsError` if the Competence does not exist.

  ## Examples

      iex> get_competence!(123)
      %Competence{}

      iex> get_competence!(456)
      ** (Ecto.NoResultsError)

  """
  def get_competence!(id), do: Repo.get!(Competence, id)

  @doc """
  Creates a competence.

  ## Examples

      iex> create_competence(%{field: value})
      {:ok, %Competence{}}

      iex> create_competence(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_competence(attrs \\ %{}) do
    %Competence{}
    |> Competence.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a competence.

  ## Examples

      iex> update_competence(competence, %{field: new_value})
      {:ok, %Competence{}}

      iex> update_competence(competence, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_competence(%Competence{} = competence, attrs) do
    competence
    |> Competence.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a competence.

  ## Examples

      iex> delete_competence(competence)
      {:ok, %Competence{}}

      iex> delete_competence(competence)
      {:error, %Ecto.Changeset{}}

  """
  def delete_competence(%Competence{} = competence) do
    Repo.delete(competence)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking competence changes.

  ## Examples

      iex> change_competence(competence)
      %Ecto.Changeset{data: %Competence{}}

  """
  def change_competence(%Competence{} = competence, attrs \\ %{}) do
    Competence.changeset(competence, attrs)
  end

  alias Sberbank.Staff.EmployerCompetence

  @doc """
  Returns the list of employer_competencies.

  ## Examples

      iex> list_employer_competencies()
      [%EmployerCompetence{}, ...]

  """
  def list_employer_competencies do
    Repo.all(EmployerCompetence)
  end

  @doc """
  Gets a single employer_competence.

  Raises `Ecto.NoResultsError` if the Employer competence does not exist.

  ## Examples

      iex> get_employer_competence!(123)
      %EmployerCompetence{}

      iex> get_employer_competence!(456)
      ** (Ecto.NoResultsError)

  """
  def get_employer_competence!(id), do: Repo.get!(EmployerCompetence, id)

  @doc """
  Creates a employer_competence.

  ## Examples

      iex> create_employer_competence(%{field: value})
      {:ok, %EmployerCompetence{}}

      iex> create_employer_competence(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_employer_competence(attrs \\ %{}) do
    %EmployerCompetence{}
    |> EmployerCompetence.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a employer_competence.

  ## Examples

      iex> update_employer_competence(employer_competence, %{field: new_value})
      {:ok, %EmployerCompetence{}}

      iex> update_employer_competence(employer_competence, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_employer_competence(%EmployerCompetence{} = employer_competence, attrs) do
    employer_competence
    |> EmployerCompetence.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a employer_competence.

  ## Examples

      iex> delete_employer_competence(employer_competence)
      {:ok, %EmployerCompetence{}}

      iex> delete_employer_competence(employer_competence)
      {:error, %Ecto.Changeset{}}

  """
  def delete_employer_competence(%EmployerCompetence{} = employer_competence) do
    Repo.delete(employer_competence)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking employer_competence changes.

  ## Examples

      iex> change_employer_competence(employer_competence)
      %Ecto.Changeset{data: %EmployerCompetence{}}

  """
  def change_employer_competence(%EmployerCompetence{} = employer_competence, attrs \\ %{}) do
    EmployerCompetence.changeset(employer_competence, attrs)
  end
end
