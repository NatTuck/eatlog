import Config

config :eat_log, EatLog.Repo,
  database: Path.expand("../db/eat_log_dev.db", __DIR__),
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :eat_log, EatLogWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "LAFTxSniOSqSc0gURRQU1qLqWXWN686G7EHNkwTYCCO0ka7NGehNU72vLoakSUro"

config :eat_log, EatLogWeb.Endpoint,
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/eat_log_web/router\.ex$",
      ~r"lib/eat_log_web/controllers/.*\.(ex)$"
    ]
  ]

config :eat_log, dev_routes: true

config :logger, :default_formatter, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :swoosh, :api_client, false
