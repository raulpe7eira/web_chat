defmodule WebChat.Chatbot.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias WebChat.Chatbot.Conversation

  schema "chatbot_messages" do
    field :role, :string
    field :content, :string

    belongs_to :conversation, Conversation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:role, :content])
    |> validate_required([:role, :content])
  end
end
