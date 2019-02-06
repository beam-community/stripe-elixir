defmodule Stripe.List do
  @moduledoc """
  Work with Stripe list objects.

  A list is a general-purpose Stripe object which holds one or more
  other Stripe objects in its "data" property.

  In its current iteration it simply allows serializing into a properly
  typed struct.

  In future iterations, it should:
  - Support multiple types of objects in its collection
  - Support fetching the next set of objects (pagination)
  """
  use Stripe.Entity

  @type value :: term

  @type t(value) :: %__MODULE__{
          object: String.t(),
          data: [value],
          has_more: boolean,
          total_count: integer | nil,
          url: String.t()
        }

  defstruct [:object, :data, :has_more, :total_count, :url]
end
