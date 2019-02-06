defmodule Stripe.Relay.Product do
  @moduledoc """
  Work with Stripe products.

  Stripe API reference: https://stripe.com/docs/api#products
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
          caption: String.t(),
          created: Stripe.timestamp(),
          deactivate_on: [Stripe.id()],
          deleted: boolean | nil,
          description: String.t(),
          images: [String.t()],
          livemode: boolean,
          metadata: Stripe.Types.metadata(),
          name: String.t(),
          package_dimensions:
            nil
            | %{
                height: float,
                length: float,
                weight: float,
                width: float
              },
          shippable: boolean,
          statement_descriptor: String.t(),
          unit_label: String.t(),
          updated: Stripe.timestamp(),
          url: String.t()
        }

  defstruct [
    :id,
    :object,
    :active,
    :attributes,
    :caption,
    :created,
    :deactivate_on,
    :deleted,
    :description,
    :images,
    :livemode,
    :metadata,
    :name,
    :package_dimensions,
    :shippable,
    :statement_descriptor,
    :unit_label,
    :updated,
    :url
  ]

  @endpoint "products"

  @doc """
  Create a product.
  """
  @spec create(params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:caption) => String.t(),
                 optional(:deactive_on) => [Stripe.id()],
                 optional(:description) => String.t(),
                 optional(:id) => String.t(),
                 optional(:images) => [Stripe.id()],
                 optional(:description) => String.t(),
                 optional(:attributes) => list,
                 :name => String.t(),
                 :type => String.t(),
                 optional(:metadata) => Stripe.Types.metadata(),
                 optional(:package_dimensions) => map,
                 optional(:shippable) => boolean,
                 optional(:url) => String.t()
               }
               | %{}
  def create(params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint)
    |> put_params(params)
    |> put_method(:post)
    |> make_request()
  end

  @doc """
  Retrieve a product.
  """
  @spec retrieve(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  Update a product.

  Takes the `id` and a map of changes.
  """
  @spec update(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:active) => boolean,
                 optional(:attributes) => list,
                 optional(:caption) => String.t(),
                 optional(:deactive_on) => [Stripe.id()],
                 optional(:description) => String.t(),
                 optional(:images) => [Stripe.id()],
                 optional(:metadata) => Stripe.Types.metadata(),
                 optional(:name) => String.t(),
                 optional(:package_dimensions) => map,
                 optional(:shippable) => boolean,
                 optional(:url) => String.t()
               }
               | %{}
  def update(id, params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint <> "/#{get_id!(id)}")
    |> put_method(:post)
    |> put_params(params)
    |> make_request()
  end

  @doc """
  Delete a product.
  """
  @spec delete(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def delete(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint <> "/#{get_id!(id)}")
    |> put_method(:delete)
    |> make_request()
  end

  @doc """
  List all product.
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:active) => boolean,
                 optional(:created) => Stripe.date_query(),
                 optional(:ending_before) => t | Stripe.id(),
                 optional(:ids) => Stripe.List.t(Stripe.id()),
                 optional(:limit) => 1..100,
                 optional(:shippable) => boolean,
                 optional(:starting_after) => t | Stripe.id(),
                 optional(:type) => String.t(),
                 optional(:url) => String.t()
               }
               | %{}
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@endpoint)
    |> put_method(:get)
    |> put_params(params)
    |> cast_to_id([:ending_before, :starting_after])
    |> make_request()
  end
end
