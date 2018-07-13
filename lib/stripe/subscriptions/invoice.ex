defmodule Stripe.Invoice do
  @moduledoc """
  Work with Stripe invoice objects.

  You can:

  - Create an invoice
  - Retrieve an invoice
  - Update an invoice

  Does not take options yet.

  Stripe API reference: https://stripe.com/docs/api#invoice
  """

  use Stripe.Entity
  import Stripe.Request

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          amount_due: integer,
          amount_paid: integer,
          amount_remaining: integer,
          application_fee: integer | nil,
          attempt_count: non_neg_integer,
          attempted: boolean,
          auto_advance: boolean,
          billing: String.t() | nil,
          billing_reason: String.t() | nil,
          charge: Stripe.id() | Stripe.Charge.t() | nil,
          closed: boolean,
          currency: String.t(),
          customer: Stripe.id() | Stripe.Customer.t(),
          date: Stripe.timestamp(),
          description: String.t() | nil,
          discount: Stripe.Discount.t() | nil,
          due_date: Stripe.timestamp() | nil,
          ending_balance: integer | nil,
          forgiven: boolean,
          hosted_invoice_url: String.t() | nil,
          invoice_pdf: String.t() | nil,
          lines: Stripe.List.t(Stripe.LineItem.t()),
          livemode: boolean,
          metadata: Stripe.Types.metadata() | nil,
          next_payment_attempt: Stripe.timestamp() | nil,
          number: String.t() | nil,
          paid: boolean,
          period_end: Stripe.timestamp(),
          period_start: Stripe.timestamp(),
          receipt_number: String.t() | nil,
          starting_balance: integer,
          statement_descriptor: String.t() | nil,
          subscription: Stripe.id() | Stripe.Subscription.t() | nil,
          subscription_proration_date: Stripe.timestamp(),
          subtotal: integer,
          tax: integer | nil,
          tax_percent: integer | nil,
          total: integer,
          webhooks_delivered_at: Stripe.timestamp() | nil
        }

  defstruct [
    :id,
    :object,
    :amount_due,
    :amount_paid,
    :amount_remaining,
    :application_fee,
    :attempt_count,
    :attempted,
    :auto_advance,
    :billing,
    :billing_reason,
    :charge,
    :closed,
    :currency,
    :customer,
    :date,
    :description,
    :discount,
    :due_date,
    :ending_balance,
    :forgiven,
    :hosted_invoice_url,
    :invoice_pdf,
    :lines,
    :livemode,
    :metadata,
    :next_payment_attempt,
    :number,
    :paid,
    :period_end,
    :period_start,
    :receipt_number,
    :starting_balance,
    :statement_descriptor,
    :subscription,
    :subscription_proration_date,
    :subtotal,
    :tax,
    :tax_percent,
    :total,
    :webhooks_delivered_at
  ]

  @plural_endpoint "invoices"

  @doc """
  Create an invoice.
  """
  @spec create(params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:application_fee) => integer,
               optional(:billing) => String.t(),
               :customer => Stripe.id() | Stripe.Customer.t(),
               optional(:days_until_due) => integer,
               optional(:description) => String.t(),
               optional(:due_date) => String.timestamp(),
               optional(:metadata) => Stripe.Types.metadata(),
               optional(:statement_descriptor) => String.t(),
               optional(:subscription) => Stripe.id() | Stripe.Subscription.t(),
               optional(:tax_percent) => integer
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
  Retrieve an invoice.
  """
  @spec retrieve(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  Update an invoice.

  Takes the `id` and a map of changes.
  """
  @spec update(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:application_fee) => integer,
               optional(:closed) => boolean,
               optional(:days_until_due) => integer,
               optional(:description) => String.t(),
               optional(:due_date) => String.timestamp(),
               optional(:forgiven) => boolean,
               optional(:metadata) => Stripe.Types.metadata(),
               optional(:paid) => boolean,
               optional(:statement_descriptor) => String.t(),
               optional(:tax_percent) => integer
             } | %{}
  def update(id, params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:post)
    |> put_params(params)
    |> make_request()
  end

  @doc """
  Retrieve an upcoming invoice.
  """
  @spec upcoming(map, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def upcoming(params = %{customer: _customer}, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/upcoming")
    |> put_method(:get)
    |> put_params(params)
    |> make_request()
  end

  @doc """
  List all invoices.
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:billing) => String.t(),
               optional(:customer) => Stripe.id() | Stripe.Customer.t(),
               optional(:date) => Stripe.date_query(),
               optional(:due_date) => String.timestamp(),
               optional(:ending_before) => t | Stripe.id(),
               optional(:limit) => 1..100,
               optional(:starting_after) => t | Stripe.id(),
               optional(:subscription) => Stripe.id() | Stripe.Subscription.t()
             } | %{}
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint)
    |> put_method(:get)
    |> put_params(params)
    |> cast_to_id([:customer, :ending_before, :starting_after, :subscription])
    |> make_request()
  end

  @doc """
  Pay an invoice.
  """
  @spec pay(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               :id => String.t(),
               optional(:forgive) => boolean,
               optional(:source) => Stripe.id() | Stripe.Source.t() | nil
             } | %{}
  def pay(id, params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}/pay")
    |> put_method(:post)
    |> put_params(params)
    |> cast_to_id([:source])
    |> make_request()
  end
end
