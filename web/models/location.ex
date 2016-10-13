defmodule Classlab.Location do
  use Classlab.Web, :model

  # Fields
  schema "locations" do
    field :name, :string
    field :address_line_1, :string
    field :address_line_2, :string
    field :zipcode, :string
    field :city, :string
    field :country, :string
    field :external_url, :string

    timestamps()
  end

  # Composable Queries

  # Changesets & Validations
  @fields ~w(name address_line_1 address_line_2 zipcode city country external_url)
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
  end

  # Model Functions
end