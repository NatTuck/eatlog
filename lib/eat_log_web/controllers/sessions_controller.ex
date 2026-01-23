defmodule EatLogWeb.SessionsController do
  use EatLogWeb, :controller

  alias EatLog.Users

  def create(conn, %{"login" => login, "password" => password}) do
    case Users.authenticate(login, password) do
      {:ok, user} ->
        expires_at = DateTime.utc_now() |> DateTime.add(7_776_000) |> DateTime.to_iso8601()
        token = Phoenix.Token.sign(EatLogWeb.Endpoint, "user auth", user.id, max_age: 7_776_000)

        conn
        |> put_status(:created)
        |> json(%{user_id: user.id, login: user.login, expires: expires_at, token: token})

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "invalid_credentials"})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "missing_login_or_password"})
  end
end
