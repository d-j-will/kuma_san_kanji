defmodule KumaSanKanji.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use KumaSanKanji.DataCase, async: true`, although
  this option is not available when using SQLite.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias KumaSanKanji.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import KumaSanKanji.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(KumaSanKanji.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(KumaSanKanji.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user_for_test(%{email: "invalid"})
      assert "must have @ symbol" in errors_on(changeset).email
      assert %{email: ["must have @ symbol"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
