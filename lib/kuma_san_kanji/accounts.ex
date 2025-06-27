defmodule KumaSanKanji.Accounts do
  use Ash.Domain,
    otp_app: :kuma_san_kanji

  resources do
    resource KumaSanKanji.Accounts.Token
    resource KumaSanKanji.Accounts.User do
      define :list_users, action: :read
      define :get_user_by_id, action: :read, get_by: [:id]
      define :toggle_user_dev_mode, action: :toggle_dev_mode, args: [:enabled]
    end
  end
end
