defmodule WebChat.Chatbot.Chat do
  use Ecto.Schema
  use Instructor.Validator

  @primary_key false
  embedded_schema do
    field :content, :string
  end

  @impl true
  def validate_changeset(changeset) do
    Ecto.Changeset.validate_required(changeset, [:content])
  end

  def call(messages) do
    Instructor.chat_completion(
      model: "gpt-4o-mini",
      response_model: __MODULE__,
      max_retries: 3,
      messages:
        Enum.concat(messages, [
          %{
            role: "system",
            content: """
            You are a chatbot that only answers questions about the programming language Elixir.
            Answer short with just a 1-3 sentences.
            If the question is about another programming language, make a joke about it.
            If the question is about something else, answer something like:
            "I don't know, its not my cup of tea" or "I have no opinion about that topic".
            """
          }
        ])
    )
  end
end
