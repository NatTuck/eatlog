defmodule EatLogWeb.PageController do
  use EatLogWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
