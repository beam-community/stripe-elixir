defmodule Stripe.TransferReversal do
  @moduledoc """
  Work with Stripe transfer_reversal objects.

  Stripe API reference: https://stripe.com/docs/api#transfer_reversal_object
  """

  use Stripe.Entity
  import Stripe.Request

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          amount: integer,
          balance_transaction: String.t() | Stripe.BalanceTransaction.t(),
          created: Stripe.timestamp(),
          currency: String.t(),
          description: boolean,
          metadata: Stripe.Types.metadata(),
          transfer: Stripe.id() | Stripe.Transfer.t()
        }

  defstruct [
    :id,
    :object,
    :amount,
    :balance_transaction,
    :created,
    :currency,
    :description,
    :metadata,
    :transfer
  ]

  @endpoint "transfers"

  @doc """
  Create a transfer reversal
  """
  @spec create(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:amount) => pos_integer,
               optional(:description) => String.t(),
               optional(:metadata) => Stripe.Types.metadata(),
               optional(:refund_application_fee) => boolean
             }
  def create(id, params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint <> "/#{id}/reversals")
    |> put_params(params)
    |> put_method(:post)
    |> make_request()
  end

  @doc """
  Retrieve a transfer reversal.
  """
  @spec retrieve(Stripe.id() | t, Stripe.id() | t, Stripe.options()) ::
          {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, reversal_id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint <> "/#{id}/reversals/#{reversal_id}")
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
  def update(id, reversal_id, params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint <> "/#{id}/reversals/#{reversal_id}")
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
    |> put_endpoint(@endpoint <> "/#{id}/reversals")
    |> put_method(:get)
    |> put_params(params)
    |> cast_to_id([:ending_before, :starting_after])
    |> make_request()
  end
end
