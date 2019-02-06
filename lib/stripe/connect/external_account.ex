defmodule Stripe.ExternalAccount do
  @moduledoc """
  Work with Stripe external account objects.

  You can:

  - Create an external account
  - Retrieve an external account
  - Update an external account
  - Delete an external account

  Stripe API reference: https://stripe.com/docs/api#external_accounts
  """

  import Stripe.Request

  defp accounts_plural_endpoint(%{account: id}) do
    "accounts/#{id}/external_accounts"
  end

  @type t :: Stripe.BankAccount.t() | Stripe.Card.t()

  @type create_params :: %{
          default_for_currency: boolean | nil,
          external_account: String.t(),
          metadata: Stripe.Types.metadata() | nil
        }

  @doc """
  Create an external account.

  Only accepts a `token` and not a hash of values.
  """
  @spec create(map, Keyword.t()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def create(%{account: _, token: token} = params, opts \\ []) do
    endpoint = params |> accounts_plural_endpoint()

    updated_params =
      params
      |> Map.put(:external_account, token)
      |> Map.delete(:token)
      |> Map.delete(:account)

    new_request(opts)
    |> put_endpoint(endpoint)
    |> put_params(updated_params)
    |> put_method(:post)
    |> make_request()
  end

  @doc """
  Retrieve an external account.
  """
  @spec retrieve(Stripe.id() | t, map, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, %{account: _} = params, opts \\ []) do
    endpoint = params |> accounts_plural_endpoint()

    new_request(opts)
    |> put_endpoint(endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  Update an external account.
  """
  @spec update(Stripe.id() | t, map, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def update(id, %{account: _} = params, opts \\ []) do
    endpoint = params |> accounts_plural_endpoint()

    new_request(opts)
    |> put_endpoint(endpoint <> "/#{get_id!(id)}")
    |> put_method(:post)
    |> put_params(params |> Map.delete(:account))
    |> make_request()
  end

  @doc """
  Delete an external account.
  """
  @spec delete(Stripe.id() | t, map, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def delete(id, %{account: _} = params, opts \\ []) do
    endpoint = params |> accounts_plural_endpoint()

    new_request(opts)
    |> put_endpoint(endpoint <> "/#{get_id!(id)}")
    |> put_method(:delete)
    |> make_request()
  end

  @doc """
  List all external accounts.

  Takes either `:bank_account` or `:card` to determine which object to list.
  """
  @spec list(atom, params, Stripe.options()) ::
          {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params: %{
               :account => Stripe.id(),
               optional(:ending_before) => t | Stripe.id(),
               optional(:limit) => 1..100,
               optional(:starting_after) => t | Stripe.id()
             }
  def list(atom, params, opts \\ [])

  def list(:bank_account, %{account: _} = params, opts) do
    endpoint = params |> accounts_plural_endpoint()
    params = params |> Map.put(:object, "bank_account")
    do_list(endpoint, params, opts)
  end

  def list(:card, %{account: _} = params, opts) do
    endpoint = params |> accounts_plural_endpoint()
    params = params |> Map.put(:object, "card")
    do_list(endpoint, params, opts)
  end

  @spec do_list(String.t(), map, Stripe.options()) ::
          {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
  defp do_list(endpoint, params, opts) do
    new_request(opts)
    |> put_endpoint(endpoint)
    |> put_method(:get)
    |> put_params(params |> Map.delete(:account))
    |> make_request()
  end
end
