defmodule BulmalabWeb.PageController do
  use BulmalabWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
