defmodule Classlab.Classroom.ChatMessageController do
  @moduledoc false
  alias Classlab.{ChatMessage}
  use Classlab.Web, :controller

  plug :restrict_roles, [1, 2] when action in [:update, :edit, :delete]
  plug :scrub_params, "chat_message" when action in [:create, :update]

  def index(conn, _params) do
    event = current_event(conn)
    chat_messages =
      event
      |> assoc(:chat_messages)
      |> Repo.all()
      |> Repo.preload(:user)

    changeset =
      event
      |> build_assoc(:chat_messages, %{user: current_user(conn)})
      |> ChatMessage.changeset()

    render(conn, "index.html", changeset: changeset, chat_messages: chat_messages, event: event)
  end

  def new(conn, _params) do
    event = current_event(conn)
    changeset =
      event
      |> build_assoc(:chat_messages, %{user: current_user(conn)})
      |> ChatMessage.changeset()

    render(conn, "new.html", changeset: changeset, event: event)
  end

  def create(conn, %{"chat_message" => chat_message_params}) do
    event = current_event(conn)
    changeset =
      event
      |> build_assoc(:chat_messages, %{user: current_user(conn)})
      |> ChatMessage.changeset(chat_message_params)

    case Repo.insert(changeset) do
      {:ok, _chat_message} ->
        page_reload_broadcast!([:event, event.id, :chat_message, :create])

        redirect(conn, to: "#{classroom_chat_message_path(conn, :index, event)}#last_message")
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, event: event)
    end
  end

  def edit(conn, %{"id" => id}) do
    event = current_event(conn)
    chat_message =
      event
      |> assoc(:chat_messages)
      |> Repo.get!(id)

    changeset = ChatMessage.changeset(chat_message)
    render(conn, "edit.html", chat_message: chat_message, changeset: changeset, event: event)
  end

  def update(conn, %{"id" => id, "chat_message" => chat_message_params}) do
    event = current_event(conn)
    chat_message =
      event
      |> assoc(:chat_messages)
      |> Repo.get!(id)

    changeset = ChatMessage.changeset(chat_message, chat_message_params)

    case Repo.update(changeset) do
      {:ok, _chat_message} ->

        page_reload_broadcast!([:event, event.id, :chat_message, :update])

        conn
        |> put_flash(:info, "Chat message updated successfully.")
        |> redirect(to: "#{classroom_chat_message_path(conn, :index, event)}#last_message")
      {:error, changeset} ->
        render(conn, "edit.html", chat_message: chat_message, changeset: changeset, event: event)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = current_event(conn)
    chat_message =
      event
      |> assoc(:chat_messages)
      |> Repo.get!(id)

    Repo.delete!(chat_message)

    page_reload_broadcast!([:event, event.id, :chat_message, :delete])

    conn
    |> put_flash(:info, "Chat message deleted successfully.")
    |> redirect(to: "#{classroom_chat_message_path(conn, :index, event)}#last_message")
  end

  # Private methods
end
