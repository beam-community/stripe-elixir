defmodule Stripe.CountrySpec do
  @moduledoc """
  Work with the Stripe country specs API.

  Stripe API reference: https://stripe.com/docs/api#country_specs
  """

  use Stripe.Entity
  import Stripe.Request

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          default_currency: String.t(),
          supported_bank_account_currencies: %{
            String.t() => list(String.t())
          },
          supported_payment_currencies: list(String.t()),
          supported_payment_methods: list(Stripe.Source.source_type() | String.t()),
          verification_fields: %{
            individual: %{
              minimum: list(String.t()),
              additional: list(String.t())
            },
            company: %{
              minimum: list(String.t()),
              additional: list(String.t())
            }
          }
        }

  defstruct [
    :id,
    :object,
    :default_currency,
    :supported_bank_account_currencies,
    :supported_payment_currencies,
    :supported_payment_methods,
    :verification_fields
  ]

  @plural_endpoint "country_specs"

  @doc """
  Retrieve a country spec.
  """
  @spec retrieve(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  List all country specs.
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:ending_before) => t | Stripe.id(),
                 optional(:limit) => 1..100,
                 optional(:starting_after) => t | Stripe.id()
               }
               | %{}
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint)
    |> put_method(:get)
    |> put_params(params)
    |> make_request()
  end
end
