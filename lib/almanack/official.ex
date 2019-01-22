defmodule Almanack.Official do
  use Ecto.Schema
  import Ecto.Changeset

  schema "representatives" do
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

    timestamps(inserted_at: :created_at)
  end

  def changeset(official, params \\ %{}) do
    official
    |> cast(params, [
      :bioguide_id,
      :first_name,
      :last_name,
      :middle_name,
      :nickname,
      :suffix,
      :birthday,
      :gender,
      :religion,
      :media
    ])
    |> unique_constraint(:bioguide_id, name: "officials_bioguide_id_index")
    |> validate_required([:bioguide_id])
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
