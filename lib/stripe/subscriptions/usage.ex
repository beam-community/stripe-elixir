defmodule Stripe.SubscriptionItem.Usage do
  @moduledoc """
  Work with Stripe usage record objects.

  Stripe API reference: https://stripe.com/docs/api/usage_records
  """

  use Stripe.Entity
  import Stripe.Request

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          invoice: Stripe.id() | nil,
          livemode: boolean,
          quantity: non_neg_integer,
          subscription_item: Stripe.id() | Stripe.SubscriptionItem.t(),
          timestamp: Stripe.timestamp()
        }

  defstruct [
    :id,
    :object,
    :invoice,
    :livemode,
    :quantity,
    :subscription_item,
    :timestamp
  ]

  @plural_endpoint "subscription_items"

  @doc """
  Creates a usage record for a specified subscription item id and date, and fills it with a quantity.
  """
  def create(id, params, opts \\ [])

  @doc """
  Creates a usage record for a specified subscription item id and date, and fills it with a quantity.
  """
  @spec create(Stripe.id(), params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               :quantity => float | pos_integer | 0,
               :timestamp => Stripe.timestamp() | non_neg_integer,
               optional(:action) => String.t()
             }
  def create(id, params, opts) do
    new_request(opts)
    |> put_endpoint("#{@plural_endpoint}/#{id}/usage_records")
    |> put_method(:post)
    |> put_params(params)
    |> make_request()
  end

  @doc """
  List all subscription item period summaries
  """
  @spec list(Stripe.id(), params, Stripe.options()) ::
          {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:ending_before) => t | Stripe.id(),
               optional(:limit) => 1..100,
               optional(:starting_after) => t | Stripe.id()
             }
  def list(id, params \\ %{}, opts \\ []) do
    new_request(opts)
    |> put_endpoint("#{@plural_endpoint}/#{id}/usage_record_summaries")
    |> put_method(:get)
    |> put_params(params)
    |> cast_to_id([:ending_before, :starting_after])
    |> make_request()
  end
end
