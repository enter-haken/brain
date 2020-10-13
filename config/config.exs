use Mix.Config

config :brain,
  memory_paths: ["~/src/enter-haken/memories/memories/"]

config :logger,
  level: :debug

import_config "config.#{Mix.env()}.exs"
