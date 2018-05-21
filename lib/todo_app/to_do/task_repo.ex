defmodule TodoApp.TaskRepo do
  alias TodoApp.Repo
  alias TodoApp.ToDo.Task

  def get_all_tasks do
    Repo.all(Task)
    |> Enum.sort()
  end

  def build_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
  end

  def insert_new_task(task) do
    task
    |> build_task()
    |> Repo.insert()
  end

  def edit_todo(item, attrs) do
    item
    |> Task.changeset(attrs)
    |> Repo.update!()
  end

  def togglestatus(id) do
    my_task = Repo.get!(Task, id)
    my_task
    |> Ecto.Changeset.change(complete: !my_task.complete)
    |> Repo.update()
  end

  def delete_todo(id) do
    Repo.get!(Task, id)
    |> Repo.delete()
  end

end
