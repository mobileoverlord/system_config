defmodule SystemConfig.PageController do
  use SystemConfig.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
