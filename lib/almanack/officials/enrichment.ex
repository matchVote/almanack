defmodule Almanack.Officials.Enrichment do
  alias Almanack.Officials.Official

  @spec generate_mv_key(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def generate_mv_key(official) do
    key =
      Official.mv_key_fields()
      |> Enum.map(fn field ->
        Official.get_change(official, field, "")
        |> normalize()
      end)
      |> Enum.reduce(fn
        "", mv_key -> mv_key
        value, mv_key -> "#{mv_key}-#{value}"
      end)

    Official.change(official, mv_key: key)
  end

  @spec generate_slug(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def generate_slug(official) do
    first_name = slug_first_name(official)
    last_name = Official.get_change(official, :last_name)
    slug = normalize("#{first_name}-#{last_name}")
    Official.change(official, slug: slug)
  end

  defp slug_first_name(official) do
    case Official.get_change(official, :nickname) do
      nil -> Official.get_change(official, :first_name)
      nickname -> nickname
    end
  end

  defp normalize(name) do
    name
    |> String.downcase()
    |> String.replace(".", "")
  end

  @spec set_defaults(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def set_defaults(official) do
    official
    |> Official.change(
      branch: "legislative",
      status: "in_office"
    )
  end

  @spec format_gender(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def format_gender(official) do
    Official.update_change(official, :gender, fn value ->
      value
      |> to_string()
      |> String.capitalize()
      |> expand_gender()
    end)
  end

  defp expand_gender("M"), do: "male"
  defp expand_gender("F"), do: "female"
  defp expand_gender(_), do: nil

  @spec downcase_religion(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def downcase_religion(official) do
    Official.update_change(official, :religion, fn value ->
      String.downcase(value)
    end)
  end
end
