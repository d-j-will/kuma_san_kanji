defmodule KumaSanKanjiWeb.HealthController do
  use KumaSanKanjiWeb, :controller

  @doc """
  Simple health check endpoint that verifies database connectivity.
  Returns 200 OK with JSON if healthy, 503 Service Unavailable otherwise.
  """
  def check(conn, _params) do
    case check_database() do
      :ok ->
        conn
        |> put_status(:ok)
        |> json(%{status: "healthy", database: "connected"})

      {:error, reason} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{status: "unhealthy", database: "disconnected", error: to_string(reason)})
    end
  end

  defp check_database do
    # Simple query to check DB connectivity
    try do
      case Ecto.Adapters.SQL.query(KumaSanKanji.Repo, "SELECT 1", []) do
        {:ok, %{rows: [[1]]}} -> :ok
        error -> {:error, "Unexpected DB response: #{inspect(error)}"}
      end
    rescue
      e -> {:error, Exception.message(e)}
    end
  end
end
