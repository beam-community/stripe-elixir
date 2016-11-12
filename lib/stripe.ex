defmodule Stripe do
  @moduledoc """
  A HTTP client for Stripe.

  ## Configuration

  ### API Key

  You need to set your API key in your application configuration. Typically
  this is done in `config/config.exs` or a similar file. For example:

      config :stripity_stripe, api_key: "sk_test_abc123456789qwerty"

  You can also utilize `System.get_env/1` to retrieve the API key from
  an environment variable, but remember that this can cause issues if
  you use a release tool like exrm or Distillery.

      config :stripity_stripe, api_key: System.get_env("STRIPE_API_KEY")

  ### HTTP Connection Pool

  Stripity Stripe is set up to use an HTTP connection pool by default. This
  means that it will reuse already opened HTTP connections in order to
  minimize the overhead of establishing connections. Two configuration
  options are available to tune how this pool works: `:timeout` and
  `:max_connections`.

  `:timeout` is the amount of time that a connection will be allowed
  to remain open but idle (no data passing over it) before it is closed
  and cleaned up. This defaults to 5 seconds.

  `:max_connections` is the maximum number of connections that can be
  open at any time. This defaults to 10.

  Both these settings are located under the `:pool_options` key in
  your application configuration:

      config :stripity_stripe, :pool_options,
        timeout: 5_000,
        max_connections: 10

  If you prefer, you can also turn pooling off completely using
  the `:use_connection_pool` setting:

      config :stripity_stripe, use_connection_pool: false

  """

  defmodule MissingAPIKeyError do
    defexception message: """
    The secret_key setting is required so that we can report the
    correct environment instance to Stripe. Please configure
    secret_key in your config.exs and environment specific config files
    to have accurate reporting of errors.
    config :stripity_stripe, api_key: YOUR_SECRET_KEY
    """
  end

  defmodule APIAuthenticationError do
    defexception message: """
    Stripe could not authenticate the request with the provided API key
    """
  end

  defmodule APIRateLimitingError do
    defexception message: """
    Stripe is currently limiting the rate at which it accepts your HTTP requests
    """
  end

  defmodule APIError do
    defexception [:message, :type, :status_code, :code]

    @type t :: %__MODULE__{
      message: String.t | nil,
      type: String.t | nil,
      status_code: pos_integer | nil,
      code: String.t | nil
    }

    @spec exception({integer, map}) :: t
    def exception({status_code, %{"type" => type, "message" => message} = body}, _) do
      # code is not a guaranteed key
      code = Map.get(body, "code")

      %__MODULE__{
        message: message,
        type: type,
        status_code: status_code,
        code: code
      }
    end

    def exception({status_code, code, message}) do
      %__MODULE__{
        code: code,
        message: message,
        status_code: status_code
      }
    end

    def exception({status_code, _}) do
      msg = """
      The Stripe HTTP client received an error response with status code #{status_code}
      """

      %__MODULE__{
        message: msg,
        status_code: status_code
      }
    end
  end

  defmodule HTTPError do
    defexception message: """
    The Stripe HTTP client encountered an error while communicating with the
    Stripe service.
    """
  end

  alias __MODULE__.{MissingAPIKeyError, HTTPError, APIRateLimitingError, APIError}

  @type method :: :get | :post | :put | :delete | :patch
  @type headers :: %{String.t => String.t}
  @typep http_success :: {:ok, integer, [{String.t, String.t}], String.t}
  @typep http_failure :: {:error, term}

  use Application

  @pool_name __MODULE__
  @api_version "2016-07-06"

  @doc """
  Callback for the application

  Starts the HTTP connection pool (if it's being used) when
  the VM loads the application pool.

  Note that we are taking advantage of the BEAM application
  standard in order to start the pool when the application is
  started. While we do start a supervisor, the supervisor is only
  to comply with the expectations of the BEAM application standard.
  It is not given any children to supervise.
  """
  @spec start(Application.start_type, any) :: :ok
  def start(_start_type, _args) do
    import Supervisor.Spec, warn: false

    if use_pool?() do
      pool_options = get_pool_options()
      :ok = :hackney_pool.start_pool(@pool_name, pool_options)
    end

    opts = [strategy: :one_for_one, name: Stripe.Supervisor]
    Supervisor.start_link([], opts)
  end

  @doc """
  Callback for the application

  Shuts down the HTTP connection pool (if it's being used) when
  the VM instructs the application to shut down.
  """
  @spec stop() :: :ok
  def stop() do
    :ok = :hackney_pool.stop_pool(@pool_name)

    :ok
  end

  @spec get_pool_options() :: Keyword.t
  defp get_pool_options() do
    Application.get_env(:stripity_stripe, :pool_options)
  end

  @spec get_base_url() :: String.t
  defp get_base_url() do
    Application.get_env(:stripity_stripe, :api_base_url)
  end

  @spec get_api_key() :: String.t
  defp get_api_key() do
    case Application.get_env(:stripity_stripe, :api_key) do
      nil -> raise MissingAPIKeyError
      key -> key
    end
  end

  @spec use_pool?() :: boolean
  defp use_pool?() do
    Application.get_env(:stripity_stripe, :use_connection_pool)
  end

  @spec add_default_headers(headers) :: headers
  defp add_default_headers(existing_headers) do
    api_key = get_api_key()

    Map.merge(existing_headers, %{
      "Accept" => "application/json; charset=utf8",
      "Accept-Encoding" => "gzip",
      "Authorization" => "Bearer #{api_key}",
      "Content-Type" => "application/x-www-form-urlencoded",
      "Connection" => "keep-alive",
      "User-Agent" => "Stripe/v1 stripity-stripe/#{@api_version}"
    })
  end

  @spec add_connect_header(headers, String.t | nil) :: headers
  defp add_connect_header(existing_headers, nil), do: existing_headers
  defp add_connect_header(existing_headers, account_id) do
    Map.put(existing_headers, "Stripe-Account", account_id)
  end

  @spec add_default_options(list) :: list
  defp add_default_options(opts) do
    [ :with_body | opts ]
  end

  @spec add_pool_option(list) :: list
  defp add_pool_option(opts) do
    if use_pool?() do
      [ {:pool, @pool_name} | opts ]
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

      request(:get, "/customers", %{}, %{}, connect_account: "acc_134151")

  """
  @spec request(method, String.t, map, headers, list) :: {:ok, map} | {:error, Exception.t}
  def request(method, endpoint, body, headers, opts) do
    {connect_account_id, opts} = Keyword.pop(opts, :connect_account)

    base_url = get_base_url()
    req_url = base_url <> endpoint
    req_body = Stripe.URI.encode_query(body)
    req_headers =
      headers
      |> add_default_headers()
      |> add_connect_header(connect_account_id)
      |> Map.to_list()

    req_opts =
      opts
      |> add_default_options()
      |> add_pool_option()

    :hackney.request(method, req_url, req_headers, req_body, req_opts)
    |> handle_response()
  end

  @doc """
  A low level utility function to make an OAuth request to the Stripe API
  """
  @spec oauth_request(method, String.t, map) :: {:ok, map} | {:error, Exception.t}
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

    :hackney.request(method, req_url, req_headers, req_body, req_opts)
    |> handle_response()
  end

  @spec handle_response(http_success | http_failure) :: {:ok, map} | {:error, Exception.t}
  defp handle_response({:ok, status, _headers, body}) when status in 200..299 do
    decoded_body = Poison.decode!(body)

    {:ok, decoded_body}
  end

  defp handle_response({:ok, 401, _headers, body}) do
    %{"error" => api_error} = Poison.decode!(body)
    error = APIAuthenticationError.exception({401, api_error})

    {:error, error}
  end

  defp handle_response({:ok, 429, _headers, body}) do
    %{"error" => api_error} = Poison.decode!(body)
    error = APIRateLimitingError.exception({429, api_error})

    {:error, error}
  end

  defp handle_response({:ok, status, _headers, body}) when status in 400..599 do
    %{"error" => api_error, "error_description" => description} = Poison.decode!(body)
    error = APIError.exception({status, api_error, description})

    {:error, error}
  end

  defp handle_response({:error, _reason}) do
    error = HTTPError.exception(nil)
    {:error, error}
  end
end
