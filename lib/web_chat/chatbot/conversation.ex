defmodule WebChat.Chatbot.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  alias WebChat.Chatbot.Message

  schema "chatbot_conversations" do
    field :session_id, :string
    field :resolved_at, :naive_datetime

    has_many :messages, Message, preload_order: [desc: :id]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:session_id, :resolved_at])
    |> validate_required([:session_id])
  end
end
