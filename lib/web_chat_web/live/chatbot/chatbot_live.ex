defmodule WebChatWeb.ChatbotLive do
  use Phoenix.LiveView, container: {:div, [class: "fixed right-0 bottom-0 mr-4"]}

  import WebChatWeb.CoreComponents

  alias Phoenix.LiveView.AsyncResult
  alias Phoenix.LiveView.JS

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col flex-grow bg-white border shadow rounded-t-lg overflow-hidden">
      <div
        id="messages"
        class="flex flex-col flex-grow max-w-xs p-4 overflow-auto max-h-[50vh]"
        phx-update="stream"
      >
        <div
          :for={{dom_id, message} <- @streams.messages}
          id={dom_id}
          phx-mounted={JS.dispatch("scrollIntoView", to: "##{dom_id}")}
        >
          <div
            :if={dom_id == "messages-1"}
            class="flex w-full mt-2 space-x-3 max-w-xs ml-auto"
            id="initial-message"
          >
            <img
              class="flex-shrink-0 h-10 w-10 rounded-full"
              src="https://lsk-public.b-cdn.net/demo_chatbot.webp"
              alt=""
            />
            <div class="w-full">
              <div class="bg-gray-300 p-3 rounded-r-lg rounded-bl-lg">
                <p class="text-sm">Hi. I am here to answer questions about Elixir.</p>
              </div>
              <span class="text-xs text-gray-500 leading-none">Now</span>
            </div>
          </div>

          <div
            :if={message.role == "user"}
            class="flex w-full mt-2 space-x-3 max-w-xs ml-auto justify-end"
          >
            <div class="w-full">
              <div class="bg-blue-600 text-white p-3 rounded-l-lg rounded-br-lg">
                <p class="text-sm">{message.content}</p>
              </div>
              <span class="text-xs text-gray-500 leading-none">Now</span>
            </div>
            <img
              class="flex-shrink-0 h-10 w-10 rounded-full bg-gray-300"
              src="https://avatars.githubusercontent.com/u/456260?v=4"
              alt=""
            />
          </div>

          <div :if={message.role == "assistant"} class="flex w-full mt-2 space-x-3 max-w-xs ml-auto">
            <img
              class="flex-shrink-0 h-10 w-10 rounded-full bg-gray-300"
              src="https://lsk-public.b-cdn.net/demo_chatbot.webp"
              alt=""
            />
            <div class="w-full">
              <div class="bg-gray-300 p-3 rounded-r-lg rounded-bl-lg">
                <p class="text-sm">{message.content}</p>
              </div>
              <span class="text-xs text-gray-500 leading-none">Now</span>
            </div>
          </div>
        </div>
      </div>

      <div class="bg-gray-300 p-4">
        <%= if @state.loading do %>
          <.input type="text" name="dummy" value="" disabled="disabled" placeholder="Loading..." />
        <% else %>
          <.live_component
            module={WebChatWeb.Chatbot.MessageFormComponent}
            id="new-message"
            conversation={@conversation}
          />
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    conversation = WebChat.Chatbot.get_or_create_active_conversation(%{session_id: "User:1"})

    {
      :ok,
      socket
      |> assign(:state, %AsyncResult{})
      |> assign(:conversation, conversation)
      |> stream(:messages, WebChat.Chatbot.list_messages(conversation))
    }
  end

  @impl true
  def handle_info({WebChatWeb.Chatbot.MessageFormComponent, {:saved, message}}, socket) do
    conversation = socket.assigns.conversation

    {
      :noreply,
      socket
      |> stream_insert(:messages, message)
      |> assign(:state, AsyncResult.loading())
      |> start_async(:generating, fn -> WebChat.Chatbot.generate_response(conversation) end)
    }
  end

  @impl true
  def handle_async(:generating, {:ok, {:ok, message}}, socket) do
    {
      :noreply,
      socket
      |> assign(:state, AsyncResult.ok(socket.assigns.state, :ok))
      |> stream_insert(:messages, message)
    }
  end

  @impl true
  def handle_async(:generating, _error, socket) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix()

    message = %{
      id: "error-#{timestamp}",
      role: "assistant",
      content: "An error occurred. Please try again"
    }

    {:noreply, stream_insert(socket, :messages, message)}
  end
end
