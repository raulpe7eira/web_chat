defmodule WebChat.Repo.Migrations.CreateChatbotConversations do
  use Ecto.Migration

  def change do
    create table(:chatbot_conversations) do
      add :session_id, :string
      add :resolved_at, :naive_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:chatbot_conversations, [:session_id], where: "resolved_at IS NULL")
  end
end
