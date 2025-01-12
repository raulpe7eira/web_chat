defmodule WebChatWeb.Chatbot.MessageFormComponent do
  use WebChatWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} id="message-form" phx-target={@myself} phx-change="change" phx-submit="save">
        <.input field={@form[:content]} value={@content} type="text" placeholder="Type your message" />
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    changeset = WebChat.Chatbot.change_message(%WebChat.Chatbot.Message{})

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:content, "")
      |> assign_form(changeset)
    }
  end

  @impl true
  def handle_event("change", %{"message" => %{"content" => content}}, socket) do
    {:noreply, assign(socket, :content, content)}
  end

  @impl true
  def handle_event("save", %{"message" => message_params}, socket) do
    message_params = Map.put(message_params, "role", "user")

    case WebChat.Chatbot.create_message(socket.assigns.conversation, message_params) do
      {:ok, message} ->
        notify_parent({:saved, message})
        {:noreply, assign(socket, :content, "")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(message) do
    send(self(), {__MODULE__, message})
  end
end
