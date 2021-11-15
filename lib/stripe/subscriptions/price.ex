defmodule Stripe.Price do
  @moduledoc """
  Work with Stripe price objects.
  The Prices API adds more flexibility to how you charge customers.
  It also replaces the Plans API, so Stripe recommends migrating your existing
  integration to work with prices.
  To migrate, you need to identify how you use plans, products, and payment
  flows and then update these parts of your integration to use the Prices API.
  Migrating to Prices guide: https://stripe.com/docs/billing/migration/migrating-prices
  You can:
  - Create a price
  - Retrieve a price
  - Update a price
  - List all prices
  Stripe API reference: https://stripe.com/docs/api/prices
  Example:
  ```
  {
    "id": "plan_HJ8MK9HTYgniMM",
    "object": "price",
    "active": true,
    "billing_scheme": "per_unit",
    "created": 1589897226,
    "currency": "usd",
    "livemode": false,
    "lookup_key": null,
    "metadata": {},
    "nickname": null,
    "product": "prod_HJ8MOtuM1vD2jd",
    "recurring": {
      "aggregate_usage": null,
      "interval": "month",
      "interval_count": 1,
      "trial_period_days": null,
      "usage_type": "licensed"
    },
    "tax_behavior": "unspecified",
    "tiers": null,
    "tiers_mode": null,
    "transform_lookup_key": false,
    "transform_quantity": null,
    "type": "recurring",
    "unit_amount": 999,
    "unit_amount_decimal": "999"
  }
  ```
  """

  use Stripe.Entity
  import Stripe.Request

  @type recurring :: %{
          optional(:aggregate_usage) => String.t(),
          optional(:interval) => String.t(),
          optional(:interval_count) => pos_integer,
          optional(:trial_period_days) => pos_integer,
          optional(:usage_type) => String.t()
        }

  @type price_tier :: %{
          flat_amount: integer,
          flat_amount_decimal: String.t(),
          unit_amount: integer,
          unit_amount_decimal: String.t(),
          up_to: integer
        }

  @type transform_quantity :: %{
          divide_by: pos_integer,
          round: String.t()
        }

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          active: boolean,
          billing_scheme: String.t(),
          created: Stripe.timestamp(),
          currency: String.t(),
          livemode: boolean,
          lookup_key: String.t(),
          metadata: Stripe.Types.metadata(),
          nickname: String.t(),
          product: Stripe.id() | Stripe.Product.t(),
          recurring: recurring(),
          tax_behavior: String.t(),
          tiers: [price_tier()],
          tiers_mode: String.t(),
          transform_lookup_key: boolean(),
          transform_quantity: transform_quantity(),
          type: String.t(),
          unit_amount: pos_integer,
          unit_amount_decimal: String.t()
        }

  defstruct [
    :id,
    :object,
    :active,
    :billing_scheme,
    :created,
    :currency,
    :livemode,
    :lookup_key,
    :metadata,
    :nickname,
    :product,
    :recurring,
    :tax_behavior,
    :tiers,
    :tiers_mode,
    :transform_lookup_key,
    :transform_quantity,
    :type,
    :unit_amount,
    :unit_amount_decimal
  ]

  @plural_endpoint "prices"

  @doc """
  Create a price.
  """
  @spec create(params, Stripe.options()) ::
          {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 :currency => String.t(),
                 optional(:unit_amount) => pos_integer,
                 optional(:active) => boolean,
                 optional(:metadata) => Stripe.Types.metadata(),
                 optional(:nickname) => String.t(),
                 optional(:product) => Stripe.id() | Stripe.Product.t(),
                 optional(:recurring) => recurring(),
                 optional(:tax_behavior) => String.t(),
                 optional(:tiers) => [price_tier()],
                 optional(:tiers_mode) => String.t(),
                 optional(:billing_scheme) => String.t(),
                 optional(:lookup_key) => String.t(),
                 optional(:transfer_lookup_key) => boolean,
                 optional(:transform_quantity) => transform_quantity(),
                 optional(:unit_amount_decimal) => String.t()
               }
               | %{}
  def create(params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint)
    |> put_params(params)
    |> put_method(:post)
    |> cast_to_id([:product])
    |> make_request()
  end

  @doc """
  Retrieve a price.
  """
  @spec retrieve(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  Update a price.
  Takes the `id` and a map of changes.
  """
  @spec update(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:active) => boolean,
                 optional(:metadata) => Stripe.Types.metadata(),
                 optional(:nickname) => String.t(),
                 optional(:recurring) => recurring(),
                 optional(:lookup_key) => String.t(),
                 optional(:transfer_lookup_key) => boolean
               }
               | %{}
  def update(id, params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:post)
    |> put_params(params)
    |> make_request()
  end

  @doc """
  List all prices.
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:active) => boolean,
                 optional(:currency) => String.t(),
                 optional(:product) => Stripe.Product.t() | Stripe.id(),
                 optional(:type) => String.t(),
                 optional(:created) => Stripe.timestamp(),
                 optional(:ending_before) => t | Stripe.id(),
                 optional(:limit) => 1..100,
                 optional(:lookup_keys) => list(String.t()),
                 optional(:recurring) => recurring() | nil,
                 optional(:starting_after) => t | Stripe.id()
               }
               | %{}
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint)
    |> put_method(:get)
    |> put_params(params)
    |> cast_to_id([:product, :ending_before, :starting_after])
    |> make_request()
  end
end