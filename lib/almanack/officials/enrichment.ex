defmodule Almanack.Officials.Enrichment do
  alias Almanack.Officials.Official

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
end
