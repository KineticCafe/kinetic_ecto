defmodule KineticEcto.TestMigration do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:images) do
      add :url, :string
      add :color, :string
      add :rgba, :map
      add :hsla, :map
    end
  end
end
