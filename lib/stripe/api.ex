defmodule Stripe.API do
  @moduledoc """
  Low-level utilities for interacting with the Stripe API.

  Usually the utilities in `Stripe.Request` are a better way to write custom interactions with
  the API.
  """
  alias Stripe.{Config, Error}

  @callback oauth_request(method, String.t(), map) :: {:ok, map}

  @type method :: :get | :post | :put | :delete | :patch
  @type headers :: %{String.t() => String.t()} | %{}
  @type body :: iodata() | {:multipart, list()}
  @typep http_success :: {:ok, integer, [{String.t(), String.t()}], String.t()}
  @typep http_failure :: {:error, term}

  @pool_name __MODULE__
  @api_version "2018-11-08"

  @doc """
  In config.exs your implicit or expicit configuration is:
    config :stripity_stripe,
      json_library: Jason # defaults to Poison but can be configured to Jason
  """
  @spec json_library() :: module
  def json_library() do
    Config.resolve(:json_library, Poison)
  end

  def supervisor_children do
    if use_pool?() do
      [:hackney_pool.child_spec(@pool_name, get_pool_options())]
    else
      []
    end
  end

  @spec get_pool_options() :: Keyword.t()
  defp get_pool_options() do
    Config.resolve(:pool_options)
  end

  @spec get_base_url() :: String.t()
  defp get_base_url() do
    Config.resolve(:api_base_url)
  end

  @spec get_upload_url() :: String.t()
  defp get_upload_url() do
    Config.resolve(:api_upload_url)
  end

  @spec get_default_api_key() :: String.t()
  defp get_default_api_key() do
    # if no API key is set default to `""` which will raise a Stripe API error
    Config.resolve(:api_key, "")
  end

  @spec use_pool?() :: boolean
  defp use_pool?() do
    Config.resolve(:use_connection_pool)
  end

  @spec http_module() :: module
  defp http_module() do
    Config.resolve(:http_module, :hackney)
  end

  @spec add_common_headers(headers) :: headers
  defp add_common_headers(existing_headers) do
    Map.merge(existing_headers, %{
      "Accept" => "application/json; charset=utf8",
      "Accept-Encoding" => "gzip",
      "Connection" => "keep-alive",
      "User-Agent" => "Stripe/v1 stripity-stripe/#{@api_version}",
      "Stripe-Version" => @api_version
    })
  end

  @spec add_default_headers(headers) :: headers
  defp add_default_headers(existing_headers) do
    existing_headers = add_common_headers(existing_headers)

    case Map.has_key?(existing_headers, "Content-Type") do
      false -> existing_headers |> Map.put("Content-Type", "application/x-www-form-urlencoded")
      true -> existing_headers
    end
  end

  @spec add_multipart_form_headers(headers) :: headers
  defp add_multipart_form_headers(existing_headers) do
    existing_headers
    |> Map.put("Content-Type", "multipart/form-data")
  end

  @spec add_auth_header(headers, String.t() | nil) :: headers
  defp add_auth_header(existing_headers, api_key) do
    api_key = fetch_api_key(api_key)
    Map.put(existing_headers, "Authorization", "Bearer #{api_key}")
  end

  @spec fetch_api_key(String.t() | nil) :: String.t()
  defp fetch_api_key(api_key) do
    case api_key do
      key when is_binary(key) -> key
      _ -> get_default_api_key()
    end
  end

  @spec add_connect_header(headers, String.t() | nil) :: headers
  defp add_connect_header(existing_headers, nil), do: existing_headers

  defp add_connect_header(existing_headers, account_id) do
    Map.put(existing_headers, "Stripe-Account", account_id)
  end

  @spec add_default_options(list) :: list
  defp add_default_options(opts) do
    [:with_body | opts]
  end

  @spec add_pool_option(list) :: list
  defp add_pool_option(opts) do
    if use_pool?() do
      [{:pool, @pool_name} | opts]
    else
      opts
    end
  end

  @doc """
  A low level utility function to make a direct request to the Stripe API

  ## Connect Accounts

  If you'd like to make a request on behalf of another Stripe account
  utilizing the Connect program, you can pass the other Stripe account's
  ID to the request function as follows:

      request(%{}, :get, "/customers", %{}, connect_account: "acc_134151")

  """
  @spec request(body, method, String.t(), headers, list) ::
          {:ok, map} | {:error, Stripe.Error.t()}
  def request(body, :get, endpoint, headers, opts) do
    {expansion, opts} = Keyword.pop(opts, :expand)
    base_url = get_base_url()

    req_url =
      body
      |> Stripe.Util.map_keys_to_atoms()
      |> add_object_expansion(expansion)
      |> Stripe.URI.encode_query()
      |> prepend_url("#{base_url}#{endpoint}")

    perform_request(req_url, :get, "", headers, opts)
  end

  def request(body, method, endpoint, headers, opts) do
    {expansion, opts} = Keyword.pop(opts, :expand)
    base_url = get_base_url()

    req_url = add_object_expansion("#{base_url}#{endpoint}", expansion)

    req_body =
      body
      |> Stripe.Util.map_keys_to_atoms()
      |> Stripe.URI.encode_query()

    perform_request(req_url, method, req_body, headers, opts)
  end

  @doc """
  A low level utility function to make a direct request to the files Stripe API
  """
  @spec request_file_upload(body, method, String.t(), headers, list) ::
          {:ok, map} | {:error, Stripe.Error.t()}
  def request_file_upload(body, :post, endpoint, headers, opts) do
    base_url = get_upload_url()
    req_url = base_url <> endpoint

    req_headers =
      headers
      |> add_multipart_form_headers()

    parts =
      body
      |> Enum.map(fn {key, value} ->
        {Stripe.Util.multipart_key(key), value}
      end)

    perform_request(req_url, :post, {:multipart, parts}, req_headers, opts)
  end

  def request_file_upload(body, method, endpoint, headers, opts) do
    base_url = get_upload_url()
    req_url = base_url <> endpoint

    req_body =
      body
      |> Stripe.Util.map_keys_to_atoms()
      |> Stripe.URI.encode_query()

    perform_request(req_url, method, req_body, headers, opts)
  end

  @doc """
  A low level utility function to make an OAuth request to the Stripe API
  """
  @spec oauth_request(method, String.t(), map) :: {:ok, map} | {:error, Stripe.Error.t()}
  def oauth_request(method, endpoint, body) do
    base_url = "https://connect.stripe.com/oauth/"
    req_url = base_url <> endpoint
    req_body = Stripe.URI.encode_query(body)

    req_headers =
      %{}
      |> add_default_headers()
      |> Map.to_list()

    req_opts =
      []
      |> add_default_options()
      |> add_pool_option()

    http_module().request(method, req_url, req_headers, req_body, req_opts)
    |> handle_response()
  end

  @spec perform_request(String.t(), method, body, headers, list) ::
          {:ok, map} | {:error, Stripe.Error.t()}
  defp perform_request(req_url, method, body, headers, opts) do
    {connect_account_id, opts} = Keyword.pop(opts, :connect_account)
    {api_key, opts} = Keyword.pop(opts, :api_key)

    req_headers =
      headers
      |> add_default_headers()
      |> add_auth_header(api_key)
      |> add_connect_header(connect_account_id)
      |> Map.to_list()

    req_opts =
      opts
      |> add_default_options()
      |> add_pool_option()

    http_module().request(method, req_url, req_headers, body, req_opts)
    |> handle_response()
  end

  @spec handle_response(http_success | http_failure) :: {:ok, map} | {:error, Stripe.Error.t()}
  defp handle_response({:ok, status, headers, body}) when status >= 200 and status <= 299 do
    decoded_body =
      body
      |> decompress_body(headers)
      |> json_library().decode!()

    {:ok, decoded_body}
  end

  defp handle_response({:ok, status, headers, body}) when status >= 300 and status <= 599 do
    request_id = headers |> List.keyfind("Request-Id", 0)

    error =
      case json_library().decode(body) do
        {:ok, %{"error_description" => _} = api_error} ->
          Error.from_stripe_error(status, api_error, request_id)

        {:ok, %{"error" => api_error}} ->
          Error.from_stripe_error(status, api_error, request_id)

        {:error, _} ->
          # e.g. if the body is empty
          Error.from_stripe_error(status, nil, request_id)
      end

    {:error, error}
  end

  defp handle_response({:error, reason}) do
    error = Error.from_hackney_error(reason)
    {:error, error}
  end

  defp decompress_body(body, headers) do
    headers_dict = :hackney_headers.new(headers)

    case :hackney_headers.get_value("Content-Encoding", headers_dict) do
      "gzip" -> :zlib.gunzip(body)
      "deflate" -> :zlib.unzip(body)
      _ -> body
    end
  end

  defp prepend_url("", url), do: url
  defp prepend_url(query, url), do: "#{url}?#{query}"

  defp add_object_expansion(query, expansion) when is_map(query) and is_list(expansion) do
    query |> Map.put(:expand, expansion)
  end

  defp add_object_expansion(url, expansion) when is_list(expansion) do
    expansion
    |> Enum.map(&"expand[]=#{&1}")
    |> Enum.join("&")
    |> prepend_url(url)
  end

  defp add_object_expansion(url, _), do: url
end
