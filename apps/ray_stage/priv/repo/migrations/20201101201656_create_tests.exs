defmodule RayStage.Repo.Migrations.CreateTests do
  use Ecto.Migration

  def change do
    create table(:tests) do

      timestamps()
    end

  end
end
