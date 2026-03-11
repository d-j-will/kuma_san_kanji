Mimic.copy(AshAuthentication.Plug.Helpers)
Mimic.copy(KumaSanKanjiWeb.UserLiveAuth)

exclude = if System.find_executable("mecab"), do: [], else: [:mecab]
ExUnit.start(exclude: exclude)
Ecto.Adapters.SQL.Sandbox.mode(KumaSanKanji.Repo, :manual)
