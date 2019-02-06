defmodule Stripe.FeeRefund do
  @moduledoc """
  Work with Stripe Connect application fees refund.

  Stripe API reference: https://stripe.com/docs/api#fee_refunds
  """

  use Stripe.Entity
  import Stripe.Request

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          amount: integer,
          balance_transaction: Stripe.id() | Stripe.BalanceTransaction.t(),
          created: Stripe.timestamp(),
          currency: String.t(),
          fee: String.t(),
          metadata: Stripe.Types.metadata()
        }

  defstruct [
    :id,
    :object,
    :amount,
    :balance_transaction,
    :created,
    :currency,
    :fee,
    :metadata
  ]

  @endpoint "application_fees"

  @doc """
  Create a application fee refund
  """
  @spec create(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:amount) => pos_integer,
               optional(:metadata) => Stripe.Types.metadata()
             }
  def create(id, params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint <> "/#{id}/refunds")
    |> put_params(params)
    |> put_method(:post)
    |> make_request()
  end

  @doc """
  Retrieve a application fee refund.
  """
  @spec retrieve(Stripe.id() | t, Stripe.id() | t, Stripe.options()) ::
          {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, fee_id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint <> "/#{id}/refunds/#{fee_id}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  Update a transfer.

  Takes the `id` and a map of changes.
  """
  @spec update(Stripe.id() | t, Stripe.id() | t, params, Stripe.options()) ::
          {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:metadata) => Stripe.Types.metadata()
             }
  def update(id, fee_id, params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint <> "/#{id}/refunds/#{fee_id}")
    |> put_method(:post)
    |> put_params(params)
    |> make_request()
  end

  @doc """
  List all transfers.
  """
  @spec list(Stripe.id() | t, params, Stripe.options()) ::
          {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:ending_before) => t | Stripe.id(),
               optional(:limit) => 1..100,
               optional(:starting_after) => t | Stripe.id()
             }
  def list(id, params \\ %{}, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint <> "/#{id}/refunds")
    |> put_method(:get)
    |> put_params(params)
    |> cast_to_id([:ending_before, :starting_after])
    |> make_request()
  end
end
