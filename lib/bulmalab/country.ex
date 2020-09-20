defmodule Bulmalab.Country do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bulmalab.Country

  # @primary_key {:name, :binary_id, autogenerate: false}
  @primary_key false
  embedded_schema do
    field(:name, :string)
    field(:nativeName, :string)
  end

  @doc false
  def changeset(%Country{} = country, attrs) do
    country
    |> cast(attrs, [:name, :nativeName])
    |> validate_required([:name, :nativeName])
  end
end
