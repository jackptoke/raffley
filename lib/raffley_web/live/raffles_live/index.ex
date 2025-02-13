defmodule RaffleyWeb.RafflesLive do
  use RaffleyWeb, :live_view

  alias Raffley.Raffles
  alias RaffleyWeb.CustomComponents
  # import RaffleyWeb.CustomComponents

  def mount(_params, _session, socket) do
    {:ok, socket, layout: {RaffleyWeb.Layouts, :app}}
  end

  def render(assigns) do
    ~H"""
    <div class="raffle-index">
      <CustomComponents.banner :let={emoji}>
        <.icon name="hero-sparkles-solid" /> Mystery Raffle Coming Soon {emoji}
        <:details>
          <h2>To Be Revealed Tomorrow</h2>
        </:details>
        <:details>
          <h2>Any guess?</h2>
        </:details>
      </CustomComponents.banner>

      <.filter_form form={@form} />

      <div class="raffles" id="raffles" phx-update="stream">
        <.raffle_card :for={{dom_id, raffle} <- @streams.raffles} raffle={raffle} id={dom_id} />
      </div>
    </div>
    """
  end

  def filter_form(assigns) do
    ~H"""
    <.form for={@form} id="filter-form" phx-change="filter">
      <.input field={@form[:q]} placeholder="Search..." autocomplete="off" phx-debounce="1000" />
      <.input
        type="select"
        field={@form[:status]}
        prompt="Status"
        options={[:upcoming, :open, :closed]}
      />
      <.input
        type="select"
        field={@form[:sort_by]}
        prompt="Sort By"
        options={[
          Prize: "prize",
          "Price: High to Low": "ticket_price_desc",
          "Price: Low to Hight": "ticket_price_asc"
        ]}
      />
      <.link patch={~p"/raffles"}>
        Reset
      </.link>
    </.form>
    """
  end

  attr :raffle, Raffley.Raffles.Raffle, required: true
  attr :id, :string, required: true

  def raffle_card(assigns) do
    ~H"""
    <.link navigate={~p"/raffles/#{@raffle}"} id={@id}>
      <div class="card">
        <img src={"#{@raffle.image_path}"} alt="" class="pic" />
        <h2>{@raffle.prize}</h2>

        <div class="details">
          <div class="price">${@raffle.ticket_price}/ticket</div>
          <CustomComponents.badge status={@raffle.status} />
        </div>
      </div>
    </.link>
    """
  end

  def handle_params(params, _uri, socket) do
    params = filter_empty_parameters(params)

    socket =
      socket
      |> stream(:raffles, Raffles.filter_raffles(params), reset: true)
      |> assign(:form, to_form(params))

    {:noreply, socket}
  end

  def handle_event("filter", params, socket) do
    params = filter_empty_parameters(params)
    IO.inspect(params)
    socket = push_patch(socket, to: ~p"/raffles?#{params}")
    {:noreply, socket}
  end

  def filter_empty_parameters(params) do
    params
    |> Map.take(~W(q status sort_by))
    |> Map.reject(fn {_, v} -> v == "" end)
  end
end
