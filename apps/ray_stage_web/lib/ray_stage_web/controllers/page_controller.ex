defmodule RayStageWeb.PageController do
  use RayStageWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
