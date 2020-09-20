defmodule BulmalabWeb.IndexLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <h1>Dropdown:</h1>
      <%= live_component(@socket, BulmalabWeb.DropdownLiveComponent, id: @dropdown_id, dropdown: @dropdown) %>
      SELECTED: <%= if @dropdown_selected, do: @dropdown_selected %>
      SELECTED: <%= if @table_selected, do: @table_selected %>
    <br>
    <h1>Range:</h1>
      <%= live_component(@socket, BulmalabWeb.LiveRangeComponent, id: :unique_range, value: @range_value, min: 0, max: 100) %>
    <br>
    <h1>Table Resize:</h1>
      <%= live_component(@socket, BulmalabWeb.TableResizeLiveComponent, id: :unique_table_resizes, table: @table) %>
    <br>
    <h1>Table:</h1>
      <%= live_component(@socket, BulmalabWeb.TableLiveComponent, id: :unique, table: @table) %>
    <br>
    """
  end

  def mount(_, _, socket) do
    # {:ok, countries} = Bulmalab.Data.contries()
    # # countries = Enum.map(countries, fn country -> Map.take(country, ["name", "nativeName"]) end)
    # countries = Enum.map(countries, fn country -> Map.take(country, ["name", "nativeName"]) end)
    countries = Bulmalab.Countries.list()
    dropdown = ["apa", "banan"]
    dropdown_id = :some_dropdown

    {:ok,
     assign(socket,
       table: countries,
       dropdown_id: dropdown_id,
       dropdown: dropdown,
       dropdown_selected: nil,
       modal_selected: nil,
       table_selected: nil,
       range_value: 50
     )}
  end

  # def handle_event("input-range", %{"unique_range" => value}, socket) do
  #   IO.inspect(binding(), label: "UNKOWN LIVE EVENT")
  #   {:noreply, assign(socket, range_value: value)}
  # end

  def handle_event(_event, _params, socket) do
    IO.inspect(binding(), label: "UNKOWN LIVE EVENT")
    {:noreply, socket}
  end

  def handle_info({:dropdown, _id, item}, socket) do
    {:noreply, assign(socket, dropdown_selected: item)}
  end

  def handle_info({:table, _id, item}, socket) do
    {:noreply, assign(socket, table_selected: item)}
  end

  def handle_info({:range, _id, value}, socket) do
    {:noreply, assign(socket, range_value: value)}
  end

  def handle_info(msg, socket) do
    IO.inspect(binding(), label: "LIVE UNKOWN")
    {:noreply, socket}
  end
end
