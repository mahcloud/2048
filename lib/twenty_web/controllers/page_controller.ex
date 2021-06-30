defmodule TwentyWeb.PageController do
  use TwentyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
