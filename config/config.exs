use Mix.Config

config :brain,
  memory_path: "priv/memories/"

config :logger,
  level: :debug

import_config "config.#{Mix.env()}.exs"
