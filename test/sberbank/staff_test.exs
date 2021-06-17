defmodule Sberbank.StaffTest do
  use Sberbank.DataCase

  alias Sberbank.Staff

  @employer_valid_attrs %{admin: true, name: "some name"}
  @employer_update_attrs %{admin: false, name: "some updated name"}
  @employer_invalid_attrs %{admin: nil, name: nil}

  def employer_fixture(attrs \\ %{}) do
    {:ok, employer} =
      attrs
      |> Enum.into(@employer_valid_attrs)
      |> Staff.create_employer()

    employer
  end

  @competence_valid_attrs %{letter: "C", name: "Credit"}
  @competence_update_attrs %{letter: "D", name: "Debt"}
  @competence_invalid_attrs %{letter: nil, name: nil}

  def competence_fixture(attrs \\ %{}) do
    {:ok, competence} =
      attrs
      |> Enum.into(@competence_valid_attrs)
      |> Staff.create_competence()

    competence
  end

  def employer_competence_fixture(attrs \\ %{}) do
    {:ok, employer_competence} = Staff.create_employer_competence(attrs)

    employer_competence
  end

  describe "employers" do
    alias Sberbank.Staff.Employer

    test "list_employers/1 returns all employers" do
      employer = employer_fixture()
      assert Staff.list_employers() == [employer]
    end

    test "list_employers/1 returns all employers with preloaded information " do
      %{id: employer_id} = employer_fixture()
      %{id: competence_id} = competence_fixture()
      employer_competence_fixture(%{employer_id: employer_id, competence_id: competence_id})
      [employer] = Staff.list_employers([:competencies])
      assert %{id: ^employer_id, competencies: [%{id: ^competence_id}]} = employer
    end

    test "get_employer!/1 returns the employer with given id" do
      employer = employer_fixture()
      assert Staff.get_employer!(employer.id) == employer
    end

    test "get_employer!/1 allow to preload necessary information" do
      %{id: employer_id} = employer_fixture()
      %{id: competence_id} = competence_fixture()
      employer_competence_fixture(%{employer_id: employer_id, competence_id: competence_id})

      assert %{id: ^employer_id, competencies: [%{id: ^competence_id}]} =
               Staff.get_employer!(employer_id, [:competencies])
    end

    test "create_employer/1 with valid data creates a employer" do
      assert {:ok, %Employer{} = employer} = Staff.create_employer(@employer_valid_attrs)
      assert employer.admin == true
      assert employer.name == "some name"
    end

    test "create_employer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_employer(@employer_invalid_attrs)
    end

    test "update_employer/2 with valid data updates the employer" do
      employer = employer_fixture()

      assert {:ok, %Employer{} = employer} =
               Staff.update_employer(employer, @employer_update_attrs)

      assert employer.admin == false
      assert employer.name == "some updated name"
    end

    test "update_employer/2 allows to create relationship during update" do
      %{id: employer_id} = employer_fixture()
      %{id: competence_id} = competence_fixture()

      employer = Staff.get_employer!(employer_id, [:competencies])

      update_attrs =
        Map.put(@employer_update_attrs, :employer_competencies, [
          %{employer_id: employer_id, competence_id: competence_id}
        ])

      assert {:ok, %Employer{} = employer} = Staff.update_employer(employer, update_attrs)
      assert employer.admin == false
      assert employer.name == "some updated name"

      assert %{id: ^employer_id, competencies: [%{id: ^competence_id}]} =
               Staff.get_employer!(employer_id, [:competencies])
    end

    test "update_employer/2 with invalid data returns error changeset" do
      employer = employer_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Staff.update_employer(employer, @employer_invalid_attrs)

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

    test "list_competencies/0 returns all competencies" do
      competence = competence_fixture()
      assert Staff.list_competencies() == [competence]
    end

    test "get_competence!/1 returns the competence with given id" do
      competence = competence_fixture()
      assert Staff.get_competence!(competence.id) == competence
    end

    test "create_competence/1 with valid data creates a competence" do
      assert {:ok, %Competence{} = competence} = Staff.create_competence(@competence_valid_attrs)
      assert competence.letter == "C"
      assert competence.name == "Credit"
    end

    test "create_competence/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Staff.create_competence(@competence_invalid_attrs)
    end

    test "update_competence/2 with valid data updates the competence" do
      competence = competence_fixture()

      assert {:ok, %Competence{} = competence} =
               Staff.update_competence(competence, @competence_update_attrs)

      assert competence.letter == "D"
      assert competence.name == "Debt"
    end

    test "update_competence/2 with invalid data returns error changeset" do
      competence = competence_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Staff.update_competence(competence, @competence_invalid_attrs)

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
end
