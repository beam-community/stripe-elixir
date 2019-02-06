defmodule Stripe.Sku do
  @moduledoc """
  Work with Stripe Sku objects.

  Stripe API reference: https://stripe.com/docs/api#sku_object
  """

  use Stripe.Entity
  import Stripe.Request

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          active: boolean,
          attributes: %{
            optional(String.t()) => String.t()
          },
          created: Stripe.timestamp(),
          currency: String.t(),
          image: String.t(),
          inventory: %{
            quantity: non_neg_integer | nil,
            type: String.t(),
            value: String.t() | nil
          },
          livemode: boolean,
          metadata: Stripe.Types.metadata(),
          package_dimensions:
            %{
              height: float,
              length: float,
              weight: float,
              width: float
            }
            | nil,
          price: non_neg_integer,
          product: Stripe.id() | Stripe.Relay.Product.t(),
          updated: Stripe.timestamp()
        }

  defstruct [
    :id,
    :object,
    :active,
    :attributes,
    :created,
    :currency,
    :image,
    :inventory,
    :livemode,
    :metadata,
    :package_dimensions,
    :price,
    :product,
    :updated
  ]

  @endpoint "skus"

  @doc """
  Create a order.
  """
  @spec create(params, Keyword.t()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               :currency => String.t(),
               :inventory => map,
               :price => non_neg_integer,
               :product => Stripe.id() | Stripe.Relay.Product.t(),
               optional(:active) => boolean,
               optional(:attributes) => map,
               optional(:image) => String.t(),
               optional(:metadata) => Stripe.Types.metadata(),
               optional(:package_dimensions) => map
             }
  def create(%{currency: _, inventory: _, price: _, product: _} = params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint)
    |> put_params(params)
    |> put_method(:post)
    |> make_request()
  end

  @doc """
  Retrieve a order.
  """
  @spec retrieve(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  Update a order.

  Takes the `id` and a map of changes
  """
  @spec update(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:active) => boolean,
               optional(:attributes) => map,
               optional(:currency) => String.t(),
               optional(:image) => String.t(),
               optional(:inventory) => map,
               optional(:metadata) => Stripe.Types.metadata(),
               optional(:package_dimensions) => map,
               optional(:price) => non_neg_integer,
               optional(:product) => Stripe.id() | Stripe.Relay.Product.t()
             }
  def update(id, params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint <> "/#{get_id!(id)}")
    |> put_method(:post)
    |> put_params(params)
    |> make_request()
  end

  @doc """
  delete an order.
  """
  @spec delete(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def delete(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint <> "/#{get_id!(id)}")
    |> put_method(:delete)
    |> make_request()
  end

  @doc """
  List all skus.
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params: %{
               optional(:active) => boolean,
               optional(:attributes) => map,
               optional(:ending_before) => t | Stripe.id(),
               optional(:ids) => Stripe.List.t(Stripe.id()),
               optional(:in_stock) => boolean,
               optional(:limit) => 1..100,
               optional(:product) => Stripe.id() | Stripe.Relay.Product.t(),
               optional(:starting_after) => t | Stripe.id()
             }
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint)
    |> put_method(:get)
    |> put_params(params)
    |> cast_to_id([:ending_before, :starting_after])
    |> make_request()
  end
end
