defmodule Stripe.Review do
  @moduledoc """
  Work with Stripe review objects.

  Stripe API reference: https://stripe.com/docs/api#reviews
  """

  use Stripe.Entity

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          billing_zip: String.t(),
          charge: Stripe.id() | Stripe.Charge.t(),
          closed_reason: String.t(),
          created: Stripe.timestamp(),
          livemode: boolean,
          open: boolean,
          opened_reason: String.t(),
          payment_intent: String.t(),
          reason: String.t()
        }

  defstruct [
    :id,
    :object,
    :billing_zip,
    :charge,
    :closed_reason,
    :created,
    :livemode,
    :open,
    :opened_reason,
    :payment_intent,
    :reason
  ]
end
