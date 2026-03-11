defmodule KumaSanKanji.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        KumaSanKanji.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:kuma_san_kanji, :token_signing_secret)
  end
end
