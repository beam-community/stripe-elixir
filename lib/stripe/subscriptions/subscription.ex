defmodule Stripe.Subscription do
  @moduledoc """
  Work with Stripe subscription objects.

  You can:

  - Create a subscription
  - Retrieve a subscription
  - Update a subscription
  - Delete a subscription

  Stripe API reference: https://stripe.com/docs/api#subscription
  """

  use Stripe.Entity
  import Stripe.Request

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          application_fee_percent: float | nil,
          automatic_tax: map,
          billing: String.t() | nil,
          billing_cycle_anchor: Stripe.timestamp() | nil,
          cancel_at_period_end: boolean,
          canceled_at: Stripe.timestamp() | nil,
          created: Stripe.timestamp(),
          current_period_end: Stripe.timestamp() | nil,
          current_period_start: Stripe.timestamp() | nil,
          customer: Stripe.id() | Stripe.Customer.t(),
          days_until_due: integer | nil,
          discount: Stripe.Discount.t() | nil,
          ended_at: Stripe.timestamp() | nil,
          items: Stripe.List.t(Stripe.SubscriptionItem.t()),
          livemode: boolean,
          metadata: Stripe.Types.metadata(),
          plan: Stripe.Plan.t() | nil,
          quantity: integer | nil,
          start: Stripe.timestamp(),
          status: String.t(),
          tax_percent: float | nil,
          trial_end: Stripe.timestamp() | nil,
          trial_start: Stripe.timestamp() | nil
        }

  defstruct [
    :id,
    :object,
    :application_fee_percent,
    :automatic_tax,
    :billing,
    :billing_cycle_anchor,
    :cancel_at_period_end,
    :canceled_at,
    :created,
    :current_period_end,
    :current_period_start,
    :customer,
    :days_until_due,
    :discount,
    :ended_at,
    :items,
    :livemode,
    :metadata,
    :plan,
    :quantity,
    :start,
    :status,
    :tax_percent,
    :trial_end,
    :trial_start
  ]

  @plural_endpoint "subscriptions"

  @doc """
  Create a subscription.
  """
  @spec create(params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               :customer => Stripe.id() | Stripe.Customer.t(),
               optional(:application_fee_percent) => integer,
               optional(:billing) => String.t(),
               optional(:billing_cycle_anchor) => Stripe.timestamp(),
               optional(:coupon) => Stripe.id() | Stripe.Coupon.t(),
               optional(:days_until_due) => non_neg_integer,
               optional(:items) => [
                 %{
                   :plan => Stripe.id() | Stripe.Plan.t(),
                   optional(:quantity) => non_neg_integer
                 }
               ],
               optional(:metadata) => Stripe.Types.metadata(),
               optional(:prorate) => boolean,
               optional(:tax_percent) => float,
               optional(:trial_end) => Stripe.timestamp(),
               optional(:trial_from_plan) => boolean,
               optional(:trial_period_days) => non_neg_integer
             }
  def create(%{customer: _} = params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint)
    |> put_params(params)
    |> put_method(:post)
    |> cast_to_id([:coupon, :customer])
    |> make_request()
  end

  @doc """
  Retrieve a subscription.
  """
  @spec retrieve(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  Update a subscription.

  Takes the `id` and a map of changes.
  """
  @spec update(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:application_fee_percent) => float,
               optional(:billing) => String.t(),
               optional(:billing_cycle_anchor) => Stripe.timestamp(),
               optional(:cancel_at_period_end) => boolean(),
               optional(:coupon) => Stripe.id() | Stripe.Coupon.t(),
               optional(:days_until_due) => non_neg_integer,
               optional(:items) => [
                 %{
                   :plan => Stripe.id() | Stripe.Plan.t(),
                   optional(:quantity) => non_neg_integer
                 }
               ],
               optional(:metadata) => Stripe.Types.metadata(),
               optional(:prorate) => boolean,
               optional(:proration_date) => Stripe.timestamp(),
               optional(:tax_percent) => float,
               optional(:trial_end) => Stripe.timestamp(),
               optional(:trial_from_plan) => boolean
             }
  def update(id, params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:post)
    |> put_params(params)
    |> cast_to_id([:coupon])
    |> make_request()
  end

  @doc """
  Delete a subscription.

  Takes the subscription `id` or a `Stripe.Subscription` struct.
  """
  @spec delete(Stripe.id() | t) :: {:ok, t} | {:error, Stripe.Error.t()}
  def delete(id), do: delete(id, [])

  @doc """
  Delete a subscription.

  Takes the subscription `id` and an optional map of `params`.

  ### Deprecated Usage

  Passing a map with `at_period_end: true` to `Subscription.delete/2`
  is deprecated.  Use `Subscription.update/2` with
  `cancel_at_period_end: true` instead.
  """
  @deprecated "Use Stripe.Subscription.update/2 with `cancel_at_period_end: true`"
  @spec delete(Stripe.id() | t, %{at_period_end: true}) :: {:ok, t} | {:error, Stripe.Error.t()}
  def delete(id, %{at_period_end: true}), do: update(id, %{cancel_at_period_end: true})

  @spec delete(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def delete(id, opts) when is_list(opts) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:delete)
    |> make_request()
  end

  @doc """
  DEPRECATED: Use `Subscription.update/3` with `cancel_at_period_end: true` instead.
  """
  @deprecated "Use Stripe.Subscription.update/3 with `cancel_at_period_end: true`"
  @spec delete(Stripe.id() | t, %{at_period_end: true}, Stripe.options()) ::
          {:ok, t} | {:error, Stripe.Error.t()}
  def delete(id, %{at_period_end: true}, opts) when is_list(opts),
    do: update(id, %{cancel_at_period_end: true}, opts)

  @doc """
  List all subscriptions.
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:billing) => String.t(),
               optional(:created) => Stripe.date_query(),
               optional(:customer) => Stripe.Customer.t() | Stripe.id(),
               optional(:ending_before) => t | Stripe.id(),
               optional(:limit) => 1..100,
               optional(:plan) => Stripe.Plan.t() | Stripe.id(),
               optional(:starting_after) => t | Stripe.id(),
               optional(:status) => String.t()
             }
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> prefix_expansions()
    |> put_endpoint(@plural_endpoint)
    |> put_method(:get)
    |> put_params(params)
    |> cast_to_id([:customer, :ending_before, :plan, :starting_after])
    |> make_request()
  end

  @doc """
  Deletes the discount on a subscription.
  """
  @spec delete_discount(Stripe.id() | t, Stripe.options()) ::
          {:ok, t} | {:error, Stripe.Error.t()}
  def delete_discount(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}/discount")
    |> put_method(:delete)
    |> make_request()
  end
end
