defmodule Stripe.Invoiceitem do
  @moduledoc """
  Work with Stripe invoiceitem objects.

  Stripe API reference: https://stripe.com/docs/api#invoiceitems

  Note: this module is named `Invoiceitem` and not `InvoiceItem` on purpose, to
  match the Stripe terminology of `invoiceitem`.
  """

  use Stripe.Entity
  import Stripe.Request

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          amount: integer,
          currency: String.t(),
          customer: Stripe.id() | Stripe.Customer.t(),
          date: Stripe.timestamp(),
          description: String.t(),
          discountable: boolean,
          invoice: Stripe.id() | Stripe.Invoice.t(),
          livemode: boolean,
          metadata: Stripe.Types.metadata(),
          period: %{
            start: Stripe.timestamp(),
            end: Stripe.timestamp()
          },
          plan: Stripe.Plan.t() | nil,
          proration: boolean,
          quantity: integer,
          subscription: Stripe.id() | Stripe.Subscription.t() | nil,
          subscription_item: Stripe.id() | Stripe.SubscriptionItem.t() | nil,
          unit_amount: integer
        }

  defstruct [
    :id,
    :object,
    :amount,
    :currency,
    :customer,
    :date,
    :description,
    :discountable,
    :invoice,
    :livemode,
    :metadata,
    :period,
    :plan,
    :proration,
    :quantity,
    :subscription,
    :subscription_item,
    :unit_amount
  ]

  @plural_endpoint "invoiceitems"

  @doc """
  Create an invoiceitem.
  """
  @spec create(params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:amount) => integer,
               :currency => String.t(),
               :customer => Stripe.id() | Stripe.Customer.t(),
               optional(:description) => String.t(),
               optional(:discountable) => boolean,
               optional(:invoice) => Stripe.id() | Stripe.Invoice.t(),
               optional(:metadata) => Stripe.Types.metadata(),
               optional(:quantity) => integer,
               optional(:subscription) => Stripe.id() | Stripe.Subscription.t(),
               optional(:unit_amount) => integer
             } | %{}
  def create(params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint)
    |> put_params(params)
    |> put_method(:post)
    |> cast_to_id([:subscription])
    |> make_request()
  end

  @doc """
  Retrieve an invoiceitem.
  """
  @spec retrieve(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  Update an invoiceitem.

  Takes the `id` and a map of changes.
  """
  @spec update(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:amount) => integer,
               optional(:description) => String.t(),
               optional(:discountable) => boolean,
               optional(:metadata) => Stripe.Types.metadata(),
               optional(:quantity) => integer,
               optional(:unit_amount) => integer
             } | %{}
  def update(id, params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:post)
    |> put_params(params)
    |> make_request()
  end

  @doc """
  Delete and invoiceitem

  Takes the `id` of the invoiceitem to delete.
  """
  @spec delete(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def delete(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:delete)
    |> make_request()
  end

  @doc """
  List all invoiceitems.
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:created) => Stripe.timestamp(),
               optional(:customer) => Stripe.id() | Stripe.Customer.t(),
               optional(:ending_before) => t | Stripe.id(),
               optional(:invoice) => Stripe.id() | Stripe.Invoice.t(),
               optional(:limit) => 1..100,
               optional(:starting_after) => t | Stripe.id()
             } | %{}
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> prefix_expansions()
    |> put_endpoint(@plural_endpoint)
    |> put_method(:get)
    |> put_params(params)
    |> cast_to_id([:customer, :ending_before, :starting_after])
    |> make_request()
  end
end
