defmodule Stripe.StripeCase do
  @moduledoc """
  This module defines the setup for tests requiring access to a mocked version of Stripe.
  """

  use ExUnit.CaseTemplate

  def assert_stripe_requested(expected_method, path, extra \\ []) do
    expected_url = build_url(path, Keyword.get(extra, :query))
    expected_body = Keyword.get(extra, :body)
    expected_headers = Keyword.get(extra, :headers)

    assert_received({method, url, headers, body, _})

    assert expected_method == method
    assert expected_url == url

    assert_stripe_request_body(expected_body, body)
    assert_stripe_request_headers(expected_headers, headers)
  end

  def stripe_base_url() do
    Application.get_env(:stripity_stripe, :api_base_url)
  end

  defp assert_stripe_request_headers(nil, _), do: nil

  defp assert_stripe_request_headers(expected_headers, headers) when is_list(expected_headers) do
    assert Enum.all?(expected_headers, &assert_stripe_request_headers(&1, headers))
  end

  defp assert_stripe_request_headers(expected_header, headers) do
    assert Enum.any?(headers, fn header -> expected_header == header end),
    """
    Expected the header `#{inspect(expected_header)}` to be in the headers of the request.

    Headers:
    #{inspect(headers)}
    """
  end

  defp assert_stripe_request_body(nil, _), do: nil

  defp assert_stripe_request_body(expected_body, body) do

    assert body == Stripe.URI.encode_query(expected_body)
  end

  defp build_url("/v1/" <> path, nil) do
    stripe_base_url() <> path
  end

  defp build_url("/v1/" <> path, query_params) do
    stripe_base_url() <> path <> "?" <> URI.encode_query(query_params)
  end

  defmodule HackneyMock do
    @doc """
    Send message to the owning process for each request so we can assert that
    the request was made.

    """
    def request(method, path, headers, body, opts) do
      send(self(), {method, path, headers, body, opts})

      :hackney.request(method, path, headers, body, opts)
    end
  end

  using do
    quote do
      import Stripe.StripeCase,
        only: [assert_stripe_requested: 2, assert_stripe_requested: 3, stripe_base_url: 0]

      Application.put_env(:stripity_stripe, :http_module, HackneyMock)
    end
  end
end
