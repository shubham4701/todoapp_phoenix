defmodule TodoApp.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :task_name, :string
      add :complete, :boolean, default: false

      timestamps(default: fragment("now()"))
    end

  end
end
