defmodule Almanack.Officials.Term do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "terms" do
    field(:start_date, :date)
    field(:end_date, :date)
    field(:role)
    field(:party)
    field(:state)
    field(:state_rank)
    field(:contact_form)
    field(:phone_number)
    field(:fax_number)
    field(:emails, {:array, :string}, default: [])
    field(:website)
    field(:address, :map)
    field(:level)
    field(:branch)
    timestamps()

    belongs_to(:official, Almanack.Officials.Official, type: :binary_id)
  end

  def changeset(term, params \\ %{}) do
    term
    |> cast(params, [
      :start_date,
      :end_date,
      :role,
      :party,
      :state,
      :state_rank,
      :contact_form,
      :phone_number,
      :fax_number,
      :emails,
      :website,
      :address,
      :level,
      :branch,
      :official_id
    ])
    |> foreign_key_constraint(:official_id)
    |> unique_constraint(:official_id, name: :terms_official_id_start_date_index)
  end

  def new(params \\ []) do
    changeset(%__MODULE__{}, Map.new(params))
  end
end
