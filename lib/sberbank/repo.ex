defmodule Sberbank.Repo do
  use Ecto.Repo,
    otp_app: :sberbank,
    adapter: Ecto.Adapters.Postgres
end
