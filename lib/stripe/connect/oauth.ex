defmodule Stripe.Connect.OAuth do
  @moduledoc """
  Work with Stripe Connect.

  You can:

  - generate the URL for starting the OAuth workflow
  - authorize a new connected account with a token
  - deauthorize an existing connected account

  Stripe API reference: https://stripe.com/docs/connect/reference
  """

  alias Stripe.{Config, Converter}

  @callback token(code :: String.t()) :: {:ok, map}
  @callback authorize_url(map) :: String.t()
  @callback deauthorize_url(url :: String.t()) :: {:ok, map}

  @authorize_url_valid_keys [
    :always_prompt,
    :client_id,
    :redirect_uri,
    :response_type,
    :scope,
    :state,
    :stripe_landing,
    :stripe_user
  ]

  defmodule AuthorizeResponse do
    defstruct [
      :access_token,
      :livemode,
      :refresh_token,
      :scope,
      :stripe_user_id,
      :stripe_publishable_key,
      :token_type
    ]
  end

  defmodule TokenResponse do
    defstruct [
      :access_token,
      :livemode,
      :refresh_token,
      :scope,
      :stripe_user_id,
      :stripe_publishable_key,
      :token_type
    ]
  end

  defmodule DeauthorizeResponse do
    defstruct [
      :stripe_user_id
    ]
  end

  @doc """
  Execute the OAuth callback to Stripe using the code supplied in the request parameter of the oauth redirect at the end of the onboarding workflow.

  ## Example
  ```
  iex(1)> {:ok, resp} = Stripe.Connect.OAuth.token(code)
  ...(1)> IO.inspect resp
  %Stripe.Connect.OAuth.TokenResponse{
      access_token: "ACCESS_TOKEN",
      livemode: false,
      refresh_token: "REFRESH_TOKEN",
      scope: "read_write",
      stripe_publishable_key: "PUBLISHABLE_KEY",
      stripe_user_id: "USER_ID",
      token_type: "bearer"
  }
  ```
  """
  @spec token(String.t()) :: {:ok, map} | {:error, %Stripe.Error{}}
  def token(code) do
    endpoint = "token"

    body = %{
      client_secret: get_client_secret(),
      code: code,
      grant_type: "authorization_code"
    }

    case Stripe.API.oauth_request(:post, endpoint, body) do
      {:ok, result} -> {:ok, Converter.convert_result(result)}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  De-authorizes the connected account.

  Requires the customer to re-establish the link using the onboarding workflow.

  ## Example
  ```
  iex(1)> {:ok, result} = Stripe.Connect.OAuth.deauthorize(stripe_user_id)
  ```

  """
  @spec deauthorize(String.t()) :: {:ok, map} | {:error, %Stripe.Error{}}
  def deauthorize(stripe_user_id) do
    endpoint = "deauthorize"

    body = %{
      client_id: get_client_id(),
      stripe_user_id: stripe_user_id
    }

    case Stripe.API.oauth_request(:post, endpoint, body) do
      {:ok, result} -> {:ok, Converter.convert_result(result)}
      {:error, error} -> {:error, error}
    end
  end

  @doc ~S"""
  Generate the URL to start a Stripe workflow.

  ## Paremeter Map Keys

  The parameter map keys are derived from the [valid request parameter](https://stripe.com/docs/connect/reference)
  for the Stripe Connect authorize endpoint. A parameter only needs to be provided if
  you wish to override the default.

  - `:always_prompt`
  - `:client_id`
  - `:redirect_uri`
  - `:response_type`
  - `:scope`
  - `:state`
  - `:stripe_landing`
  - `:stripe_user`

  For ease of use, any parameters you provide will be merged into
  the following default map with sensible defaults. This also allows
  you to call the function with no parameters and it will fall
  back to this map:

  ```
  %{
    client_id: client_id, # :connect_client_id from configuration
    response_type: "code",
    scope: "read_write"
  }
  ```

  ## Example

  ```
  connect_opts = %{
    state: "2686e7a93156ff5af76a83262ac653",
    stripe_user: %{
      "email" => "local@business.example.net",
      "url" => "http://local.example.net",
      "country" => "US",
      "phone_number" => "5555555678",
      "business_name" => "Jeanine & Jerome's Jellies",
      "businessy_type" => "llc",
      "first_name" => "Jeanine",
      "last_name" => "Smith",
      "dob_day" => 29,
      "dob_month" => 1,
      "dob_year" => 1983,
      "street_address" => "123 Main St.",
      "product_category" => "food_and_restuarants"
    }
  }
  url = Stripe.Connect.OAuth.authorize_url(connect_opts)
  ```
  """
  @spec authorize_url(map) :: String.t()
  def authorize_url(options \\ %{}) do
    base_url = "https://connect.stripe.com/oauth/authorize?"

    param_string =
      get_default_authorize_map()
      |> Map.merge(options)
      |> Map.take(@authorize_url_valid_keys)
      |> Stripe.URI.encode_query()

    base_url <> param_string
  end

  @spec get_client_id() :: String.t()
  defp get_client_id() do
    Config.resolve(:connect_client_id)
  end

  @spec get_client_secret() :: String.t()
  defp get_client_secret() do
    Config.resolve(:api_key)
  end

  @spec get_default_authorize_map() :: map
  defp get_default_authorize_map() do
    %{
      client_id: get_client_id(),
      response_type: "code",
      scope: "read_write"
    }
  end
end
