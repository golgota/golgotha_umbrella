defmodule BlessdWeb.UserController do
  use BlessdWeb, :controller

  alias Blessd.Accounts
  alias BlessdWeb.ConfirmationMailer

  def index(conn, _params) do
    with {:ok, users} <- Accounts.list_users(conn.assigns.current_user) do
      render(conn, "index.html", users: users)
    end
  end

  def edit(conn, %{"id" => id}) do
    with current_user = conn.assigns.current_user,
         {:ok, changeset} <- Accounts.edit_user_changeset(id, current_user) do
      render(conn, "edit.html", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    with current_user = conn.assigns.current_user,
         {:ok, user} <- Accounts.update_user(id, user_params, current_user),
         :ok = send_confirmation(user) do
      conn
      |> put_flash(:info, gettext("User updated successfully."))
      |> redirect(to: Routes.user_path(conn, :index, current_user.church.slug))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp send_confirmation(%{confirmed_at: nil} = user), do: ConfirmationMailer.send(user)
  defp send_confirmation(_), do: :ok

  def delete(conn, %{"id" => id}) do
    with current_user = conn.assigns.current_user,
         {:ok, _user} = Accounts.delete_user(id, current_user) do
      conn
      |> put_flash(:info, gettext("User deleted successfully."))
      |> redirect(to: Routes.user_path(conn, :index, current_user.church.slug))
    end
  end
end
