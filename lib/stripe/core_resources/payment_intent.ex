defmodule Stripe.PaymentIntent do
  @moduledoc """
  Work with [Stripe `payment_intent` objects](https://stripe.com/docs/api/payment_intents).
   You can:
  - [Create a payment_intent](https://stripe.com/docs/api/payment_intents/create)
  - [Retrieve a payment_intent](https://stripe.com/docs/api/payment_intents/retrieve)
  - [Update a payment_intent](https://stripe.com/docs/api/payment_intents/update)
  - [Confirm a payment_intent](https://stripe.com/docs/api/payment_intents/confirm)
  - [Capture a payment_intent](https://stripe.com/docs/api/payment_intents/capture)
  - [Cancel a payment_intent](https://stripe.com/docs/api/payment_intents/cancel)
  - [List all payment_intent](https://stripe.com/docs/api/payment_intents/list)
  """

  use Stripe.Entity
  import Stripe.Request
  require Stripe.Util

  @type last_payment_error :: %{
          type: String.t(),
          charge: String.t(),
          code: String.t(),
          decline_code: String.t(),
          doc_url: String.t(),
          message: String.t(),
          param: String.t(),
          payment_intent: Stripe.PaymentIntent.t() | map,
          source: Stripe.Card.t() | map
        }

  @type next_action :: %{
          redirect_to_url: redirect_to_url | nil,
          type: String.t(),
          use_stripe_sdk: map | nil
        }

  @type redirect_to_url :: %{
          return_url: String.t(),
          url: String.t()
        }

  @type transfer_data :: %{
          :destination => String.t()
        }

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          amount: non_neg_integer,
          amount_capturable: non_neg_integer,
          amount_received: non_neg_integer,
          application: Stripe.id() | nil,
          application_fee_amount: non_neg_integer | nil,
          canceled_at: Stripe.timestamp() | nil,
          cancellation_reason: String.t() | nil,
          capture_method: String.t(),
          charges: Stripe.List.t(Stripe.Charge.t()),
          client_secret: String.t(),
          confirmation_method: String.t(),
          created: Stripe.timestamp(),
          currency: String.t(),
          customer: Stripe.id() | Stripe.Customer.t() | nil,
          description: String.t() | nil,
          last_payment_error: last_payment_error | nil,
          livemode: boolean,
          metadata: Stripe.Types.metadata(),
          next_action: next_action | nil,
          on_behalf_of: Stripe.id() | Stripe.Account.t() | nil,
          payment_method_types: list(String.t()),
          receipt_email: String.t() | nil,
          review: Stripe.id() | Stripe.Review.t() | nil,
          shipping: Stripe.Types.shipping() | nil,
          source: Stripe.Card.t() | map,
          statement_descriptor: String.t() | nil,
          status: String.t(),
          transfer_data: transfer_data | nil,
          transfer_group: String.t() | nil
        }

  defstruct [
    :id,
    :object,
    :amount,
    :amount_capturable,
    :amount_received,
    :application,
    :application_fee_amount,
    :canceled_at,
    :cancellation_reason,
    :capture_method,
    :charges,
    :client_secret,
    :confirmation_method,
    :created,
    :currency,
    :customer,
    :description,
    :last_payment_error,
    :livemode,
    :metadata,
    :next_action,
    :on_behalf_of,
    :payment_method_types,
    :receipt_email,
    :review,
    :shipping,
    :source,
    :statement_descriptor,
    :status,
    :transfer_data,
    :transfer_group
  ]

  @plural_endpoint "payment_intents"

  @doc """
  Create a payment intent.
   See the [Stripe docs](https://stripe.com/docs/api/payment_intents/create).
  """
  @spec create(params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 :amount => pos_integer,
                 :currency => String.t(),
                 :payment_method_types => [String.t()],
                 optional(:application_fee_amount) => non_neg_integer,
                 optional(:capture_method) => String.t(),
                 optional(:confirm) => boolean,
                 optional(:customer) => Stripe.id() | Stripe.Customer.t(),
                 optional(:description) => String.t(),
                 optional(:metadata) => map,
                 optional(:on_behalf_of) => Stripe.id() | Stripe.Account.t(),
                 optional(:receipt_email) => String.t(),
                 optional(:return_url) => String.t(),
                 optional(:save_payment_method) => boolean,
                 optional(:shipping) => Stripe.Types.shipping(),
                 optional(:source) => Stripe.id() | Stripe.Card.t(),
                 optional(:statement_descriptor) => String.t(),
                 optional(:transfer_data) => transfer_data,
                 optional(:transfer_group) => String.t()
               }
               | %{}
  def create(params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint)
    |> put_params(params)
    |> put_method(:post)
    |> cast_path_to_id([:destination, :account])
    |> cast_to_id([:on_behalf_of, :customer, :source])
    |> make_request()
  end

  @doc """
  Retrieves the details of a PaymentIntent that has previously been created.
  Client-side retrieval using a publishable key is allowed when the client_secret is provided in the query string.
   When retrieved with a publishable key, only a subset of properties will be returned. Please refer to the payment intent object reference for more details.
   See the [Stripe docs](https://stripe.com/docs/api/payment_intents/retrieve).
  """
  @spec retrieve(Stripe.id() | t, params, Stripe.options()) ::
          {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:client_secret) => String.t()
               }
               | %{}
  def retrieve(id, params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_params(params)
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  Updates a PaymentIntent object.
   See the [Stripe docs](https://stripe.com/docs/api/payment_intents/update).
  """
  @spec update(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:amount) => non_neg_integer,
                 optional(:application_fee_amount) => non_neg_integer,
                 optional(:currency) => String.t(),
                 optional(:customer) => Stripe.id() | Stripe.Customer.t(),
                 optional(:description) => String.t(),
                 optional(:metadata) => map,
                 optional(:payment_method_types) => [Stripe.id()],
                 optional(:receipt_email) => String.t(),
                 optional(:save_payment_method) => boolean,
                 optional(:shipping) => Stripe.Types.shipping(),
                 optional(:source) => Stripe.id() | Stripe.Card.t(),
                 optional(:transfer_group) => String.t()
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
  Confirm that your customer intends to pay with current or provided source. Upon confirmation,
  the PaymentIntent will attempt to initiate a payment.
  If the selected source requires additional authentication steps, the PaymentIntent will transition to
  the requires_action status and suggest additional actions via next_source_action.
  If payment fails, the PaymentIntent will transition to the requires_payment_method status.
  If payment succeeds, the PaymentIntent will transition to the succeeded status (or requires_capture,
  if capture_method is set to manual). Read the expanded documentation to learn more about server-side confirmation.
   See the [Stripe docs](https://stripe.com/docs/api/payment_intents/confirm).
  """
  @spec confirm(Stripe.id() | t, params, Stripe.options()) ::
          {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:client_secret) => String.t(),
                 optional(:receipt_email) => String.t(),
                 optional(:return_url) => String.t(),
                 optional(:save_payment_method) => boolean,
                 optional(:shipping) => Stripe.Types.shipping(),
                 optional(:source) => Stripe.id() | Stripe.Card.t()
               }
               | %{}
  def confirm(id, params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}" <> "/confirm")
    |> put_method(:post)
    |> put_params(params)
    |> make_request()
  end

  @doc """
  Capture the funds of an existing uncaptured PaymentIntent where required_action="requires_capture".
  Uncaptured PaymentIntents will be canceled exactly seven days after they are created.
   See the [Stripe docs](https://stripe.com/docs/api/payment_intents/capture).
  """
  @spec capture(Stripe.id() | t, params, Stripe.options()) ::
          {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:amount_to_capture) => non_neg_integer,
                 optional(:application_fee_amount) => non_neg_integer
               }
               | %{}
  def capture(id, params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}/capture")
    |> put_params(params)
    |> put_method(:post)
    |> make_request()
  end

  @doc """
  A PaymentIntent object can be canceled when it is in one of these statuses: requires_payment_method,
  requires_capture, requires_confirmation, requires_action.
  Once canceled, no additional charges will be made by the PaymentIntent and any operations on the PaymentIntent will fail with an error.
  For PaymentIntents with status='requires_capture', the remaining amount_capturable will automatically be refunded.
   See the [Stripe docs](https://stripe.com/docs/api/payment_intents/cancel).
  """
  @spec cancel(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:cancellation_reason) => String.t()
               }
               | %{}
  def cancel(id, params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}" <> "/cancel")
    |> put_method(:post)
    |> put_params(params)
    |> make_request()
  end

  @doc """
  Returns a list of PaymentIntents.
   See the [Stripe docs](https://stripe.com/docs/api/payment_intents/list).
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:created) => Stripe.date_query(),
               optional(:ending_before) => t | Stripe.id(),
               optional(:limit) => 1..100,
               optional(:starting_after) => t | Stripe.id()
             }
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> prefix_expansions()
    |> put_endpoint(@plural_endpoint)
    |> put_method(:get)
    |> put_params(params)
    |> cast_to_id([:ending_before, :starting_after])
    |> make_request()
  end
end
