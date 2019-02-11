defmodule Almanack.Official do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "officials" do
    field(:bioguide_id, :string)
    field(:official_name, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:middle_name, :string)
    field(:nickname, :string)
    field(:suffix, :string)
    field(:birthday, :date)
    field(:gender, :string)
    field(:religion, :string)
    field(:media, :map)
    field(:branch, :string)
    field(:status, :string)
    field(:party, :string)
    field(:state, :string)
    field(:state_rank, :string)
    field(:government_role, :string)
    field(:seniority_date, :date)
    field(:contact_form, :string)
    field(:phone_number, :string)
    field(:website, :string)
    field(:emails, {:array, :string})
    timestamps(inserted_at: :created_at)
  end

  def changeset(official, params \\ %{}) do
    official
    |> cast(params, fields())
    |> unique_constraint(:bioguide_id, name: "officials_bioguide_id_index")
    |> validate_required([:bioguide_id])
  end

  defp fields do
    [
      :bioguide_id,
      :official_name,
      :first_name,
      :last_name,
      :middle_name,
      :nickname,
      :suffix,
      :birthday,
      :gender,
      :religion,
      :media,
      :branch,
      :status,
      :party,
      :state,
      :state_rank,
      :seniority_date,
      :government_role,
      :contact_form,
      :phone_number,
      :website,
      :emails
    ]
  end

  def replace_fields do
    [:updated_at | fields()]
  end

  def new(params \\ []) do
    changeset(%Almanack.Official{}, Map.new(params))
  end

  def change(official, params \\ []) do
    Ecto.Changeset.change(official, Map.new(params))
  end

  def get_change(official, key, default \\ nil) do
    Ecto.Changeset.get_change(official, key, default)
  end
end
