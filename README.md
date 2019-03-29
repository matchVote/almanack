# Almanack

Collects and aggregates data for matchVote Officials

### Development

    $ docker-compose build
    $ docker-compose up

### Testing

    $ mix test

### TODO

- Load custom files
  - "2015_HighProfile.yml"
- Load image urls
  - /db/data/2015_SenatorProfileImageURLs.txt
  - /db/data/2017_CongressProfileImageURLs.txt
  - /db/data/2017_GovernorProfileImageURLs.txt
  - /db/data/2017_MayorProfileImageURLs.txt
  - slug: "george-bynum", url: "2017/mayors/GT_Bynum.jpeg"
  - slug: "tomas-regalado", url: "2017/mayors/Tomas_Regalado.jpeg"
  - slug: "john-bel-edwards", url: "2015/governors/John_Bel_Edwards.jpeg"
  - slug: "mario-diaz-balart", url: "2015/congress/Mario_Diaz_Balart.jpeg"
  - slug: "ileana-ros-lehtinen", url: "2015/congress/Ileana_Ros_Lehtinen.jpeg"
  - slug: "lucille-roybal-allard", url: "2015/congress/Lucille_Roybal_Allard.jpeg"
  - slug: "beto-o?rourke", url: "2015/congress/Beto_ORourke.jpeg"
  - slug: "gk-butterfield", url: "2015/congress/G_K_Butterfield.jpeg"
  - slug: "earl-ray-tomblin", url: "2015/governors/Earl_Ray_Tomblin.jpeg"
- Load wikipedia bios
- Name recognition

### Refactor
- Remove enrichment step from Scheduler and use those functions directly in the sources.
- Simplify Sources; call `map_to_officials` last to avoid passing extra data