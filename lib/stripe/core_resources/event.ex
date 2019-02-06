defmodule Stripe.Event do
  @moduledoc """
  Work with Stripe event objects.

  You can:
  - Retrieve an event
  - List all events

  Stripe API reference: https://stripe.com/docs/api#event
  """

  use Stripe.Entity
  import Stripe.Request

  @type event_data :: %{
          object: event_data_object,
          previous_attributes: map
        }

  # TODO: add Scheduled query run
  @type event_data_object ::
          Stripe.Account.t()
          | Stripe.ApplicationFee.t()
          | Stripe.Charge.t()
          | Stripe.Coupon.t()
          | Stripe.Customer.t()
          | Stripe.FileUpload.t()
          | Stripe.Invoice.t()
          | Stripe.Invoiceitem.t()
          | Stripe.Order.t()
          | Stripe.OrderReturn.t()
          | Stripe.Payout.t()
          | Stripe.Plan.t()
          | Stripe.Relay.Product.t()
          | Stripe.Product.t()
          | Stripe.Recipient.t()
          | Stripe.Review.t()
          | Stripe.Sku.t()
          | Stripe.Source.t()
          | Stripe.Transfer.t()
          | map

  @type event_request :: %{
          id: String.t() | nil,
          idempotency_key: String.t() | nil
        }

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          api_version: String.t() | nil,
          created: Stripe.timestamp(),
          data: event_data,
          livemode: boolean,
          pending_webhooks: non_neg_integer,
          request: event_request | nil,
          type: String.t()
        }

  defstruct [
    :id,
    :object,
    :api_version,
    :created,
    :data,
    :livemode,
    :pending_webhooks,
    :request,
    :type,
    :account
  ]

  @plural_endpoint "events"

  @doc """
  Retrieve an event.
  """
  @spec retrieve(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  List all events, going back up to 30 days.
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:created) => Stripe.date_query(),
                 optional(:ending_before) => t | Stripe.id(),
                 optional(:limit) => 1..100,
                 optional(:starting_after) => t | Stripe.id(),
                 optional(:type) => String.t(),
                 optional(:types) => list
               }
               | %{}
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint)
    |> put_method(:get)
    |> put_params(params)
    |> cast_to_id([:ending_before, :starting_after])
    |> make_request()
  end
end
