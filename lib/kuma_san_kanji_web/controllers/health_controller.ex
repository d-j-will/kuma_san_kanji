defmodule KumaSanKanjiWeb.HealthController do
  use KumaSanKanjiWeb, :controller

  def index(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
