defmodule Stripe.Subscription do
  @moduledoc """
  Work with Stripe subscription objects.

  You can:

  - Create a subscription
  - Retrieve a subscription
  - Update a subscription
  - Delete a subscription

  Does not yet render lists or take options.

  Stripe API reference: https://stripe.com/docs/api#subscription

  ```
  {
    "id": "sub_A5GH4y0tqOZorL",
    "object": "subscription",
    "application_fee_percent": null,
    "cancel_at_period_end": false,
    "canceled_at": 1486599980,
    "created": 1486599925,
    "current_period_end": 1489019125,
    "current_period_start": 1486599925,
    "customer": "cus_A5GEGcroKA82CE",
    "discount": null,
    "ended_at": 1486599980,
    "items": {
      "object": "list",
      "data": [
        {
          "id": "si_19l5kX2eZvKYlo2COV9VLK3B",
          "object": "subscription_item",
          "created": 1486599925,
          "plan": {
            "id": "gold-extended-3221748186322061931",
            "object": "plan",
            "amount": 5000,
            "created": 1486599923,
            "currency": "usd",
            "interval": "month",
            "interval_count": 1,
            "livemode": false,
            "metadata": {
            },
            "name": "Bronze complete",
            "statement_descriptor": null,
            "trial_period_days": null
          },
          "quantity": 1
        }
      ],
      "has_more": false,
      "total_count": 1,
      "url": "/v1/subscription_items?subscription=sub_A5GH4y0tqOZorL"
    },
    "livemode": false,
    "metadata": {
    },
    "plan": {
      "id": "gold-extended-3221748186322061931",
      "object": "plan",
      "amount": 5000,
      "created": 1486599923,
      "currency": "usd",
      "interval": "month",
      "interval_count": 1,
      "livemode": false,
      "metadata": {
      },
      "name": "Bronze complete",
      "statement_descriptor": null,
      "trial_period_days": null
    },
    "quantity": 1,
    "start": 1486599925,
    "status": "canceled",
    "tax_percent": null,
    "trial_end": null,
    "trial_start": null
  }
  ```
  """

  @type t :: %__MODULE__{}

  defstruct [
    :id, :object,
    :application_fee_percent, :cancel_at_period_end, :canceled_at,
    :created, :current_period_end, :current_period_start, :customer,
    :ended_at, :livemode, :metadata, :plan, :quantity, :source,
    :start, :status, :tax_percent, :trial_end, :trial_start
  ]

  @plural_endpoint "subscriptions"

  @doc """
  Create a subscription.
  """
  @spec create(map, Keyword.t) :: {:ok, t} | {:error, Stripe.api_error_struct}
  def create(changes, opts \\ []) do
    Stripe.Request.create(@plural_endpoint, changes, opts)
  end

  @doc """
  Retrieve a subscription.
  """
  @spec retrieve(binary, Keyword.t) :: {:ok, t} | {:error, Stripe.api_error_struct}
  def retrieve(id, opts \\ []) do
    endpoint = @plural_endpoint <> "/" <> id
    Stripe.Request.retrieve(endpoint, opts)
  end

  @doc """
  Update a subscription.

  Takes the `id` and a map of changes.
  """
  @spec update(binary, map, list) :: {:ok, t} | {:error, Stripe.api_error_struct}
  def update(id, changes, opts \\ []) do
    endpoint = @plural_endpoint <> "/" <> id
    Stripe.Request.update(endpoint, changes, opts)
  end

  @doc """
  Delete a subscription.
  """
  @spec delete(binary, list) :: :ok | {:error, Stripe.api_error_struct}
  def delete(id, opts \\ []) do
    endpoint = @plural_endpoint <> "/" <> id
    Stripe.Request.delete(endpoint, opts)
  end
end
