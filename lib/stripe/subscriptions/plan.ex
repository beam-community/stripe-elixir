defmodule Stripe.Plan do
  @moduledoc """
  Work with Stripe plan objects.

  You can:

  - Create a plan
  - Retrieve a plan
  - Update a plan
  - Delete a plan

  Does not yet render lists or take options.

  Stripe API reference: https://stripe.com/docs/api#plan

  Example:

  ```
  {
    "id": "ivory-extended-580",
    "object": "plan",
    "active": true,
    "aggregate_usage": null,
    "amount": 999,
    "billing_scheme": "per_unit",
    "created": 1531234812,
    "currency": "usd",
    "interval": "month",
    "interval_count": 1,
    "livemode": false,
    "metadata": {
    },
    "nickname": null,
    "product": "prod_DCmtkptv7qHXGE",
    "tiers": null,
    "tiers_mode": null,
    "transform_usage": null,
    "trial_period_days": null,
    "usage_type": "licensed"
  }
  ```
  """

  use Stripe.Entity
  import Stripe.Request

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          active: boolean,
          aggregate_usage: String.t() | nil,
          amount: non_neg_integer | nil,
          billing_scheme: String.t() | nil,
          created: Stripe.timestamp(),
          currency: String.t(),
          deleted: boolean | nil,
          interval: String.t(),
          interval_count: pos_integer,
          livemode: boolean,
          metadata: Stripe.Types.metadata(),
          name: String.t(),
          nickname: String.t() | nil,
          product: Stripe.id() | Stripe.Product.t(),
          tiers: Stripe.List.t(map) | nil,
          tiers_mode: boolean | nil,
          transform_usage: map | nil,
          trial_period_days: non_neg_integer | nil,
          usage_type: String.t() | nil
        }

  defstruct [
    :id,
    :object,
    :active,
    :aggregate_usage,
    :amount,
    :billing_scheme,
    :created,
    :currency,
    :deleted,
    :interval,
    :interval_count,
    :livemode,
    :metadata,
    :name,
    :nickname,
    :product,
    :tiers,
    :tiers_mode,
    :transform_usage,
    :trial_period_days,
    :usage_type
  ]

  @plural_endpoint "plans"

  @doc """
  Create a plan.
  """
  @spec create(params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 :currency => String.t(),
                 :interval => String.t(),
                 :product => Stripe.id() | Stripe.Product.t(),
                 optional(:id) => String.t(),
                 optional(:amount) => non_neg_integer,
                 optional(:active) => boolean,
                 optional(:billing_scheme) => String.t(),
                 optional(:interval_count) => pos_integer,
                 optional(:metadata) => Stripe.Types.metadata(),
                 optional(:nickname) => String.t(),
                 optional(:tiers) => Stripe.List.t(map),
                 optional(:tiers_mode) => String.t(),
                 optional(:transform_usage) => map,
                 optional(:trial_period_days) => non_neg_integer,
                 optional(:usage_type) => String.t()
               }
               | %{}
  def create(%{currency: _, interval: _, product: _} = params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint)
    |> put_params(params)
    |> put_method(:post)
    |> make_request()
  end

  @doc """
  Retrieve a plan.
  """
  @spec retrieve(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  Update a plan.

  Takes the `id` and a map of changes.
  """
  @spec update(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:active) => boolean,
                 optional(:metadata) => Stripe.Types.metadata(),
                 optional(:nickname) => String.t(),
                 optional(:product) => Stripe.id() | Stripe.Product.t(),
                 optional(:trial_period_days) => non_neg_integer
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
  Delete a plan.
  """
  @spec delete(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def delete(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:delete)
    |> make_request()
  end

  @doc """
  List all plans.
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:active) => boolean,
                 optional(:created) => Stripe.date_query(),
                 optional(:ending_before) => t | Stripe.id(),
                 optional(:limit) => 1..100,
                 optional(:product) => Stripe.Product.t() | Stripe.id(),
                 optional(:starting_after) => t | Stripe.id()
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
