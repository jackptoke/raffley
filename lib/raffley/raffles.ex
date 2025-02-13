defmodule Raffley.Raffle do
  defstruct [:id, :prize, :ticket_price, :status, :image_path, :description]
end

defmodule Raffley.Raffles do
  alias Raffley.Raffles.Raffle
  alias Raffley.Repo
  import Ecto.Query, only: [from: 2, where: 2, where: 3, order_by: 2]

  def list_raffles() do
    Repo.all(Raffle)
  end

  def get_raffle(id) do
    Repo.get(Raffle, id)
  end

  def featured_raffles(raffle) do
    query =
      from r in Raffle,
        where: r.status == :open,
        where: r.id != ^raffle.id,
        order_by: [desc: :ticket_price],
        limit: 3

    Repo.all(query)
  end

  def search() do
    query =
      from r in Raffle,
        where: ilike(r.prize, "%gourmet%"),
        order_by: [asc: r.prize]

    Repo.all(query)

    # Raffle
    # |> where([r], ilike(r.prize, fragment("%?%", ^term)))
    # |> order_by(:prize)
    # |> Repo.all()
  end

  def filter_raffles(filter) do
    Raffle
    |> with_status(filter["status"])
    |> search_by(filter["q"])
    |> sort(filter["sort_by"])
    |> Repo.all()
  end

  def with_status(query, status)
      when status in ~W(open closed upcoming) do
    where(query, status: ^status)
  end

  def with_status(query, _), do: query

  def search_by(query, q) when q in ["", nil], do: query

  def search_by(query, q) do
    where(query, [r], ilike(r.prize, ^"%#{q}%"))
  end

  def sort(query, "prize") do
    order_by(query, :prize)
  end

  def sort(query, "ticket_price_asc") do
    order_by(query, asc: :ticket_price)
  end

  def sort(query, "ticket_price_desc") do
    order_by(query, desc: :ticket_price)
  end

  def sort(query, sort_by) do
    IO.inspect(sort_by)
    order_by(query, :id)
  end
end
