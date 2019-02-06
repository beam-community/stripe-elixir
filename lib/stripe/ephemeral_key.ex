defmodule Stripe.EphemeralKey do
  @moduledoc """
  Work with Stripe EphemeralKey objects.

  You can:

  - Create a ephemeral key

  Does not yet render lists or take options.

  Does not have an official API docs endpoint,
  but is required for iOS and Android SDK functionality.

  Explained in
  https://stripe.com/docs/mobile/ios/standard#prepare-your-api
  https://stripe.com/docs/mobile/android/customer-information#prepare-your-api

  Stripe API reference: https://stripe.com/docs/api#customer
  """

  import Stripe.Request

  defstruct [
    :id,
    :object,
    :created,
    :expires,
    :secret,
    :associated_objects
  ]

  @type t :: %__MODULE__{}

  @plural_endpoint "ephemeral_keys"

  @doc """
  Create an ephemeral key.
  """
  @spec create(params, String.t(), Keyword.t()) :: {:ok, t} | {:error, %Stripe.Error{}}
        when params: %{
               :customer => Stripe.id()
             }
  def create(params, api_version, opts \\ []) do
    new_request(opts, %{"Stripe-Version": api_version})
    |> put_endpoint(@plural_endpoint)
    |> put_params(params)
    |> put_method(:post)
    |> make_request()
  end
end
