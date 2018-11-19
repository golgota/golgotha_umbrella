defmodule BlessdWeb.UserController do
  use BlessdWeb, :controller

  alias Blessd.Accounts
  alias BlessdWeb.ConfirmationMailer

  def index(conn, _params) do
    users = Accounts.list_users(conn.assigns.current_user)
    render(conn, "index.html", users: users)
  end

  def edit(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    changeset =
      id
      |> Accounts.get_user!(user)
      |> Accounts.change_user(user)

    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    current_user = conn.assigns.current_user
    user = Accounts.get_user!(id, current_user)

    with {:ok, new_user} <- Accounts.update_user(user, user_params, current_user),
         {:ok, _} = confirm_email_change(user, new_user) do
      conn
      |> put_flash(:info, gettext("User updated successfully."))
      |> redirect(to: Routes.user_path(conn, :index, current_user.church.identifier))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  defp confirm_email_change(%{email: email}, %{email: email} = user), do: {:ok, user}
  defp confirm_email_change(_, user), do: ConfirmationMailer.send(user)

  def delete(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    user = Accounts.get_user!(id, current_user)
    {:ok, _user} = Accounts.delete_user(user, current_user)

    conn
    |> put_flash(:info, gettext("User deleted successfully."))
    |> redirect(to: Routes.user_path(conn, :index, current_user.church.identifier))
  end
end
