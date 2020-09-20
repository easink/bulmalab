defmodule BulmalabWeb.TableLiveComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  @arrow_down <<" ", 0x25BE::utf8>>
  @arrow_up <<" ", 0x25B4::utf8>>

  def render(assigns) do
    table_classes = assigns.table_classes |> to_html_class_names()

    ~L"""
    <table class="table <%= table_classes %>" id="table-<%= @id %>"<>
    <thead>
      <%= header(@table, assigns) %>
    </thead>
    <tbody>
      <%= body(@table, assigns) %>
    </tbody>
    <tfoot>
    </tfoot>
    </table>
    """
  end

  def mount(socket) do
    # IO.inspect(binding(), label: :mount)
    init = [
      table_classes: [:is_hoverable, :is_narrow, :is_bordered],
      sort_by: nil,
      order: :asc,
      selected: nil
    ]

    {:ok, assign(socket, init)}
  end

  def handle_event("sort", %{"sort-by" => sort_by}, socket) do
    {sort_by, order} = get_sorting(socket.assigns, sort_by)
    {:noreply, assign(socket, sort_by: sort_by, order: order)}
  end

  def handle_event("select", %{"row-id" => row_id}, socket) do
    selected = unless socket.assigns.selected == row_id, do: row_id

    # entry = Enum.find(socket.table, fn entry ->
    send(self(), {:table, socket.assigns.id, selected})
    {:noreply, assign(socket, selected: selected)}
  end

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

  defp header(table, assigns) do
    for head <- headers(table), do: head(head, assigns)
  end

  defp head(title, assigns) do
    title_camel = title |> to_string |> Phoenix.Naming.camelize()

    # style =
    #   "position: -webkit-sticky; position: sticky; top: 0; background: #5cb85c; text-align: left; font-weight: normal; font-size: 1.1rem; color: white; position: relative;"

    attrs = [
      # style: "position: relative",
      phx_click: "sort",
      phx_value_sort_by: title,
      phx_target: "#table-#{assigns.id}"
    ]

    # attrs =
    #   if title == assigns.sort_by,
    #     do: [{:bgcolor, "#E0E0E0"} | attrs],
    #     else: attrs

    content_tag(:th, attrs) do
      if title == assigns.sort_by,
        do: title_camel |> title_sort(assigns.order),
        else: title_camel

      # Routes.live_path(
      # live_link(title,
      #   to:
      #     BulmalabWeb.Router.Helpers.page_path(
      #       BulmalabWeb.Endpoint,
      #       :index,
      #       %{sort_by: title}
      #     )
      # )

      # content_tag(:strong, String.capitalize(title), title: title)
    end
  end

  defp title_sort(title, :asc),
    do: [title, @arrow_down]

  defp title_sort(title, :desc),
    do: [title, @arrow_up]

  # do: [String.upcase(title), <<0xF0, 0xD7>>]

  defp body(table, %{sort_by: nil} = assigns) do
    for row <- table, do: row(row, headers(table), assigns)
  end

  defp body(table, assigns) do
    sorter =
      case assigns.order do
        :asc -> &>=/2
        :desc -> &<=/2
      end

    table
    |> Enum.sort_by(fn row -> Map.get(row, assigns.sort_by) end, sorter)
    |> Enum.map(fn row -> row(row, headers(table), assigns) end)

    # for row <- table, do: row(row, headers(table))
  end

  defp row(row, headers, assigns) do
    prim_key = List.first(headers)
    row_id = Map.get(row, prim_key)
    attrs = [phx_click: "select", phx_value_row_id: row_id, phx_target: "#table-#{assigns.id}"]

    attrs =
      if assigns.selected == row_id,
        do: [{:class, "is-selected"} | attrs],
        else: attrs

    content_tag(:tr, attrs) do
      for column <- headers do
        content_tag(:td, Map.get(row, column))
      end
    end
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
end
