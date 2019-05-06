defmodule Stripe.BankAccount do
  @moduledoc """
  Work with Stripe bank account objects.

  Stripe API reference: https://stripe.com/docs/api#bank_accounts
  """

  use Stripe.Entity
  import Stripe.Request

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          account: Stripe.id() | Stripe.Account.t() | nil,
          account_holder_name: String.t() | nil,
          account_holder_type: String.t() | nil,
          bank_name: String.t() | nil,
          country: String.t(),
          currency: String.t(),
          customer: Stripe.id() | Stripe.Customer.t() | nil,
          default_for_currency: boolean | nil,
          deleted: boolean | nil,
          fingerprint: String.t() | nil,
          last4: String.t(),
          metadata: Stripe.Types.metadata() | nil,
          routing_number: String.t() | nil,
          status: String.t()
        }

  defstruct [
    :id,
    :object,
    :account,
    :account_holder_name,
    :account_holder_type,
    :bank_name,
    :country,
    :currency,
    :customer,
    :default_for_currency,
    :deleted,
    :fingerprint,
    :last4,
    :metadata,
    :routing_number,
    :status
  ]

  defp plural_endpoint(%{customer: id}) do
    "customers/" <> id <> "/sources"
  end

  @doc """
  Create a bank account.
  """
  @spec create(params, Keyword.t()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               :customer => Stripe.id() | Stripe.Customer.t(),
               :source => Stripe.id() | Stripe.Source.t(),
               optional(:metadata) => Stripe.Types.metadata()
             }
  def create(%{customer: _, source: _} = params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(params |> plural_endpoint())
    |> put_params(params |> Map.delete(:customer))
    |> put_method(:post)
    |> make_request()
  end

  @doc """
  Retrieve a bank account.
  """
  @spec retrieve(Stripe.id() | t, map, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, %{customer: _} = params, opts \\ []) do
    endpoint = params |> plural_endpoint()

    new_request(opts)
    |> put_endpoint(endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  Update a bank account.
  """
  @spec update(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               :customer => Stripe.id() | Stripe.Customer.t(),
               optional(:metadata) => Stripe.Types.metadata(),
               optional(:account_holder_name) => String.t(),
               optional(:account_holder_type) => String.t()
             }
  def update(id, %{customer: _} = params, opts \\ []) do
    endpoint = params |> plural_endpoint()

    new_request(opts)
    |> put_endpoint(endpoint <> "/#{get_id!(id)}")
    |> put_method(:post)
    |> put_params(params |> Map.delete(:customer))
    |> make_request()
  end

  @doc """
  Delete a bank account.
  """
  @spec delete(Stripe.id() | t, map, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def delete(id, %{customer: _} = params, opts \\ []) do
    endpoint = params |> plural_endpoint()

    new_request(opts)
    |> put_endpoint(endpoint <> "/#{get_id!(id)}")
    |> put_method(:delete)
    |> make_request()
  end

  @doc """
  Verify a bank account.
  """
  @spec verify(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               :customer => Stripe.id() | Stripe.Customer.t(),
               optional(:amounts) => list(integer),
               optional(:verification_method) => String.t()
             }
  def verify(id, %{customer: _} = params, opts \\ []) do
    endpoint = params |> plural_endpoint()

    new_request(opts)
    |> put_endpoint(endpoint <> "/#{get_id!(id)}/verify")
    |> put_method(:post)
    |> put_params(params |> Map.delete(:customer))
    |> make_request()
  end

  @doc """
  List all bank accounts.
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params: %{
               :customer => Stripe.id() | Stripe.Customer.t(),
               optional(:ending_before) => t | Stripe.id(),
               optional(:limit) => 1..100,
               optional(:starting_after) => t | Stripe.id()
             }
  def list(%{customer: _} = params, opts \\ []) do
    endpoint = params |> plural_endpoint()
    params = params |> Map.put(:object, "bank_account")

    new_request(opts)
    |> put_endpoint(endpoint)
    |> put_method(:get)
    |> put_params(params |> Map.delete(:customer))
    |> make_request()
  end
end
