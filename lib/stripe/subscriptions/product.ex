defmodule Stripe.Product do
  @moduledoc """
  Work with Stripe product objects.

  You can:

  - Create a product
  - Retrieve a product
  - Update a product
  - Delete a product
  - List products

  Stripe API reference: https://stripe.com/docs/api#service_products
  """

  use Stripe.Entity
  import Stripe.Request

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          active: boolean | nil,
          attributes: list | nil,
          caption: String.t() | nil,
          created: Stripe.timestamp(),
          deactivate_on: list,
          deleted: boolean | nil,
          description: String.t() | nil,
          images: list,
          livemode: boolean,
          metadata: Stripe.Types.metadata(),
          name: String.t(),
          package_dimensions: map | nil,
          shippable: boolean | nil,
          statement_descriptor: String.t() | nil,
          type: String.t() | nil,
          unit_label: String.t() | nil,
          updated: Stripe.timestamp(),
          url: String.t() | nil
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
    :type,
    :unit_label,
    :updated,
    :url
  ]

  @plural_endpoint "products"

  @doc """
  Create a product.
  """
  @spec create(params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:id) => String.t(),
                 optional(:attributes) => list,
                 :name => String.t(),
                 :type => String.t(),
                 optional(:metadata) => Stripe.Types.metadata(),
                 optional(:statement_descriptor) => String.t(),
                 optional(:unit_label) => String.t()
               }
               | %{}
  def create(params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint)
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
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
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
                 optional(:attributes) => list,
                 optional(:name) => String.t(),
                 optional(:metadata) => Stripe.Types.metadata(),
                 optional(:statement_descriptor) => String.t()
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
  Delete a product.
  """
  @spec delete(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def delete(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:delete)
    |> make_request()
  end

  @doc """
  List all products.
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:active) => boolean,
                 optional(:created) => Stripe.date_query(),
                 optional(:ending_before) => t | Stripe.id(),
                 optional(:limit) => 1..100,
                 optional(:shippable) => boolean,
                 optional(:starting_after) => t | Stripe.id(),
                 optional(:type) => String.t(),
                 optional(:url) => String.t()
               }
               | %{}
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint)
    |> put_method(:get)
    |> put_params(params)
    |> cast_to_id([:ending_before, :starting_after])
    |> make_request()
  end
end
