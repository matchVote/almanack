defmodule Almanack.Sources.StaticFiles do
  # import Mockery.Macro
  require Logger
  # alias __MODULE__.API
  alias Almanack.Officials.{Enrichment, Official}

  @static_files_dir :code.priv_dir(:almanack) |> Path.join("data/static_files")

  # @spec officials() :: [Ecto.Changeset.t()]
  def officials do
    static_data()
    |> map_to_officials()
  end

  def static_data do
    @static_files_dir
    |> File.ls!()
    |> Enum.flat_map(fn file ->
      Path.join(@static_files_dir, file)
      |> YamlElixir.read_from_file!()
    end)
  end

  defp map_to_officials(raw_officials) do
    raw_officials
    |> Enum.map(fn data ->
      Official.new(
        first_name: data["first_name"],
        last_name: data["last_name"],
        middle_name: data["middle_name"],
        nickname: data["nick_name"],
        suffix: data["suffix"],
        birthday: data["birthday"],
        gender: Enrichment.standardize_gender(data["gender"]),
        religion: data["religion"],
        sexual_orientation: data["orientation"],
        status: data["rep_status"]
      )
    end)
  end
end

# IDs
# "facebook" => "https://www.facebook.com/barackobama",
# "twitter" => "https://twitter.com/barackobama",
# "wiki" => "http://en.wikipedia.org/wiki/Barack_Obama",
# "youtube" => "https://www.youtube.com/user/BarackObamadotcom"

# Terms
# "address" => "The White House, 1600 Pennsylvania Avenue NW, Washington, DC 20500",
# "branch" => "executive",
# "contact_form_url" => "https://www.whitehouse.gov/contact/submit-questions-and-comments",
# "fax" => nil,
# "tel" => "202-456-1111",
# "party" => "D",
# "state" => "DC",
# "took_office" => "2009-01-20",
# "term_ends" => 2016,
# "title" => "President",
# "web" => "https://www.barackobama.com/",

# Not handled
# "name_recognition" => 54815149,
# "profile_pic" => "http://data.matchvote.com/images/2015/highprofile/Barack_Obama.png",
