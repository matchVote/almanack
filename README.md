# Almanack

Collects and aggregates data for matchVote Officials

### Development

    $ docker-compose build
    $ docker-compose up

### Testing

    $ mix test

### TODO

- Name recognition

### Refactor
- Remove enrichment step from Scheduler and use those functions directly in the sources.
- Simplify Sources; call `map_to_officials` last to avoid passing extra data
