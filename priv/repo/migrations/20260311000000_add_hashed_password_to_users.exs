defmodule KumaSanKanji.Repo.Migrations.AddHashedPasswordToUsers do
  @moduledoc """
  Re-adds hashed_password column for password-based authentication.
  Previously dropped when migrating to Auth0 (20250903214437).
  """
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :hashed_password, :text
    end
  end
end
