defmodule Almanack.Repo.Migrations.CreateOfficials do
  use Ecto.Migration

  def change do
    create table(:representatives) do
      add(:bioguide_id, :string, null: false)
      add(:official_name, :text)
      add(:first_name, :string)
      add(:last_name, :string)
      add(:middle_name, :string)
      add(:nickname, :string)
      add(:suffix, :string)
      add(:birthday, :date)
      add(:gender, :string)
      add(:religion, :string)
      add(:media, :map)

      timestamps(inserted_at: :created_at)
    end

    create(unique_index(:representatives, [:bioguide_id]))
  end
end
