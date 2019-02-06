defmodule Stripe.Recipient do
  @moduledoc """
  Work with Stripe recipient objects.

  Stripe API reference: https://stripe.com/docs/api#recipients
  """

  use Stripe.Entity
  import Stripe.Request

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          active_account:
            %{
              id: Stripe.id(),
              object: String.t(),
              account: Stripe.id(),
              account_holder_name: String.t(),
              account_holder_type: String.t(),
              bank_name: String.t(),
              country: String.t(),
              currency: String.t(),
              customer: Stripe.id(),
              default_for_currency: boolean,
              fingerprint: String.t(),
              last4: String.t(),
              metadata: Stripe.Types.metadata(),
              routing_number: String.t(),
              status: String.t()
            }
            | nil,
          cards: Stripe.List.t(Stripe.Card.t()),
          created: Stripe.timestamp(),
          default_card: Stripe.id() | Stripe.Card.t(),
          description: String.t() | nil,
          email: String.t() | nil,
          livemode: boolean,
          metadata: Stripe.Types.metadata(),
          migrated_to: Stripe.id() | Stripe.Account.t(),
          name: String.t() | nil,
          rolled_back_from: Stripe.id() | Stripe.Account.t(),
          type: String.t()
        }

  defstruct [
    :id,
    :object,
    :active_account,
    :cards,
    :created,
    :default_card,
    :description,
    :email,
    :livemode,
    :metadata,
    :migrated_to,
    :name,
    :rolled_back_from,
    :type
  ]

  @plural_endpoint "recipients"

  @doc """
  Create a recipient
  """
  @spec create(params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               :name => String.t(),
               :type => String.t(),
               optional(:bank_account) => Stripe.id() | Stripe.BankAccount.t(),
               optional(:recipient) => Stripe.id() | Stripe.Card.t(),
               optional(:description) => String.t(),
               optional(:email) => String.t(),
               optional(:metadata) => Stripe.Types.metadata(),
               optional(:tax_id) => String.t()
             }
  def create(%{name: _, type: _} = params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint)
    |> put_params(params)
    |> put_method(:post)
    |> make_request()
  end

  @doc """
  Retrieve a recipient.
  """
  @spec retrieve(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  Update a recipient.

  Takes the `id` and a map of changes
  """
  @spec update(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:bank_account) => Stripe.id() | Stripe.BankAccount.t(),
               optional(:card) => Stripe.id() | Stripe.Card.t(),
               optional(:default_card) => Stripe.id() | Stripe.Card.t(),
               optional(:description) => String.t(),
               optional(:email) => String.t(),
               optional(:metadata) => Stripe.Types.metadata(),
               optional(:name) => String.t(),
               optional(:tax_id) => String.t()
             }
  def update(id, params \\ %{}, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:post)
    |> put_params(params |> Map.delete(:customer))
    |> make_request()
  end

  @doc """
  Delete a recipient.
  """
  @spec delete(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def delete(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:delete)
    |> make_request()
  end

  @doc """
  List all recipients.
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:created) => Stripe.timestamp(),
               optional(:ending_before) => t | Stripe.id(),
               optional(:limit) => 1..100,
               optional(:starting_after) => t | Stripe.id(),
               optional(:type) => String.t(),
               optional(:verified) => boolean
             }
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> prefix_expansions()
    |> put_endpoint(@plural_endpoint)
    |> put_method(:get)
    |> put_params(params)
    |> make_request()
  end
end
