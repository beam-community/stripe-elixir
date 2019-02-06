defmodule Stripe.Dispute do
  @moduledoc """
  Work with Stripe disputes.

  You can:

  - Retrieve a dispute
  - Update a dispute
  - Close a dispute
  - List disputes

  Stripe API reference: https://stripe.com/docs/api#disputes
  """

  use Stripe.Entity
  import Stripe.Request

  @type dispute_evidence :: %{
          access_activity_log: String.t() | nil,
          billing_address: String.t() | nil,
          cancellation_policy: Stripe.id() | Stripe.FileUpload.t() | nil,
          cancellation_policy_disclosure: String.t() | nil,
          cancellation_rebuttal: String.t() | nil,
          dispute_communication: Stripe.id() | Stripe.FileUpload.t() | nil,
          dispute_email_address: String.t() | nil,
          dispute_name: String.t() | nil,
          dispute_purchase_ip: String.t() | nil,
          dispute_signature: Stripe.id() | Stripe.FileUpload.t() | nil,
          duplicate_charge_documentation: Stripe.id() | Stripe.FileUpload.t() | nil,
          duplicate_charge_explanation: String.t() | nil,
          duplicate_charge_id: Stripe.id() | nil,
          product_description: String.t() | nil,
          receipt: Stripe.id() | Stripe.FileUpload.t() | nil,
          refund_policy: Stripe.id() | Stripe.FileUpload.t() | nil,
          refund_policy_disclosure: String.t() | nil,
          refund_refusal_explanation: String.t() | nil,
          service_date: String.t() | nil,
          service_documentation: Stripe.id() | Stripe.FileUpload.t() | nil,
          shipping_address: String.t() | nil,
          shipping_carrier: String.t() | nil,
          shipping_date: String.t() | nil,
          shipping_documentation: Stripe.id() | Stripe.FileUpload.t() | nil,
          shipping_tracking_number: Stripe.id() | Stripe.FileUpload.t() | nil,
          uncategorized_file: Stripe.id() | Stripe.FileUpload.t() | nil,
          uncategorized_text: String.t() | nil
        }

  @type dispute_evidence_details :: %{
          due_by: Stripe.timestamp() | nil,
          has_evidence: boolean,
          past_due: boolean,
          submission_count: integer
        }

  @type dispute_reason :: String.t()

  @type dispute_status :: String.t()

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          amount: integer,
          balance_transactions: list(Stripe.BalanceTransaction.t()),
          charge: Stripe.id() | Stripe.Charge.t(),
          created: Stripe.timestamp(),
          currency: String.t(),
          evidence: dispute_evidence,
          evidence_details: dispute_evidence_details,
          is_charge_refundable: boolean,
          livemode: boolean,
          metadata: %{
            optional(String.t()) => String.t()
          },
          reason: dispute_reason,
          status: dispute_status
        }

  defstruct [
    :id,
    :object,
    :amount,
    :balance_transactions,
    :charge,
    :created,
    :currency,
    :evidence,
    :evidence_details,
    :is_charge_refundable,
    :livemode,
    :metadata,
    :reason,
    :status
  ]

  @plural_endpoint "disputes"

  @doc """
  Retrieve a dispute.
  """
  @spec retrieve(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  Update a dispute.
  """
  @spec update(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:evidence) => dispute_evidence,
                 optional(:metadata) => Stripe.Types.metadata(),
                 optional(:submit) => boolean
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
  Close a dispute.
  """
  @spec close(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def close(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}" <> "/close")
    |> put_method(:post)
    |> make_request()
  end

  @doc """
  List all disputes.
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:created) => String.t() | Stripe.date_query(),
                 optional(:ending_before) => t | Stripe.id(),
                 optional(:limit) => 1..100,
                 optional(:starting_after) => t | Stripe.id()
               }
               | %{}
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> prefix_expansions()
    |> put_endpoint(@plural_endpoint)
    |> put_method(:get)
    |> put_params(params)
    |> cast_to_id([:created, :ending_before, :starting_after])
    |> make_request()
  end
end
