defmodule WebChat.Repo.Migrations.CreateChatbotMessages do
  use Ecto.Migration

  def change do
    create table(:chatbot_messages) do
      add :role, :string
      add :content, :text
      add :conversation_id, references(:chatbot_conversations, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:chatbot_messages, [:conversation_id])
  end
end
