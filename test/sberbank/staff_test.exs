defmodule Sberbank.StaffTest do
  use Sberbank.DataCase

  alias Sberbank.Staff

  describe "employers" do
    alias Sberbank.Staff.Employer

    @valid_attrs %{admin: true, name: "some name"}
    @update_attrs %{admin: false, name: "some updated name"}
    @invalid_attrs %{admin: nil, name: nil}

    def employer_fixture(attrs \\ %{}) do
      {:ok, employer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Staff.create_employer()

      employer
    end

    test "list_employers/0 returns all employers" do
      employer = employer_fixture()
      assert Staff.list_employers() == [employer]
    end

    test "get_employer!/1 returns the employer with given id" do
      employer = employer_fixture()
      assert Staff.get_employer!(employer.id) == employer
    end

    test "create_employer/1 with valid data creates a employer" do
      assert {:ok, %Employer{} = employer} = Staff.create_employer(@valid_attrs)
      assert employer.admin == true
      assert employer.name == "some name"
    end

    test "create_employer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_employer(@invalid_attrs)
    end

    test "update_employer/2 with valid data updates the employer" do
      employer = employer_fixture()
      assert {:ok, %Employer{} = employer} = Staff.update_employer(employer, @update_attrs)
      assert employer.admin == false
      assert employer.name == "some updated name"
    end

    test "update_employer/2 with invalid data returns error changeset" do
      employer = employer_fixture()
      assert {:error, %Ecto.Changeset{}} = Staff.update_employer(employer, @invalid_attrs)
      assert employer == Staff.get_employer!(employer.id)
    end

    test "delete_employer/1 deletes the employer" do
      employer = employer_fixture()
      assert {:ok, %Employer{}} = Staff.delete_employer(employer)
      assert_raise Ecto.NoResultsError, fn -> Staff.get_employer!(employer.id) end
    end

    test "change_employer/1 returns a employer changeset" do
      employer = employer_fixture()
      assert %Ecto.Changeset{} = Staff.change_employer(employer)
    end
  end

  describe "competencies" do
    alias Sberbank.Staff.Competence

    @valid_attrs %{letter: "some letter", name: "some name"}
    @update_attrs %{letter: "some updated letter", name: "some updated name"}
    @invalid_attrs %{letter: nil, name: nil}

    def competence_fixture(attrs \\ %{}) do
      {:ok, competence} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Staff.create_competence()

      competence
    end

    test "list_competencies/0 returns all competencies" do
      competence = competence_fixture()
      assert Staff.list_competencies() == [competence]
    end

    test "get_competence!/1 returns the competence with given id" do
      competence = competence_fixture()
      assert Staff.get_competence!(competence.id) == competence
    end

    test "create_competence/1 with valid data creates a competence" do
      assert {:ok, %Competence{} = competence} = Staff.create_competence(@valid_attrs)
      assert competence.letter == "some letter"
      assert competence.name == "some name"
    end

    test "create_competence/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_competence(@invalid_attrs)
    end

    test "update_competence/2 with valid data updates the competence" do
      competence = competence_fixture()
      assert {:ok, %Competence{} = competence} = Staff.update_competence(competence, @update_attrs)
      assert competence.letter == "some updated letter"
      assert competence.name == "some updated name"
    end

    test "update_competence/2 with invalid data returns error changeset" do
      competence = competence_fixture()
      assert {:error, %Ecto.Changeset{}} = Staff.update_competence(competence, @invalid_attrs)
      assert competence == Staff.get_competence!(competence.id)
    end

    test "delete_competence/1 deletes the competence" do
      competence = competence_fixture()
      assert {:ok, %Competence{}} = Staff.delete_competence(competence)
      assert_raise Ecto.NoResultsError, fn -> Staff.get_competence!(competence.id) end
    end

    test "change_competence/1 returns a competence changeset" do
      competence = competence_fixture()
      assert %Ecto.Changeset{} = Staff.change_competence(competence)
    end
  end

  describe "employer_competencies" do
    alias Sberbank.Staff.EmployerCompetence

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def employer_competence_fixture(attrs \\ %{}) do
      {:ok, employer_competence} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Staff.create_employer_competence()

      employer_competence
    end

    test "list_employer_competencies/0 returns all employer_competencies" do
      employer_competence = employer_competence_fixture()
      assert Staff.list_employer_competencies() == [employer_competence]
    end

    test "get_employer_competence!/1 returns the employer_competence with given id" do
      employer_competence = employer_competence_fixture()
      assert Staff.get_employer_competence!(employer_competence.id) == employer_competence
    end

    test "create_employer_competence/1 with valid data creates a employer_competence" do
      assert {:ok, %EmployerCompetence{} = employer_competence} = Staff.create_employer_competence(@valid_attrs)
    end

    test "create_employer_competence/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_employer_competence(@invalid_attrs)
    end

    test "update_employer_competence/2 with valid data updates the employer_competence" do
      employer_competence = employer_competence_fixture()
      assert {:ok, %EmployerCompetence{} = employer_competence} = Staff.update_employer_competence(employer_competence, @update_attrs)
    end

    test "update_employer_competence/2 with invalid data returns error changeset" do
      employer_competence = employer_competence_fixture()
      assert {:error, %Ecto.Changeset{}} = Staff.update_employer_competence(employer_competence, @invalid_attrs)
      assert employer_competence == Staff.get_employer_competence!(employer_competence.id)
    end

    test "delete_employer_competence/1 deletes the employer_competence" do
      employer_competence = employer_competence_fixture()
      assert {:ok, %EmployerCompetence{}} = Staff.delete_employer_competence(employer_competence)
      assert_raise Ecto.NoResultsError, fn -> Staff.get_employer_competence!(employer_competence.id) end
    end

    test "change_employer_competence/1 returns a employer_competence changeset" do
      employer_competence = employer_competence_fixture()
      assert %Ecto.Changeset{} = Staff.change_employer_competence(employer_competence)
    end
  end
end
