defmodule EatLogWeb.Plugs.Auth do
  import Plug.Conn
  import Phoenix.Controller

  alias EatLog.Repo
  alias EatLog.Users.User

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user_id} <- Phoenix.Token.verify(EatLogWeb.Endpoint, "user auth", token),
         %User{} = user <- Repo.get(User, user_id) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "invalid_token"})
        |> halt()
    end
  end
end
