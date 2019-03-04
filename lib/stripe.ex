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

  ### Shared Options

  Almost all of the requests that can be sent accept the following options:

    * `:api_key` - The Stripe API key to use for the request. See
      [https://stripe.com/docs/api/authentication](https://stripe.com/docs/api/authentication)
    * `:connect_account` - The ID of a Stripe Connect account for which the
      request should be made, passed through as the "Stripe-Account" header. The
      preferred authentication method for Stripe Connect. See
      [https://stripe.com/docs/connect/authentication#stripe-account-header](https://stripe.com/docs/connect/authentication#stripe-account-header)
    * `:expand` - Takes a list of fields that should be expanded in the response
      from Stripe. See [https://stripe.com/docs/api/expanding_objects](https://stripe.com/docs/api/expanding_objects)
    * `:idempotency_key` - A string that is passed through as the "Idempotency-Key" header on all POST requests. This is used by Stripe's idempotency layer to manage
      duplicate requests to the stripe API. See [https://stripe.com/docs/api/idempotent_requests](https://stripe.com/docs/api/idempotent_requests)

  ### HTTP Connection Pool

  Stripity Stripe is set up to use an HTTP connection pool by default. This
  means that it will reuse already opened HTTP connections in order to
  minimize the overhead of establishing connections. The pool is directly
  supervised by Stripity Stripe. Two configuration options are
  available to tune how this pool works: `:timeout` and `:max_connections`.

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
  use Application

  @type id :: String.t()
  @type date_query :: %{
          optional(:gt) => timestamp,
          optional(:gte) => timestamp,
          optional(:lt) => timestamp,
          optional(:lte) => timestamp
        }
  @type options :: Keyword.t()
  @type timestamp :: pos_integer

  @doc """
  Callback for the application

  Start the supervision tree including the supervised
  HTTP connection pool (if it's being used) when
  the VM loads the application pool.

  Note that we are taking advantage of the BEAM application
  standard in order to start the pool when the application is
  started. While we do start a supervisor, the supervisor is only
  to comply with the expectations of the BEAM application standard.
  It is not given any children to supervise.
  """
  @spec start(Application.start_type(), any) :: {:error, any} | {:ok, pid} | {:ok, pid, any}
  def start(_start_type, _args) do
    import Supervisor.Spec, warn: false

    children = Stripe.API.supervisor_children()

    opts = [strategy: :one_for_one, name: Stripe.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
