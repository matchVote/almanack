defmodule Almanack.Officials.Enrichment do
  alias Almanack.Officials.Official

  @doc """
  Weak suffix check, but it's satisfactory for now.
  Refactor
  """
  @spec split_name(String.t()) :: map
  def split_name(name) do
    case String.split(name) do
      [first | [last]] = parts when length(parts) == 2 ->
        %{first_name: first, middle_name: "", last_name: last, suffix: ""}

      [first | [middle | [last]]] = parts when length(parts) == 3 ->
        cond do
          String.contains?(last, ".") ->
            %{first_name: first, middle_name: "", last_name: middle, suffix: last}

          true ->
            %{first_name: first, middle_name: middle, last_name: last, suffix: ""}
        end

      [first | [middle | [last | [suffix]]]] = parts when length(parts) == 4 ->
        %{first_name: first, middle_name: middle, last_name: last, suffix: suffix}
    end
  end

  @spec generate_mv_key(map, [atom]) :: String.t()
  def generate_mv_key(data, fields) do
    fields
    |> Enum.map(&normalize(data[&1]))
    |> Enum.reduce(fn
      "", mv_key -> mv_key
      value, mv_key -> "#{mv_key}-#{value}"
    end)
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

  defp normalize(nil), do: ""

  defp normalize(name) do
    name
    |> String.downcase()
    |> String.replace(".", "")
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

  @doc """
  Perhaps move this to a config file and use it as a map?
  """
  @spec standardize_party(String.t()) :: String.t()
  def standardize_party(party) do
    case party do
      "Democratic Party" ->
        "Democrat"

      "D" ->
        "Democrat"

      "Republican Party" ->
        "Republican"

      "R" ->
        "Republican"

      "I" ->
        "Independent"

      _ ->
        party
    end
  end

  @spec standardize_media_key(String.t()) :: String.t()
  def standardize_media_key(key) do
    String.downcase(key)
  end
end
