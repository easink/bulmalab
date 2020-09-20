defmodule BulmalabWeb.ModalComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  def render(assigns) do
    # IO.inspect(assigns, label: :DDDD, limit: :infinity)
    ~L"""
    <button class="button" phx-click="activate" phx-target="#modal-<%= @id %>">
    <div class="modal <%= if @active, do: "is-active" %>" id="modal-<%= @id %>">
      <div class="modal-background"></div>
      <!-- <div class="modal-card"></div> -->
      <div class="modal-content">
        <p>Hello</p>
      </div>
      <button class="modal-close is-large" aria-label="close"></button>
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
    # IO.inspect(binding(), label: "ACTIVATE", limit: :infinity)
    {:noreply, assign(socket, active: :erlang.xor(socket.assigns.active, true))}
  end

  def handle_event(_a, _b, socket) do
    # IO.inspect(binding(), label: "UNKNOWN DROPDOWN EVENT", limit: :infinity)
    {:noreply, socket}
  end

  ## Privates
end
