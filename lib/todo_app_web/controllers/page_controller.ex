defmodule TodoAppWeb.PageController do
  use TodoAppWeb, :controller
  alias TodoApp.TaskRepo

  def index(conn, _) do
    changeset = TaskRepo.build_task()

    task_list =
      TaskRepo.get_all_tasks()
      |> Enum.reverse()

    render(conn, "index.html", changeset: changeset, task_list: task_list)
  end

  def create(conn, %{"addtask" => params}) do
    task_list = TaskRepo.get_all_tasks()

    case TaskRepo.insert_new_task(params) do
      {:ok, _changeset} ->
        conn
        |> redirect(to: "/")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Some error occured")
        |> render("index.html", changeset: changeset, task_list: task_list)
    end
  end

  def toggle(conn, %{"id" => id}) do
    case TaskRepo.togglestatus(id) do
      {:ok, _data} ->
        conn
        |> redirect(to: "/")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Some error occured")
        |> render("index.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    case TaskRepo.delete_todo(id) do
      {:ok, _data} ->
        conn
        |> redirect(to: "/")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Some error occured!")
        |> render("index.html", changeset: changeset)
    end
  end
end
