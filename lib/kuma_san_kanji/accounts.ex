defmodule KumaSanKanji.Accounts do
  use Ash.Domain,
    otp_app: :kuma_san_kanji

  resources do
    resource KumaSanKanji.Accounts.Token
    resource KumaSanKanji.Accounts.User
  end
end
