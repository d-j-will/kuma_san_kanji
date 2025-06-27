Mimic.copy(AshAuthentication.Plug.Helpers)
Mimic.copy(KumaSanKanjiWeb.UserLiveAuth)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(KumaSanKanji.Repo, :manual)
