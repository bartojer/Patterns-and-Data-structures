defmodule LicoriceStructs do

  defmodule Address do
    defstruct street_address_1: "",
              street_address_2: "",
              city: "",
              state: "ID",
              zip_code: "",
              country: "United States",
              company: ""
  end

  defmodule Customer do
    defstruct name: "",
              address: %Address{},
              phone_number: "",
              email: "",
              notes: "",
              created_at: nil
  end

  defmodule Item do
    defstruct item_id: nil,
              name: "",
              description: "",
              image_url: "",
              category: "",
              brand: "",
              size: "",
              color: "",
              material: "",
              cost: 0.0,
              quantity: 0
  end

  defmodule Rental do
    defstruct customer: %Customer{},
              items: [],
              rented_at: nil,
              due_at: nil,
              returned_at: nil,
              status: "active",
              notes: ""
  end

end
