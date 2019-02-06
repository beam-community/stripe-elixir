defmodule Stripe.Types do
  @moduledoc """
  A module that contains shared types matching Stripe schemas.
  """

  @type address :: %{
          city: String.t() | nil,
          country: String.t() | nil,
          line1: String.t() | nil,
          line2: String.t() | nil,
          postal_code: String.t() | nil,
          state: String.t() | nil
        }

  @type fee :: %{
          amount: integer,
          application: String.t() | nil,
          currency: String.t(),
          description: String.t() | nil,
          type: String.t()
        }

  @type location :: %{
          country: String.t(),
          source: String.t(),
          state: String.t()
        }

  @type metadata :: %{
          optional(String.t()) => String.t()
        }

  @type shipping :: %{
          address: Stripe.Types.address(),
          carrier: String.t() | nil,
          name: String.t(),
          phone: String.t() | nil,
          tracking_number: String.t() | nil
        }

  @type tax :: %{
          automatic_tax: String.t(),
          ip_address: String.t(),
          location: location()
        }

  @type tax_info :: %{
          type: String.t(),
          tax_id: String.t() | nil
        }

  @type tax_info_verification :: %{
          status: String.t() | nil,
          verified_name: String.t() | nil
        }

  @type transfer_schedule :: %{
          delay_days: non_neg_integer,
          interval: String.t(),
          monthly_anchor: non_neg_integer | nil,
          weekly_anchor: String.t() | nil
        }
end
