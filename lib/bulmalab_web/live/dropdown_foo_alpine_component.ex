defmodule BulmalabWeb.DropdownFooAlpineLiveComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  def render(assigns) do
    # IO.inspect(assigns, label: :DDDD, limit: :infinity)
    # <select class="ui search dropdown">
    # <option value="">State</option>
    # <div class="dropdown <%= if @active, do: "is-active" %>" id="dropdown-<%= @id %>">
    # <%= if @active do %>
    # <!-- click layer -->
    # <div style="opacity: 1!important; position: fixed; z-index: 1; left: 0; top: 0; width: 100%; height: 100%;" phx-click="deactivate" phx-target="#dropdown-<%= @id %>"></div>
    # <% end %>
    # <a href="#" class="dropdown-item" phx-click="select", phx-value-item="<%= item %>" phx-target="#dropdown-<%= @id %>">
    ~L"""
    <div class="ui selection dropdown" :class="{ 'active visible': open }" x-data="{ open: false }" @click="open = !open" @keydown.escape="open = false" @click.away="open = false">
      <i class="dropdown icon"></i>
      <div class="text">Menu</div>
      <div class="menu" :class="{ 'transition visible': open }" >
        <%= for item <- @dropdown do %>
        <div class="item" phx-click="select", phx-value-item="<%= item %>" phx-target="<%= @myself %>">
          <%= item %>
        </div>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  # def update(%{dropdown: dropdown, id: id}, socket) do
  #   IO.inspect(binding(), label: "DROPDOWN UPDATE")
  #   {:ok, assign(socket, dropdown: dropdown, id: id)}
  # end

  def handle_event("select", %{"item" => item}, socket) do
    IO.inspect(binding(), label: "SELECT", limit: :infinity)
    send(self(), {:dropdown, socket.assigns.id, item})
    {:noreply, socket}
  end

  def handle_event(a, b, socket) do
    IO.inspect(binding(), label: "UNKNOWN DROPDOWN EVENT", limit: :infinity)
    {:noreply, socket}
  end

  ## Privates
end
