defmodule BulmalabWeb.DropdownFooLiveComponent do
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
    <div>
    <div class="ui selection dropdown <%= if @active, do: "active visible"%>" style="z-index: 2;" phx-click="activate" phx-target="<%= @myself %>">
      <i class="dropdown icon"></i>
      <div class="text">Menu</div>
      <div class="menu <%= if @active, do: "transition visible" %>">
        <%= for item <- @dropdown do %>
        <div class="item" phx-click="select", phx-value-item="<%= item %>" phx-target="<%= @myself %>">
          <%= item %>
        </div>
        <% end %>
      </div>
    </div>
    <%= if @active do %>
    <!-- click layer -->
    <div style="opacity: 1!important; position: fixed; z-index: 1; left: 0; top: 0; width: 100%; height: 100%;" phx-click="deactivate" phx-target="<%= @myself %>"></div>
    <% end %>
    </div>
    """
  end

  def mount(socket) do
    # IO.inspect(binding(), label: :mount)
    init = [
      active: false
      # selected: nil
    ]

    {:ok, assign(socket, init)}
  end

  # def update(%{dropdown: dropdown, id: id}, socket) do
  #   IO.inspect(binding(), label: "DROPDOWN UPDATE")
  #   {:ok, assign(socket, dropdown: dropdown, id: id)}
  # end

  def handle_event("activate", _, socket) do
    IO.inspect(binding(), label: "ACTIVATE", limit: :infinity)
    {:noreply, assign(socket, active: :erlang.xor(socket.assigns.active, true))}
  end

  def handle_event("deactivate", _, socket) do
    IO.inspect(binding(), label: "DEACTIVATE", limit: :infinity)
    {:noreply, assign(socket, active: false)}
  end

  def handle_event("select", %{"item" => item}, socket) do
    IO.inspect(binding(), label: "SELECT", limit: :infinity)
    send(self(), {:dropdown, socket.assigns.id, item})
    {:noreply, assign(socket, active: false)}
  end

  def handle_event(a, b, socket) do
    IO.inspect(binding(), label: "UNKNOWN DROPDOWN EVENT", limit: :infinity)
    {:noreply, socket}
  end

  ## Privates
end
