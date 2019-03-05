defmodule Stripe.Session do
  @moduledoc """
  Work with Stripe Checkout Session objects.

  You can:

  - Create a new session

  Stripe API reference: https://stripe.com/docs/api/checkout/sessions
  """

  use Stripe.Entity
  import Stripe.Request

  @type line_item :: %{
          :amount => integer(),
          :currency => String.t(),
          :name => String.t(),
          :quantity => integer(),
          optional(:description) => String.t(),
          optional(:images) => list(String.t())
        }

  @type capture_method :: :automatic | :manual

  @type transfer_data :: %{
          :destination => String.t()
        }

  @type payment_intent_data :: %{
          optional(:application_fee_amount) => integer(),
          optional(:capture_method) => capture_method,
          optional(:description) => String.t(),
          optional(:metadata) => Stripe.Types.metadata(),
          optional(:on_behalf_of) => String.t(),
          optional(:receipt_email) => String.t(),
          optional(:shipping) => Stripe.Types.shipping(),
          optional(:statement_descriptor) => String.t(),
          optional(:transfer_data) => transfer_data
        }

  @type item :: %{
          :plan => String.t(),
          optional(:quantity) => integer()
        }

  @type subscription_data :: %{
          :items => list(item),
          :metadata => Stripe.Types.metadata(),
          :trial_end => integer(),
          :trial_period_days => integer()
        }

  @type create_params :: %{
          :cancel_url => String.t(),
          :payment_method_types => list(String.t()),
          :success_url => String.t(),
          optional(:client_reference_id) => String.t(),
          optional(:customer_email) => String.t(),
          optional(:line_items) => list(line_item),
          optional(:locale) => String.t(),
          optional(:payment_intent_data) => payment_intent_data,
          optional(:subscription_data) => subscription_data
        }

  @type t :: %__MODULE__{
          :id => Stripe.id(),
          :object => String.t(),
          :livemode => boolean()
        }

  defstruct [
    :id,
    :object,
    :livemode
  ]

  @plural_endpoint "checkout/sessions"

  @spec create(create_params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def create(params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint)
    |> put_params(params)
    |> put_method(:post)
    |> make_request()
  end
end
