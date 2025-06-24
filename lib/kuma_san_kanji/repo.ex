defmodule KumaSanKanji.Repo do
  use AshPostgres.Repo, otp_app: :kuma_san_kanji

  # This repo will be used by resources with AshPostgres.DataLayer

  @impl true
  def installed_extensions do
    # Add extensions here, and the migration generator will install them.
    ["ash-functions", "uuid-ossp", "pg_trgm", "citext"]
  end

  @impl true
  def min_pg_version do
    %Version{major: 14, minor: 0, patch: 0}
  end
end
