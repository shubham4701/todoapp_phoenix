defmodule TodoApp.ToDo.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :complete, :boolean, default: false
    field :task_name, :string

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:task_name, :complete])
    |> validate_required([:task_name])
  end
end
