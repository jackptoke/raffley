defmodule RaffleyWeb.CharityLive.Show do
  use RaffleyWeb, :live_view

  alias Raffley.Charities

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:charity, Charities.get_charity_with_raffles!(id))}
  end

  defp page_title(:show), do: "Show Charity"
  defp page_title(:edit), do: "Edit Charity"
end
