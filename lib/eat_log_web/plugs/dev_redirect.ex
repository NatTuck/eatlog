defmodule EatLogWeb.Plugs.DevRedirect do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if Mix.env() == :dev and conn.request_path == "/" and conn.method == "GET" do
      conn
      |> put_resp_header("location", "http://localhost:3000")
      |> send_resp(302, "Redirecting to Vite...")
      |> halt()
    else
      conn
    end
  end
end
