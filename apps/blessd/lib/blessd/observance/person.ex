defmodule Blessd.Observance.Person do
  use Ecto.Schema

  import Ecto.Query

  alias Blessd.Observance.Attendant
  alias Blessd.Observance.Person
  alias Blessd.Observance.Meeting

  schema "people" do
    field(:church_id, :id)
    field(:email, :string)
    field(:name, :string)

    has_many(:attendants, Attendant)
  end

  def select_ids(query), do: select(query, [p], p.id)

  def order(query), do: order_by(query, [p], p.name)

  def preload(query) do
    query
    |> join(:left, [p], a in assoc(p, :attendants), as: :attendants)
    |> preload([p, attendants: a], attendants: a)
  end

  def present?(%Person{attendants: attendants}, %Meeting{id: meeting_id}) do
    Enum.any?(attendants, &(&1.meeting_id == meeting_id))
  end

  def search(query, query_str) do
    query_str = "%#{query_str}%"

    where(
      query,
      [p],
      fragment("? ilike ?", p.name, ^query_str) or fragment("? ilike ?", p.email, ^query_str)
    )
  end
end
