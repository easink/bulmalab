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
    # x-transition:leave="animating down in"
    #
    # <div class="ui selection dropdown">
    # <div class="ui selection dropdown active">
    # <div class="ui selection dropdown active visible">
    # ---
    # <div class="ui selection dropdown visible">
    # <div class="ui selection dropdown">
    # ===
    # <div class="menu transition hidden">
    # <div class="menu transition animating slide down in" style="display block !important; animation-duration: 200ms;">
    # <div class="menu transition visible" style="display block !important;">
    # ---
    # <div class="menu transition visible animating slide down out" style="display block !important; animation-duration: 200ms;">
    # <div class="menu transition hidden">
    #
    # x-transition:enter="'animating slide down ' + active ? 'out' : 'in'"
    ~L"""
    <div class="ui selection dropdown"
      x-data="{ visible: false, active: false, done: true }"
      :class="{ 'active': active, 'visible': visible }"
      @click="active = ! active; done = false"
      @keydown.escape="active = false"
      @click.away="active = false"
      x-on:transitionend="visible = ! visible; done = true"
    >
      <i class="dropdown icon"></i>
      <div class="text">Menu</div>
      <div class="menu transition"
      :class="{ 'visible': visible, 'hidden': !( active || visible ), 'animating slide down out': ! done, 'out': (active && ! done), 'in': (! active && ! done ) }"
        >
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
