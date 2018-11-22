defmodule Blessd.Signup.Church do
  use Ecto.Schema

  alias Blessd.Signup.Church
  alias Blessd.Changeset.Church, as: ChurchChangeset

  schema "churches" do
    field(:name, :string)
    field(:slug, :string)

    timestamps()
  end

  @doc false
  def changeset(%Church{} = church, attrs) do
    ChurchChangeset.changeset(church, attrs)
  end
end
