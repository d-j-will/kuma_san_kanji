Mimic.copy(AshAuthentication.Plug.Helpers)
Mimic.copy(KumaSanKanjiWeb.UserLiveAuth)

{:ok, _} = Application.ensure_all_started(:credo)

exclude = if System.find_executable("mecab"), do: [], else: [:mecab]
ExUnit.start(exclude: exclude)
Ecto.Adapters.SQL.Sandbox.mode(KumaSanKanji.Repo, :manual)
