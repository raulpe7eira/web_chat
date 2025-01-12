defmodule WebChat.Repo do
  use Ecto.Repo,
    otp_app: :web_chat,
    adapter: Ecto.Adapters.Postgres
end
