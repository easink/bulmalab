defmodule BulmalabWeb.LiveRangeComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  def render(assigns) do
    # STEP
    # VALUE
    ~L"""
    <form phx-change="input-range" phx-submit="save" phx-target="#range-<%= @name %>">
      <div class="range range-primary" id="range-<%= @name %>">
        <input type="range" name="<%= @name %>" min="<%= @min %>" max="<%= @max %>" phx-debounce="200" <%= unless @enable, do: "disabled=\"disabled\"" %>>
        <output id="<%= @name %>"><%= @value %></output>
      </div>
    </form>
    """
  end

  def mount(socket) do
    # IO.inspect(binding(), label: :mount)
    init = [
      # active: false,
      # selected: nil
    ]

    {:ok, assign(socket, init)}
  end

  def update(params, socket) do
    IO.inspect(binding(), label: "RANGE UPDATE")

    values = [
      name: Map.get(params, :id),
      value: Map.get(params, :value, 0),
      min: Map.get(params, :min, 0),
      max: Map.get(params, :max, 100),
      steps: Map.get(params, :steps, 1),
      enable: true
    ]

    # {:ok, assign(socket, range: range, id: id)}
    {:ok, assign(socket, values)}
  end

  def handle_event("input-range", params, socket) do
    id = socket.assigns.name
    value = Map.get(params, Atom.to_string(id))

    send(self(), {:range, id, value})

    {:noreply, assign(socket, value: value)}
  end

  # def handle_event("select", %{"item" => item}, socket) do
  #   # IO.inspect(binding(), label: "SELECT", limit: :infinity)
  #   send(self(), {:dropdown, socket.assigns.id, item})
  #   {:noreply, assign(socket, active: false)}
  # end

  # def handle_event(a, b, socket) do
  #   # IO.inspect(binding(), label: "UNKNOWN DROPDOWN EVENT", limit: :infinity)
  #   {:noreply, socket}
  # end

  ## Privates
end
