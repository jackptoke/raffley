defmodule RaffleyWeb.CustomComponents do
  use RaffleyWeb, :html

  # Specifying the method below has a required parameter
  # , default: :upcoming
  attr :status, :atom, required: true
  attr :class, :string, default: nil

  def badge(assigns) do
    ~H"""
    <div class={[
      "rounded-md px-2 py-1 text-xs font-medium uppercase inline-block border",
      @status == :open && "text-lime-600 border-lime-600",
      @status == :upcoming && "text-amber-600 border-amber-600",
      @status == :closed && "text-gray-600 border-gray-600",
      @class
    ]}>
      {@status}
    </div>
    """
  end

  slot :inner_block, required: true
  slot :details, required: false

  def banner(assigns) do
    assigns = assign(assigns, :emoji, ~W(🛵 🏍️ 🏎️) |> Enum.random())

    ~H"""
    <div class="banner">
      <h1>
        {render_slot(@inner_block, @emoji)}
      </h1>
      <div :for={detail <- @details} :if={@details != []} class="details">
        {render_slot(detail)}
      </div>
    </div>
    """
  end
end
