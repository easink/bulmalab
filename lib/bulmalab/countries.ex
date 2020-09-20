defmodule Bulmalab.Countries do
  alias Bulmalab.Country
  # alias Bulmalab.Countries

  # import Ecto.Changeset

  @countries \
     Bulmalab.Data.contries()
     |> Enum.map(fn country ->
       %Country{}
       |> Country.changeset(country)
       |> Ecto.Changeset.apply_changes()
     end)

  @spec list() :: [Country.t()]
  def list() do
    @countries

    # countries = Enum.map(countries, fn country -> Map.take(country, ["name", "nativeName"]) end)
    # Enum.map(countries, fn country -> Map.take(country, ["name", "nativeName"]) end)
  end
end
