defmodule Almanack.Officials.Enrichment do
  alias Almanack.Officials.Official

  @month_numbers %{
    "January" => "01",
    "February" => "02",
    "March" => "03",
    "April" => "04",
    "May" => "05",
    "June" => "06",
    "July" => "07",
    "August" => "08",
    "September" => "09",
    "October" => "10",
    "November" => "11",
    "December" => "12"
  }

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

  @spec generate_slug([{atom, any}]) :: String.t()
  def generate_slug(fields) do
    first_name = Keyword.get(fields, :nickname) || fields[:first_name]
    normalize("#{first_name}-#{fields[:last_name]}")
  end

  defp normalize(nil), do: ""

  defp normalize(name) do
    name
    |> String.downcase()
    |> String.replace(".", "")
  end

  def standardize_gender(nil), do: nil

  @spec standardize_gender(String.t()) :: String.t()
  def standardize_gender(gender) do
    gender
    |> String.downcase()
    |> case do
      "m" -> "male"
      "male" -> "male"
      "f" -> "female"
      "female" -> "female"
      _ -> nil
    end
  end

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

  @spec standardize_date(nil) :: nil
  def standardize_date(nil), do: nil

  @spec standardize_date(integer) :: String.t()
  def standardize_date(date) when is_integer(date) do
    Integer.to_string(date)
    |> standardize_date()
  end

  @spec standardize_date(String.t()) :: String.t()
  def standardize_date(date) do
    case String.length(date) do
      4 ->
        "#{date}-01-01"

      10 ->
        date

      _ ->
        Regex.split(~r/(\s|,\s)/, date)
        |> format_date()
    end
  end

  defp format_date([month, day, year]) do
    day = if String.length(day) == 1, do: "0#{day}", else: day
    "#{year}-#{@month_numbers[month]}-#{day}"
  end
end
