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

  def secret_for(
        [:authentication, :strategies, :auth0, :client_id],
        KumaSanKanji.Accounts.User,
        _opts,
        _meth
      ) do
    get_config(:client_id)
  end

  def secret_for(
        [:authentication, :strategies, :auth0, :redirect_uri],
        KumaSanKanji.Accounts.User,
        _opts,
        _meth
      ) do
    get_config(:redirect_uri)
  end

  def secret_for(
        [:authentication, :strategies, :auth0, :client_secret],
        KumaSanKanji.Accounts.User,
        _opts,
        _meth
      ) do
    get_config(:client_secret)
  end

  def secret_for(
        [:authentication, :strategies, :auth0, :base_url],
        KumaSanKanji.Accounts.User,
        _opts,
        _meth
      ) do
    get_config(:base_url)
  end

  defp get_config(key) do
    :kuma_san_kanji
    |> Application.fetch_env!(:auth0)
    |> Keyword.fetch!(key)
    |> then(&{:ok, &1})
  end
end
