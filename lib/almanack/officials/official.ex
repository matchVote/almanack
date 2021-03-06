defmodule Almanack.Officials.Official do
  use Ecto.Schema
  import Ecto.Changeset
  alias Almanack.Officials.Enrichment

  @primary_key {:id, :binary_id, autogenerate: true}
  @mv_key_fields [:first_name, :middle_name, :last_name, :suffix]

  schema "officials" do
    field(:mv_key, :string)
    field(:identifiers, :map)
    field(:official_name, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:middle_name, :string)
    field(:nickname, :string)
    field(:suffix, :string)
    field(:birthday, :date)
    field(:gender, :string)
    field(:religion, :string)
    field(:sexual_orientation, :string)
    field(:status, :string)
    field(:slug, :string)
    field(:profile_pic, :string)
    field(:bio, :string)
    field(:data_source, :string)
    timestamps(inserted_at: :created_at)

    has_many(:terms, Almanack.Officials.Term)
  end

  def changeset(official, params \\ %{}) do
    official
    |> cast(params, [:mv_key | fields()])
    |> validate_required([:mv_key])
    |> unique_constraint(:mv_key)
    |> cast_assoc(:terms)
  end

  defp fields do
    [
      :identifiers,
      :official_name,
      :first_name,
      :last_name,
      :middle_name,
      :nickname,
      :suffix,
      :birthday,
      :gender,
      :religion,
      :sexual_orientation,
      :status,
      :slug,
      :bio,
      :profile_pic,
      :data_source
    ]
  end

  def replace_fields do
    [:updated_at | fields()]
  end

  @spec new([tuple]) :: Ecto.Changeset.t()
  def new(params \\ []) do
    params =
      params
      |> Map.new()
      |> Map.merge(%{
        mv_key: Enrichment.generate_mv_key(params, @mv_key_fields),
        slug: Enrichment.generate_slug(params)
      })

    changeset(%__MODULE__{}, params)
  end

  def change(official, params \\ []) do
    Ecto.Changeset.change(official, Map.new(params))
  end

  @spec get_change(Ecto.Changeset.t(), atom(), any()) :: any()
  def get_change(official, key, default \\ nil) do
    Ecto.Changeset.get_change(official, key, default)
  end

  @spec update_change(Ecto.Changeset.t(), atom(), (any() -> any())) :: Ecto.Changeset.t()
  def update_change(official, key, func) do
    Ecto.Changeset.update_change(official, key, func)
  end
end
