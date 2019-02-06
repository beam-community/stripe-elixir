defmodule Stripe.Payout do
  @moduledoc """
  Work with Stripe payouts.

  Stripe API reference: https://stripe.com/docs/api#payouts
  """

  use Stripe.Entity
  import Stripe.Request

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          amount: integer,
          arrival_date: Stripe.timestamp(),
          automatic: boolean,
          balance_transaction: Stripe.id() | Stripe.BalanceTransaction.t() | nil,
          created: Stripe.timestamp(),
          currency: String.t(),
          deleted: boolean | nil,
          description: String.t() | nil,
          destination: Stripe.id() | Stripe.Card.t() | Stripe.BankAccount.t() | String.t() | nil,
          failure_balance_transaction: Stripe.id() | Stripe.BalanceTransaction.t() | nil,
          failure_code: String.t() | nil,
          failure_message: String.t() | nil,
          livemode: boolean,
          metadata: Stripe.Types.metadata(),
          method: String.t(),
          source_type: String.t(),
          statement_descriptor: String.t() | nil,
          status: String.t(),
          type: String.t()
        }

  defstruct [
    :id,
    :object,
    :amount,
    :arrival_date,
    :automatic,
    :balance_transaction,
    :created,
    :currency,
    :deleted,
    :description,
    :destination,
    :failure_balance_transaction,
    :failure_code,
    :failure_message,
    :livemode,
    :metadata,
    :method,
    :source_type,
    :statement_descriptor,
    :status,
    :type
  ]

  @plural_endpoint "payouts"

  @doc """
  Create a payout.

  If your API key is in test mode, the supplied payment source (e.g., card) won't actually be
  payoutd, though everything else will occur as if in live mode.
  (Stripe assumes that the payout would have completed successfully).

  See the [Stripe docs](https://stripe.com/docs/api#create_payout).
  """
  @spec create(params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 :amount => pos_integer,
                 :currency => String.t(),
                 optional(:description) => String.t(),
                 optional(:destination) =>
                   Stripe.id() | Stripe.Card.t() | Stripe.BankAccount.t() | String.t(),
                 optional(:metadata) => Stripe.Types.metadata(),
                 optional(:method) => String.t(),
                 optional(:source_type) => String.t(),
                 optional(:statement_descriptor) => String.t()
               }
               | %{}
  def create(params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint)
    |> put_params(params)
    |> put_method(:post)
    |> make_request()
  end

  @doc """
  Retrieve a payout.

  See the [Stripe docs](https://stripe.com/docs/api#retrieve_payout).
  """
  @spec retrieve(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  Update a payout.

  Updates the specified payout by setting the values of the parameters passed. Any parameters
  not provided will be left unchanged.

  This request accepts only the `:payout` or `:metadata`.

  The payout to be updated may either be passed in as a struct or an ID.

  See the [Stripe docs](https://stripe.com/docs/api#update_payout).
  """
  @spec update(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:metadata) => Stripe.Types.metadata()
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
  List all payouts.

  Returns a list of payouts. The payouts are returned in sorted order,
  with the most recent payouts appearing first.

  See the [Stripe docs](https://stripe.com/docs/api#list_payouts).
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:arrival_date) => Stripe.date_query(),
                 optional(:created) => Stripe.date_query(),
                 optional(:destination) => String.t(),
                 optional(:ending_before) => t | Stripe.id(),
                 optional(:limit) => 1..100,
                 optional(:starting_after) => t | Stripe.id(),
                 optional(:status) => String.t()
               }
               | %{}
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> prefix_expansions()
    |> put_endpoint(@plural_endpoint)
    |> put_method(:get)
    |> put_params(params)
    |> cast_to_id([:ending_before, :starting_after])
    |> make_request()
  end

  @doc """
  Cancel a payout.

  See the [Stripe docs](https://stripe.com/docs/api#cancel_payout).
  """
  @spec cancel(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def cancel(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}" <> "/cancel")
    |> put_method(:post)
    |> make_request()
  end
end
