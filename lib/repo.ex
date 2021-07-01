defmodule Twenty.Repo do
  use Ecto.Repo,
    otp_app: :twenty,
    adapter: Ecto.Adapters.Postgres
end
