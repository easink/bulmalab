defmodule BulmalabWeb.TableLiveTestaComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  def render(assigns) do
    table_classes =
      assigns.table_classes
      |> Enum.map(&to_string/1)
      |> Enum.map(&String.replace(&1, "_", "-"))
      |> Enum.join(" ")

    ~L"""
    <table class="table <%= table_classes %>" id="table-<%= @id %>" phx-hook=Table>
    <thead>
      <%= header(@table, assigns) %>
    </thead>
    <tbody>
      <%= body(@table, assigns) %>
    </tbody>
    <tfoot>
    </tfoot>
    </table>
    <script>
      // Code By Webdevtrick ( https://webdevtrick.com )
      const min = 150;
      // The max (fr) values for grid-template-columns
      const columnTypeToRatioMap = {
        numeric: 1,
        'text-short': 1.67,
        'text-long': 3.33
      };

      const table = document.querySelector('table');

      const columns = [];
      let headerBeingResized;

      // The next three functions are mouse event callbacks
      const onMouseMove = e => requestAnimationFrame(() => {
        console.log('onMouseMove');

        // Calculate the desired width
        horizontalScrollOffset = document.documentElement.scrollLeft;
        const width = horizontalScrollOffset + e.clientX - headerBeingResized.offsetLeft;
        console.log(width);

        // Update the column object with the new size value
        const column = columns.find(({ header }) => header === headerBeingResized);
        column.size = Math.max(min, width) + 'px'; // Enforce our minimum

        // For the other headers which don't have a set width, fix it to their computed width
        columns.forEach(column => {
          if (column.size.startsWith('minmax')) {// isn't fixed yet (it would be a pixel value otherwise)
            column.size = parseInt(column.header.clientWidth, 10) + 'px';
          }
        });

        /*
              Update the column sizes
              Reminder: grid-template-columns sets the width for all columns in one value
          */
        table.style.gridTemplateColumns = columns.
        map(({ header, size }) => size).
        join(' ');
      });

      // Clean up event listeners, classes, etc.
      const onMouseUp = () => {
        console.log('onMouseUp');

        window.removeEventListener('mousemove', onMouseMove);
        window.removeEventListener('mouseup', onMouseUp);
        headerBeingResized.classList.remove('header--being-resized');
        headerBeingResized = null;
      };

      // Get ready, they're about to resize
      const initResize = ({ target }) => {
        console.log('initResize');

        headerBeingResized = target.parentNode;
        headerBeingResized = target;
        console.log(headerBeingResized);
        window.addEventListener('mousemove', onMouseMove);
        window.addEventListener('mouseup', onMouseUp);
        headerBeingResized.classList.add('header--being-resized');
      };

      // Let's populate that columns array and add listeners to the resize handles
      document.querySelectorAll('th').forEach(header => {
        const max = columnTypeToRatioMap[header.dataset.type] + 'fr';
        columns.push({
          header,
          // The initial size value for grid-template-columns:
          size: `minmax(${min}px, ${max})` });

        // header.querySelector('.resize-handle').addEventListener('mousedown', initResize);
        header.addEventListener('mousedown', initResize);
      });
    </script>
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
    |> hd
    |> Map.from_struct()
    |> Map.keys()
  end

  defp header(table, assigns) do
    for head <- headers(table), do: head(head, assigns)
  end

  defp head(title, assigns) do
    title = title |> to_string |> Phoenix.Naming.camelize()

    attrs = [
      # class: "resize-handle",
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
        do: title |> title_sort(assigns.order),
        else: title

      # htitle <> " <span class=\"resize-handle\"></span>"

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
    do: [title, <<" ", 0x25BE::utf8>>]

  defp title_sort(title, :desc),
    do: [title, <<" ", 0x25B4::utf8>>]

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
    case {assigns.sort_by, assigns.order} do
      {^sort_by, :asc} -> {sort_by, :desc}
      _ -> {sort_by, :asc}
    end
  end
end
