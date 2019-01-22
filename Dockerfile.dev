FROM elixir:1.7.4

RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /usr/src/app
COPY . .

RUN rm -rf deps/* && \
    mix deps.get

CMD ["elixir", "-S", "mix", "run", "--no-halt"]
