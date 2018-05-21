defmodule TodoAppWeb.TodoController do
  use TodoAppWeb, :controller
  alias TodoApp.TaskRepo

  def create_task(conn, params) do
    params
    |> TaskRepo.insert_new_task()
    conn
    |> json(TaskRepo.get_all_tasks())
  end

  def get_users(conn, _) do
    conn
    |> json(TaskRepo.get_all_tasks())
  end

  def togglestatus(conn, %{"id" => id}) do
    TaskRepo.togglestatus(id)
    conn
    |> get_users(%{})
  end

  def delete(conn, %{"id" => id}) do
    TaskRepo.delete_todo(id)
    conn
    |> get_users(%{})
  end

end
