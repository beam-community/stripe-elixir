defmodule Stripe.Request do
  @moduledoc """
  A module for working with requests to the Stripe API.

  Requests are composed in a functional manner. The request does not happen
  until it is configured and passed to `make_request/1`.

  Currently encompasses only requests to the normal Stripe API. The OAuth
  endpoint is not yet supported.

  Generally intended to be used internally, but can also be used by end-users
  to work around missing endpoints (if any).

  At a minimum, a request must have the endpoint and method specified to be
  valid.
  """
  alias Stripe.{API, Converter, Request}

  @type t :: %__MODULE__{
          cast_to_id: MapSet.t(),
          endpoint: String.t() | nil,
          headers: map | nil,
          method: Stripe.API.method() | nil,
          opts: Keyword.t() | nil,
          params: map
        }

  @type error_code ::
          :endpoint_fun_invalid_result
          | :invalid_endpoint

  defstruct opts: [],
            endpoint: nil,
            headers: nil,
            method: nil,
            params: %{},
            cast_to_id: MapSet.new()

  @doc """
  Creates a new request.

  Optionally accepts options for the request, such as using a specific API key.
  See `t:Stripe.options` for details.
  """
  @spec new_request(Stripe.options(), map) :: t
  def new_request(opts \\ [], headers \\ %{}) do
    headers =
      opts
      |> Keyword.get(:headers, %{})
      |> Map.merge(headers)

    %Request{opts: opts, headers: headers}
  end

  @doc """
  Specifies an endpoint for the request.

  The endpoint should not include the `v1` prefix or an initial slash, for
  example `put_endpoint(request, "charges")`.

  The endpoint can be a binary or a function which takes the parameters of the
  query and returns an endpoint. The function is not evaluated until just
  before the request is made so the actual parameters can be specified after
  the endpoint.
  """
  @spec put_endpoint(t, String.t()) :: t
  def put_endpoint(%Request{} = request, endpoint) do
    %{request | endpoint: endpoint}
  end

  @doc """
  Specifies a method to use for the request.

  Accepts any of the standard HTTP methods as atoms, that is `:get`, `:post`,
  `:put`, `:patch` or `:delete`.
  """
  @spec put_method(t, Stripe.API.method()) :: t
  def put_method(%Request{} = request, method)
      when method in [:get, :post, :put, :patch, :delete] do
    %{request | method: method}
  end

  @doc """
  Specifies the parameters to be used for the request.

  If the request is a POST request, these are encoded in the request body.
  Otherwise, they are encoded in the URL.

  Calling this function multiple times will merge, not replace, the params
  currently specified.
  """
  @spec put_params(t, map) :: t
  def put_params(%Request{params: params} = request, new_params) do
    %{request | params: Map.merge(params, new_params)}
  end

  @doc """
  Specify a single param to be included in the request.
  """
  @spec put_param(t, atom, any) :: t
  def put_param(%Request{params: params} = request, key, value) do
    %{request | params: Map.put(params, key, value)}
  end

  @doc """
  Specify that a given set of parameters should be cast to a simple ID.

  Sometimes, it may be convenient to allow end-users to pass in structs (say,
  the card to charge) but the API requires only the ID of the object. This
  function will ensure that before the request is made, the parameters
  specified here will be cast to IDs – if the value of a parameter is a
  struct with an `:id` field, the value of that field will replace the struct
  in the parameter list.

  If the function is called multiple times, the set of parameters to cast to
  ID is merged between the multiple calls.
  """
  @spec cast_to_id(t, [atom]) :: t
  def cast_to_id(%Request{cast_to_id: cast_to_id} = request, new_cast_to_id) do
    %{request | cast_to_id: MapSet.union(cast_to_id, MapSet.new(new_cast_to_id))}
  end

  @doc """
  Specify that a given path in the parameters should be cast to a simple ID.

  Acts similar to `cast_to_id/2` but specifies only one parameter to be cast,
  by specifying its path (as in the `Access` protocol). Used to cast nested
  objects to their IDs.
  """
  @spec cast_path_to_id(t, [atom]) :: t
  def cast_path_to_id(%Request{cast_to_id: cast_to_id} = request, new_cast_to_id) do
    %{request | cast_to_id: MapSet.put(cast_to_id, new_cast_to_id)}
  end

  @doc ~S"""
  Normalise the argument to a simple Stripe ID.

  Actively extracts the ID, given a struct with an `:id` field, or returns the
  binary if one is passed in.

  Useful for eagerly getting the ID of an object passed in, for example when
  computing the endpoint to use:

  ```
  def capture(id, params, opts) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}/capture")
    ...
  ```
  """
  @spec get_id!(Stripe.id() | struct) :: Stripe.id()
  def get_id!(id) when is_binary(id), do: id

  def get_id!(%{id: id}) when is_binary(id), do: id

  def get_id!(_), do: raise("You must provide an ID or a struct with an ID to this operation.")

  @doc ~S"""
  Prefixes all `:expand` values provided in `opts` with the given prefix.

  When using object expansion on a `list` function for a resource, the values must
  be prefixed with `data.`. This is required because the stripe api nests the
  returned objects within `data: {}`.

  For all `create`, `update`, `cancel` and `retrieve` functions this is not required.

  ```
  opts = [expand: ["balance_transaction"]]
  request = prefix_expansions(%Request{opts: opts})

  request.opts == ["data.balance_transaction"]
  ```
  """
  @spec prefix_expansions(t) :: t
  def prefix_expansions(%Request{opts: opts} = request) do
    case Keyword.get(opts, :expand) do
      nil ->
        request

      expansions ->
        mapped_expansions = Enum.map(expansions, &"data.#{&1}")
        opts = Keyword.replace!(opts, :expand, mapped_expansions)

        %{request | opts: opts}
    end
  end

  @doc """
  Executes the request and returns the response.
  """
  @spec make_request(t) :: {:ok, struct} | {:error, Stripe.Error.t()}
  def make_request(
        %Request{params: params, endpoint: endpoint, method: method, headers: headers, opts: opts} =
          request
      ) do
    with {:ok, params} <- do_cast_to_id(params, request.cast_to_id),
         {:ok, endpoint} <- consolidate_endpoint(endpoint, params),
         {:ok, result} <- API.request(params, method, endpoint, headers, opts) do
      {:ok, Converter.convert_result(result)}
    end
  end

  @doc """
  Executes the request and returns the response for file uploads
  """
  @spec make_file_upload_request(t) :: {:ok, struct} | {:error, Stripe.Error.t()}
  def make_file_upload_request(
        %Request{params: params, endpoint: endpoint, method: method, opts: opts} = request
      ) do
    with {:ok, params} <- do_cast_to_id(params, request.cast_to_id),
         {:ok, endpoint} <- consolidate_endpoint(endpoint, params),
         {:ok, result} <- API.request_file_upload(params, method, endpoint, %{}, opts) do
      {:ok, Converter.convert_result(result)}
    end
  end

  defp do_cast_to_id(params, cast_to_id) do
    to_cast = MapSet.to_list(cast_to_id)

    params =
      Enum.reduce(to_cast, params, fn key, params ->
        case params[key] do
          %{__struct__: _, id: id} -> put_in(params[key], id)
          _ -> params
        end
      end)

    {:ok, params}
  end

  defp consolidate_endpoint(endpoint, _) when is_binary(endpoint), do: {:ok, endpoint}

  defp consolidate_endpoint(endpoint_fun, params) when is_function(endpoint_fun, 1) do
    case endpoint_fun.(params) do
      result when is_binary(result) ->
        {:ok, result}

      invalid ->
        {
          :error,
          Stripe.Error.new(
            source: :internal,
            code: :endpoint_fun_invalid_result,
            message:
              "calling the endpoint function produced an invalid result of #{inspect(invalid)} "
          )
        }
    end
  end

  defp consolidate_endpoint(_, _) do
    {
      :error,
      Stripe.Error.new(
        source: :internal,
        code: :invalid_endpoint,
        message: "endpoint must be a string or a function from params to a string"
      )
    }
  end
end
