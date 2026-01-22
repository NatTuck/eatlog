defmodule EatLog.Repo do
  use Ecto.Repo,
    otp_app: :eat_log,
    adapter: Ecto.Adapters.SQLite3
end
