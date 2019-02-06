defmodule Stripe.OrderReturn do
  @moduledoc """
  Work with Stripe order returns.

  Stripe API reference: https://stripe.com/docs/api#order_return_object
  """

  use Stripe.Entity
  import Stripe.Request

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          amount: pos_integer,
          created: Stripe.timestamp(),
          currency: String.t(),
          items: Stripe.List.t(Stripe.OrderItem.t()),
          livemode: boolean,
          order: Stripe.id() | Stripe.Order.t() | nil,
          refund: Stripe.id() | Stripe.Refund.t() | nil
        }

  defstruct [
    :id,
    :object,
    :amount,
    :created,
    :currency,
    :items,
    :livemode,
    :order,
    :refund
  ]

  @plural_endpoint "order_returns"

  @doc """
  Retrieve a return.
  """
  @spec retrieve(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  List all returns.
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:created) => Stripe.date_query(),
               optional(:ending_before) => t | Stripe.id(),
               optional(:ids) => Stripe.List.t(Stripe.id()),
               optional(:limit) => 1..100,
               optional(:order) => Stripe.Order.t(),
               optional(:starting_after) => t | Stripe.id()
             }
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint)
    |> put_method(:get)
    |> put_params(params)
    |> make_request()
  end
end
