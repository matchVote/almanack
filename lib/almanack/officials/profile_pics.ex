defmodule Almanack.Officials.ProfilePics do
  import Ecto.Query
  alias Almanack.Repo
  alias Almanack.Officials.{Enrichment, Official}

  @spec load() :: :ok
  def load do
    pics =
      :code.priv_dir(:almanack)
      |> Path.join("static_data/pic_urls")
      |> collect_urls()
      |> parse_urls()

    update_profile_pics(pics, officials_without_profile_pics())
  end

  defp collect_urls(dir) do
    File.ls!(dir)
    |> Enum.flat_map(fn file ->
      Path.join(dir, file)
      |> File.read!()
      |> String.split("\n")
    end)
  end

  @spec parse_urls([String.t()]) :: [map]
  def parse_urls(urls) do
    urls
    |> Enum.map(fn url ->
      [first_name | rest] =
        extract_name(url)
        |> String.split("_")

      last_name = List.last(rest)
      %{url: url, slug: slug(first_name, last_name)}
    end)
  end

  defp extract_name(url) do
    url
    |> String.split("/")
    |> List.last()
    |> String.split(".")
    |> List.first()
  end

  defp slug(first_name, last_name) do
    Enrichment.generate_slug(first_name: first_name, last_name: last_name)
  end

  defp officials_without_profile_pics do
    from(o in Official, where: is_nil(o.profile_pic))
    |> Repo.all()
  end

  @spec update_profile_pics([map], [Official]) :: :ok
  def update_profile_pics(profile_pics, officials) do
    Enum.each(officials, fn official ->
      pic = find_pic(profile_pics, official)

      official
      |> Official.changeset(%{profile_pic: pic.url})
      |> Repo.update!()
    end)
  end

  @spec find_pic([map], Official) :: map
  def find_pic(pics, official) do
    Enum.find(pics, %{url: ""}, fn pic ->
      pic.slug == official.slug
    end)
  end
end
