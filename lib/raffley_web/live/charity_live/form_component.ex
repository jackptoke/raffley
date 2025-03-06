defmodule RaffleyWeb.CharityLive.FormComponent do
  use RaffleyWeb, :live_component

  alias Raffley.Charities

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage charity records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="charity-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:slug]} type="text" label="Slug" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Charity</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{charity: charity} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Charities.change_charity(charity))
     end)}
  end

  @impl true
  def handle_event("validate", %{"charity" => charity_params}, socket) do
    changeset = Charities.change_charity(socket.assigns.charity, charity_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"charity" => charity_params}, socket) do
    save_charity(socket, socket.assigns.action, charity_params)
  end

  defp save_charity(socket, :edit, charity_params) do
    case Charities.update_charity(socket.assigns.charity, charity_params) do
      {:ok, charity} ->
        notify_parent({:saved, charity})

        {:noreply,
         socket
         |> put_flash(:info, "Charity updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_charity(socket, :new, charity_params) do
    case Charities.create_charity(charity_params) do
      {:ok, charity} ->
        notify_parent({:saved, charity})

        {:noreply,
         socket
         |> put_flash(:info, "Charity created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
