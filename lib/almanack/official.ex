defmodule Almanack.Official do
  use Ecto.Schema

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
end
