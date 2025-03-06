defmodule RaffleyWeb.CharityLive.Index do
  use RaffleyWeb, :live_view

  alias Raffley.Charities
  alias Raffley.Charities.Charity

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :charities, Charities.list_charities())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Charity")
    |> assign(:charity, Charities.get_charity!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Charity")
    |> assign(:charity, %Charity{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Charities")
    |> assign(:charity, nil)
  end

  @impl true
  def handle_info({RaffleyWeb.CharityLive.FormComponent, {:saved, charity}}, socket) do
    {:noreply, stream_insert(socket, :charities, charity)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    charity = Charities.get_charity!(id)
    {:ok, _} = Charities.delete_charity(charity)

    {:noreply, stream_delete(socket, :charities, charity)}
  end
end
