defmodule KineticEcto.TestRepo do
  @moduledoc false

  use Ecto.Repo, otp_app: :kinetic_ecto, adapter: Ecto.Adapters.SQLite3
  use KineticEcto.Transact
end
