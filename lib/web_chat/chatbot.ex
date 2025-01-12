defmodule WebChat.Chatbot do
  import Ecto.Query, warn: false

  alias WebChat.Chatbot.Chat
  alias WebChat.Chatbot.Conversation
  alias WebChat.Chatbot.Message
  alias WebChat.Repo

  def get_or_create_active_conversation(%{session_id: session_id} = attrs) do
    session_id = to_string(session_id)

    query =
      from c in Conversation,
        where: c.session_id == ^session_id and is_nil(c.resolved_at),
        select: c

    case Repo.one(query) do
      nil ->
        %Conversation{}
        |> Conversation.changeset(attrs)
        |> Repo.insert!(returning: true)

      active_conversation ->
        active_conversation
    end
  end

  def list_messages(conversation) do
    query =
      from m in Message,
        where: m.conversation_id == ^conversation.id,
        order_by: [asc: m.id]

    Repo.all(query)
  end

  def create_message(conversation, attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:conversation, conversation)
    |> Repo.insert()
  end

  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  def generate_response(conversation) do
    conversation
    |> list_messages()
    |> Enum.map(fn message -> Map.take(message, [:role, :content]) end)
    |> Chat.call()
    |> case do
      {:ok, %{content: content}} ->
        create_message(conversation, %{content: content, role: "assistant"})

      error ->
        error
    end
  end
end
