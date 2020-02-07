defmodule Almanack.SchedulerTest do
  use Almanack.RepoCase
  alias Almanack.Scheduler
  alias Almanack.Officials.{Bios, Official, Term}
  alias Almanack.Sources.{Ballotpedia, GoogleCivicInfo, NGA, USIO, StaticFiles}

  setup_all do
    official =
      Official.new(
        first_name: "Sherrod",
        last_name: "Brown",
        gender: "male",
        religion: "Lutheran",
        terms: [
          %{
            start_date: "2015-01-03",
            role: "Supreme Burger",
            party: "of 5",
            state: "OH",
            address: %{
              line1: "123 Pocky Way",
              city: "Washington",
              state: "DC",
              zip: "20501"
            }
          },
          %{
            start_date: "2010-01-03",
            role: "Junior Burger"
          }
        ]
      )

    address = %NGA{
      line1: "1 Front Row",
      city: "Keats",
      state: "Hyperion",
      zip: "12345-6789"
    }

    {:ok,
     official: official,
     legislators: Fixtures.load("usio_legislators.json"),
     media: Fixtures.load("usio_social_media.json"),
     executives: Fixtures.load("usio_executives.json"),
     governors_addresses: [address],
     ballotpedia_mayors_html: Fixtures.load("ballotpedia_mayors_table.html"),
     static_officials: Fixtures.load("static_officials.json"),
     bio: Fixtures.load("wikipedia_bios.json") |> List.first(),
     civic_info: Fixtures.load("gci_representatives.json")}
  end

  describe "run_workflow/0" do
    test "loads officials from all sources and presists them", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      mock(USIO.API, :executives, context.executives)
      mock(NGA, :governors_addresses, context.governors_addresses)
      mock(GoogleCivicInfo.API, :representatives, context.civic_info)
      mock(Ballotpedia.API, :top_mayors_html, context.ballotpedia_mayors_html)
      mock(StaticFiles, :static_data, context.static_officials)
      mock(Bios.Wikipedia, :request_bio, context.bio)

      Scheduler.run_workflow()
      officials = Repo.all(Official)
      assert length(officials) == 8
    end

    test "loads officials from USIO and persists them to DB", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      mock(USIO.API, :executives, context.executives)
      mock(NGA, :governors_addresses, context.governors_addresses)
      mock(GoogleCivicInfo.API, :representatives, context.civic_info)
      mock(Ballotpedia.API, :top_mayors_html, context.ballotpedia_mayors_html)
      mock(StaticFiles, :static_data, context.static_officials)
      mock(Bios.Wikipedia, :request_bio, context.bio)

      Scheduler.run_workflow()
      officials = Repo.all(Official)
      assert Enum.find(officials, &(&1.first_name == "Maria"))
      sherrod = Enum.find(officials, &(&1.first_name == "Sherrod"))
      assert sherrod.data_source == "usio"
    end

    test "loads officials from GoogleCivicInfo and persists them to DB", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      mock(USIO.API, :executives, context.executives)
      mock(NGA, :governors_addresses, context.governors_addresses)
      mock(GoogleCivicInfo.API, :representatives, context.civic_info)
      mock(Ballotpedia.API, :top_mayors_html, context.ballotpedia_mayors_html)
      mock(StaticFiles, :static_data, context.static_officials)
      mock(Bios.Wikipedia, :request_bio, context.bio)

      Scheduler.run_workflow()
      officials = Repo.all(Official)
      bobeck = Enum.find(officials, &(&1.first_name == "Bobeck"))
      assert bobeck
      assert bobeck.data_source == "google_civic_info"
    end

    test "loads officials from Ballotpedia and persists them to DB", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      mock(USIO.API, :executives, context.executives)
      mock(NGA, :governors_addresses, context.governors_addresses)
      mock(GoogleCivicInfo.API, :representatives, context.civic_info)
      mock(Ballotpedia.API, :top_mayors_html, context.ballotpedia_mayors_html)
      mock(StaticFiles, :static_data, context.static_officials)
      mock(Bios.Wikipedia, :request_bio, context.bio)

      Scheduler.run_workflow()
      officials = Repo.all(Official)
      blasio = Enum.find(officials, &(&1.last_name == "Blasio"))
      assert blasio
      assert blasio.data_source == "ballotpedia"
    end

    test "profile_pics are inserted for officials without them", context do
      mock(USIO.API, :current_legislators, context.legislators)
      mock(USIO.API, :social_media, context.media)
      mock(USIO.API, :executives, context.executives)
      mock(NGA, :governors_addresses, context.governors_addresses)
      mock(GoogleCivicInfo.API, :representatives, context.civic_info)
      mock(Ballotpedia.API, :top_mayors_html, context.ballotpedia_mayors_html)
      mock(StaticFiles, :static_data, context.static_officials)
      mock(Bios.Wikipedia, :request_bio, context.bio)

      Scheduler.run_workflow()
      brown = Repo.one(from(o in Official, where: o.last_name == "Brown"))
      assert brown.profile_pic
    end
  end

  describe "enrich_officials/1" do
    test "downcases religion values", %{official: official} do
      [sherrod | [maria]] =
        [
          official,
          Official.change(official, first_name: "Maria", religion: "Roman Catholic")
        ]
        |> Scheduler.enrich_officials()

      assert sherrod.changes.religion == "lutheran"
      assert maria.changes.religion == "roman catholic"
    end
  end

  describe "persist_officials/1" do
    test "updates existing officials in DB", %{official: official} do
      assert Repo.insert!(official).gender == "male"

      [Official.change(official, gender: "female")]
      |> Scheduler.persist_officials()

      official = Repo.get_by(Official, mv_key: "sherrod-brown")
      assert official.gender == "female"
    end

    test "only modifies 'updated_at' and not 'created_at'", %{official: official} do
      old_time =
        NaiveDateTime.utc_now()
        |> NaiveDateTime.add(-1)
        |> NaiveDateTime.truncate(:second)

      old_official =
        Official.change(official, created_at: old_time, updated_at: old_time)
        |> Repo.insert!()

      Scheduler.persist_officials([official])
      official = Repo.get_by(Official, mv_key: "sherrod-brown")
      assert old_official.created_at == official.created_at
      refute old_official.updated_at == official.updated_at
    end

    test "persists terms for officials", %{official: official} do
      Scheduler.persist_officials([official])

      sherrod =
        Repo.get_by(Official, mv_key: "sherrod-brown")
        |> Repo.preload(:terms)

      assert length(sherrod.terms) == 2
    end

    test "official terms have the proper values", %{official: official} do
      Scheduler.persist_officials([official])

      term =
        from(t in Term,
          join: o in Official,
          where: t.official_id == o.id and o.mv_key == "sherrod-brown",
          order_by: [desc: t.start_date],
          limit: 1
        )
        |> Repo.one()

      {:ok, date} = Date.new(2015, 1, 3)
      assert term.start_date == date
      assert term.role == "Supreme Burger"
      assert term.address["line1"] == "123 Pocky Way"
      assert term.address["city"] == "Washington"
      assert term.address["state"] == "DC"
      assert term.address["zip"] == "20501"
      assert term.party == "of 5"
      assert term.state == "OH"
    end

    test "official terms are not duplicated", %{official: official} do
      Scheduler.persist_officials([official])
      Scheduler.persist_officials([official])

      sherrod =
        Repo.get_by(Official, mv_key: "sherrod-brown")
        |> Repo.preload(:terms)

      assert length(sherrod.terms) == 2
    end
  end
end
