defmodule Stripe.LineItem do
  @moduledoc """
  Work with Stripe (invoice) line item objects.

  Stripe API reference: https://stripe.com/docs/api/ruby#invoice_line_item_object
  """

  use Stripe.Entity
  import Stripe.Request

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          amount: integer,
          currency: String.t(),
          description: String.t(),
          discountable: boolean,
          invoice_item: Stripe.id() | nil,
          livemode: boolean,
          metadata: Stripe.Types.metadata(),
          period: %{
            start: Stripe.timestamp(),
            end: Stripe.timestamp()
          },
          plan: Stripe.Plan.t() | nil,
          proration: boolean,
          quantity: integer,
          subscription: Stripe.id() | nil,
          subscription_item: Stripe.id() | nil,
          type: String.t()
        }

  defstruct [
    :id,
    :object,
    :amount,
    :currency,
    :description,
    :discountable,
    :invoice_item,
    :livemode,
    :metadata,
    :period,
    :plan,
    :proration,
    :quantity,
    :subscription,
    :subscription_item,
    :type
  ]

  @doc """
  Retrieve an invoice line item.
  """
  @spec retrieve(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:coupon) => Stripe.id() | Stripe.Coupon.t(),
               optional(:customer) => Stripe.id() | Stripe.Customer.t(),
               optional(:ending_before) => t | Stripe.id(),
               optional(:limit) => 1..100,
               optional(:starting_after) => t | Stripe.id(),
               optional(:subscription) => Stripe.id() | Stripe.Subscription.t(),
               optional(:subscription_billing_cycle_anchor) => integer,
               optional(:subscription_items) => Stripe.List.t(Stripe.SubscriptionItem.t()),
               optional(:subscription_prorate) => boolean,
               optional(:subscription_proration_date) => Stripe.timestamp(),
               optional(:subscription_tax_percent) => integer,
               optional(:subscription_trial_from_plan) => boolean
             } | %{}
  def retrieve(id, params \\ %{}, opts \\ []) do
    new_request(opts)
    |> put_endpoint("invoices" <> "/#{get_id!(id)}/" <> "lines")
    |> put_method(:get)
    |> put_params(params)
    |> make_request()
  end
end
