defmodule Stripe.ApplicationFee do
  @moduledoc """
  Work with Stripe Connect application fees.

  Stripe API reference: https://stripe.com/docs/api#application_fees
  """

  use Stripe.Entity
  import Stripe.Request

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          account: Stripe.id() | Stripe.Account.t(),
          amount: integer,
          amount_refunded: integer,
          application: Stripe.id(),
          balance_transaction: Stripe.id() | Stripe.BalanceTransaction.t(),
          charge: Stripe.id() | Stripe.Charge.t(),
          created: Stripe.timestamp(),
          currency: String.t(),
          livemode: boolean,
          originating_transaction: Stripe.id() | Stripe.Charge.t(),
          refunded: boolean,
          refunds: Stripe.List.t(Stripe.FeeRefund.t())
        }

  defstruct [
    :id,
    :object,
    :account,
    :amount,
    :amount_refunded,
    :application,
    :balance_transaction,
    :charge,
    :created,
    :currency,
    :livemode,
    :originating_transaction,
    :refunded,
    :refunds
  ]

  @endpoint "application_fees"

  @doc """
  Retrieves the details of the application fees
  """
  @spec retrieve(Stripe.id()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id) do
    new_request()
    |> put_endpoint(@endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  List all application fees
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:charge) => Stripe.id(),
                 optional(:created) => Stripe.date_query(),
                 optional(:ending_before) => t | Stripe.id(),
                 optional(:limit) => 1..100,
                 optional(:starting_after) => t | Stripe.id()
               }
               | %{}
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> prefix_expansions()
    |> put_endpoint(@endpoint)
    |> put_method(:get)
    |> put_params(params)
    |> cast_to_id([:ending_before, :starting_after])
    |> make_request()
  end
end
