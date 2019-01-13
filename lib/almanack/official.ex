defmodule Almanack.Official do
  use Ecto.Schema
  import Ecto.Changeset

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
  end

  def changeset(official, params \\ %{}) do
    official
    |> cast(params, [
      :bioguide_id,
      :first_name,
      :last_name,
      :media
    ])
    |> unique_constraint(:bioguide_id, name: "officials_bioguide_id_index")
    |> validate_required([:bioguide_id])
  end
end
