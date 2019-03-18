defmodule Stripe.Review do
  @moduledoc """
  Work with Stripe review objects.

  Stripe API reference: https://stripe.com/docs/api#reviews
  """

  use Stripe.Entity

  @type session :: %{
          browser: String.t(),
          device: String.t(),
          platform: String.t(),
          version: String.t()
        }

  @type ip_address_location :: %{
          city: String.t(),
          country: String.t(),
          latitude: float,
          longitude: float,
          region: String.t()
  }

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          billing_zip: String.t(),
          charge: Stripe.id() | Stripe.Charge.t(),
          closed_reason: String.t(),
          created: Stripe.timestamp(),
          ip_address: String.t(),
          ip_address_location: ip_address_location,
          livemode: boolean,
          open: boolean,
          opened_reason: String.t(),
          payment_intent: String.t(),
          reason: String.t(),
          session: session
        }

  defstruct [
    :id,
    :object,
    :billing_zip,
    :charge,
    :closed_reason,
    :created,
    :ip_address,
    :ip_address_location,
    :livemode,
    :open,
    :opened_reason,
    :payment_intent,
    :reason,
    :session
  ]
end
