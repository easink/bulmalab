defmodule BulmalabWeb.TableResizeComponentsLiveComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  @arrow_down <<" ", 0x25BE::utf8>>
  @arrow_up <<" ", 0x25B4::utf8>>

  defmodule TableRowComponent do
    use Phoenix.LiveComponent

    # <tr phx-click="select"
    #     phx-value-row-id="<%= @id %>"
    #     phx-target="#table-<%= @table.id %>"
    #     <%= if @table.selected_row == @id do %>
    #     class="is-selected"
    #     <% end %>
    # >
    # <%= for column <- @headers do %>
    #   <td><%= Map.get(@row, column, "") %></td>
    # <% end %>
    # </tr>

    #  <%= table_row(@row, @headers, @table_assigns) %>
    @impl true
    def render(assigns) do
      ~L"""
      <%= table_row(@row, @headers, @table_assigns) %>
      """
    end

    defp table_row(row, headers, assigns) do
      prim_key = List.first(headers)
      row_id = Map.get(row, prim_key)

      attrs =
        [
          phx_click: "select",
          phx_value_row_id: row_id,
          phx_target: "#table-#{assigns.id}"
        ]
        |> add_selected(assigns.selected_row, row_id)

      content_tag(:tr, attrs) do
        for column <- headers do
          content_tag(:td, Map.get(row, column))
        end
      end
    end

    defp add_selected(attrs, selected_row, row_id) do
      if selected_row == row_id,
        do: [{:class, "is-selected"} | attrs],
        else: attrs
    end
  end

  @impl true
  def render(assigns) do
    table_classes = assigns.table_classes |> to_html_class_names()

    headers = headers(assigns.table)
    prim_key = List.first(headers)

    ~L"""
    <table class="table <%= table_classes %>" id="table-<%= @id %>">
    <thead>
      <%= for title <- headers do %>
        <%= head(title , assigns) %>
      <% end %>
    </thead>
    <tbody>
    <%= for row <- table_sorted(@table, assigns) do %>
      <% row_id = Map.get(row, prim_key) %>
      <%= live_component @socket, TableRowComponent, id: row_id, row: row, headers: headers, table_assigns: assigns %>
    <% end %>
    </tbody>
    <tfoot>
    </tfoot>
    </table>
    """
  end

  @impl true
  def mount(socket) do
    # IO.inspect(binding(), label: :mount)
    init = [
      table_classes: [:is_hoverable, :is_narrow, :is_bordered],
      sort_by: nil,
      order: :asc,
      selected_row: nil,
      widths: []
    ]

    {:ok, assign(socket, init)}
  end

  @impl true
  def handle_event("sort", %{"sort-by" => sort_by}, socket) do
    IO.inspect(binding(), label: "TABLE SORT", limit: :infinity)
    {sort_by, order} = get_sorting(socket.assigns, sort_by)
    {:noreply, assign(socket, sort_by: sort_by, order: order)}
  end

  @impl true
  def handle_event("select", %{"row-id" => row_id} = apa, socket) do
    IO.inspect(binding(), label: "TABLE SELECT", limit: :infinity)
    selected_row = unless socket.assigns.selected_row == row_id, do: row_id

    # entry = Enum.find(socket.table, fn entry ->
    send(self(), {:table, socket.assigns.id, selected_row})
    {:noreply, assign(socket, selected_row: selected_row)}
  end

  @impl true
  def handle_event("resize", %{"title" => title, "width" => width}, socket) do
    IO.inspect(binding(), label: "TABLE COLUMN RESIZE", limit: :infinity)

    widths = socket.assigns.widths
    heads = headers(socket.assigns.table)

    socket =
      case Enum.find(heads, fn name -> Atom.to_string(name) == title end) do
        nil -> socket
        title -> assign(socket, widths: Keyword.put(widths, title, width))
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event(_event, _params, socket) do
    IO.inspect(binding(), label: :TableComponent)
    {:noreply, socket}
  end

  ## Privates

  defp headers(table) do
    table
    |> List.first()
    |> Map.from_struct()
    |> Map.keys()
  end

  # defp header(table, assigns) do
  #   for head <- headers(table), do: head(head, assigns)
  # end

  defp head(title, assigns) do
    # style =
    #   "position: -webkit-sticky; position: sticky; top: 0; background: #5cb85c; text-align: left; font-weight: normal; font-size: 1.1rem; color: white; position: relative;"

    attrs = [
      style: "position: relative",
      class: "unselectable",
      title: title,
      phx_target: "#table-#{assigns.id}"
    ]

    attrs =
      assigns.widths
      |> Keyword.get(title)
      |> maybe_add_width(attrs)

    content_tag(:th, attrs) do
      [head_title(title, assigns), resize_elem(title, assigns.id)]
    end
  end

  defp head_title(title, assigns) do
    title_camel = title |> to_string |> Phoenix.Naming.camelize()

    attrs = [
      phx_click: "sort",
      phx_value_sort_by: title
    ]

    content_tag(:span, attrs) do
      if title == assigns.sort_by,
        do: title_camel |> show_sort(assigns.order),
        else: title_camel
    end
  end

  defp resize_elem(title, id) do
    # <div style="top: 0px; right: 0px; width: 5px; position: absolute; cursor: col-resize; user-select: none; height: 87px;"></div>
    # style="position: absolute; top: 0; right: 0; bottom: 0; background: black; opacity: 0; width: 5px; cursor: col-resize;"
    style = """
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    background: black;
    opacity: 0;
    width: 5px;
    cursor: col-resize;
    """

    # content_tag(:span, "", style: style, id: "#{id}-#{title}", phx_hook: "Table")
    attrs = [
      style: style,
      # "x-on:mousedown": "mousedown = true; xpos = $event.clientX; console.log($event)",
      # "x-on:mousemove": "if (mousedown === true) { console.log(xpos - $event.clientX) }",
      # "x-on:mouseup": "mousedown = false; console.log('up')"
      id: "#{id}-#{title}",
      phx_hook: "Table"
    ]

    content_tag(:span, "", attrs)
  end

  defp show_sort(title, :asc),
    do: [title, @arrow_down]

  defp show_sort(title, :desc),
    do: [title, @arrow_up]

  # do: [String.upcase(title), <<0xF0, 0xD7>>]

  defp table_sorted(table, %{sort_by: nil} = _assigns) do
    table
  end

  defp table_sorted(table, %{order: sort_order, sort_by: sort_by} = _assigns) do
    sorter =
      case sort_order do
        :asc -> &>=/2
        :desc -> &<=/2
      end

    Enum.sort_by(table, &Map.get(&1, sort_by), sorter)

    # |> Enum.map(fn row -> {row, headers} end)

    # for row <- table, do: row(row, headers(table))
  end

  defp get_sorting(assigns, sort_by) do
    sorting_header = get_sorting_header(assigns.table, sort_by)

    case {assigns.sort_by, assigns.order} do
      {^sorting_header, :asc} -> {sorting_header, :desc}
      _ -> {sorting_header, :asc}
    end
  end

  defp get_sorting_header(table, sort_by) do
    Enum.find(headers(table), fn column -> to_string(column) == sort_by end)
  end

  defp to_html_class_names(names) do
    names
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.replace(&1, "_", "-"))
    |> Enum.join(" ")
  end

  defp maybe_add_width(nil, attrs), do: attrs

  defp maybe_add_width(width, attrs) do
    width = max(width, 10)
    Keyword.put(attrs, :width, "#{width}px")
  end
end
