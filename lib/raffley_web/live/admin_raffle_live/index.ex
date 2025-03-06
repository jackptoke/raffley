defmodule RaffleyWeb.AdminRaffleLive.Index do
  use RaffleyWeb, :live_view
  import RaffleyWeb.CustomComponents

  alias Raffley.Admin
  # import RaffleyWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Listing Raffles")
      |> stream(:raffles, Admin.list_raffles())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="admin-index">
      <.button phx-click={
        JS.toggle(
          to: "#joke",
          # "fade-in"
          in: {"ease-in-out duration-300", "opacity-0", "opacity-100"},
          # "fade-out"
          out: {"ease-out-in duration-300", "opacity-100", "opacity-0"},
          time: 300
        )
      }>
        Toggle Joke
      </.button>
      <div id="joke" class="joke hidden">
        What's a tree's favourite drink, {@current_user.username}?
      </div>
      <.header>
        {@page_title}
        <:actions>
          <.link navigate={~p"/admin/raffles/new"} class="button">
            New Raffle
          </.link>
        </:actions>
      </.header>
      <.table
        id="raffles"
        rows={@streams.raffles}
        row_click={fn {_, raffle} -> JS.navigate(~p"/raffles/#{raffle}") end}
      >
        <:col :let={{_dom_id, raffle}} label="Prize">
          <.link navigate={~p"/raffles/#{raffle.id}"}>
            {raffle.prize}
          </.link>
        </:col>
        <:col :let={{_dom_id, raffle}} label="Status">
          <.badge status={raffle.status} />
        </:col>
        <:col :let={{_dom_id, raffle}} label="Ticket Price">
          ${raffle.ticket_price}
        </:col>
        <:action :let={{_dom_id, raffle}}>
          <.link navigate={~p"/admin/raffles/#{raffle}/edit"}>
            Edit
          </.link>
        </:action>
        <:action :let={{dom_id, raffle}}>
          <%!-- <.link phx-click="delete" phx-value-id={raffle.id} data-confirm="Are you sure?">
            Delete
          </.link> --%>
          <.link
            phx-click={delete_and_hide(dom_id, raffle)}
            phx-disable-with="Deleting..."
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </div>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    # Process.sleep(3000)
    raffle = Admin.get_raffle!(id)
    {:ok, _} = Admin.delete_raffle(raffle)

    socket =
      socket
      |> stream_delete(:raffles, raffle)

    {:noreply, socket}
  end

  def delete_and_hide(dom_id, raffle) do
    JS.push("delete", value: %{id: raffle.id})
    |> JS.add_class("opacity-50", to: "##{dom_id}")

    # |> JS.hide(to: "##{dom_id}", transition: "fade-out")
  end
end
