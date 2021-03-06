defmodule Classlab.Classroom.MembershipController do
  @moduledoc false
  alias Classlab.{Invitation, Membership, Role}
  alias Ecto.Query
  use Classlab.Web, :controller
  use Classlab.ErrorRescue, from: Ecto.NoResultsError, redirect_to: &page_path(&1, :index)

   plug :restrict_roles, [1, 2] when action in [:update]

  def index(conn, _params) do
    event = current_event(conn)
    memberships =
      event
      |> assoc(:memberships)
      |> Membership.not_as_role(1)
      |> Query.order_by(:id)
      |> Repo.all()
      |> Repo.preload([:user, :role, :event])

    completed_invitations =
      Invitation
      |> Invitation.for_event(event)
      |> Invitation.completed()
      |> Repo.all()
      |> Repo.preload(:role)

    open_invitations =
      Invitation
      |> Invitation.for_event(event)
      |> Invitation.not_completed()
      |> Repo.all()
      |> Repo.preload(:role)

    invitation_changeset =
      event
      |> build_assoc(:invitations)
      |> Invitation.changeset()

    roles =
      Role
      |> Query.where([r], r.id > 1)
      |> Query.order_by(desc: :id)
      |> Repo.all()

    render(
      conn,
      "index.html",
      event: event,
      invitation_changeset: invitation_changeset,
      memberships: memberships,
      completed_invitations: completed_invitations,
      open_invitations: open_invitations,
      roles: roles
    )
  end

  def update(conn, %{"id" => id, "role_id" => role_id}) do
    event = current_event(conn)
    {role_id, _} = Integer.parse(role_id)

    membership =
      event
      |> assoc(:memberships)
      |> Repo.get!(id)

    if role_id == 2 || role_id == 3 do
      changeset = Membership.changeset(membership, %{role_id: role_id})
      Repo.update!(changeset)
    end

    conn
    |> put_flash(:info, "Membership updated successfully.")
    |> redirect(to: classroom_membership_path(conn, :index, event))
  end

  def delete(conn, %{"id" => id}) do
    event = current_event(conn)

    membership =
      event
      |> assoc(:memberships)
      |> Repo.get!(id)
      |> Repo.preload(:user)

    redirect_path =
      if has_permission?(current_memberships(conn), [1, 2]) do
        classroom_membership_path(conn, :index, event)
      else
        account_membership_path(conn, :index)
      end

    if has_permission?(current_memberships(conn), [1, 2]) || membership.user.id == current_user(conn).id do
      Repo.delete!(membership)

      invitation =
        Invitation
        |> Query.where(email: ^membership.user.email)
        |> Query.where(event_id: ^membership.event_id)
        |> Repo.one()

      if invitation do
        Repo.delete!(invitation)
      end

      conn
      |> put_flash(:info, "Membership deleted successfully.")
      |> redirect(to: redirect_path)
    else
      conn
      |> put_flash(:error, "Permission denied.")
      |> redirect(to: classroom_membership_path(conn, :index, event))
    end

  end

  # Private methods
end
