defmodule KumaSanKanji.Repo.Migrations.AddDevModeAndAdminToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:dev_mode_enabled, :boolean, null: false, default: false)
      add(:admin, :boolean, null: false, default: false)
    end
  end
end
