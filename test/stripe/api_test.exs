defmodule Stripe.APITest do
  use ExUnit.Case

  import Mox

  test "works with 301 responses without issue" do
    {:error, %Stripe.Error{extra: %{http_status: 301}}} =
      Stripe.API.request(%{}, :get, "/", %{}, [])
  end

  test "oauth_request works" do
    verify_on_exit!()

    Stripe.APIMock
    |> expect(:oauth_request, fn method, _endpoint, _body -> method end)

    assert Stripe.APIMock.oauth_request(:post, "www", %{body: "body"}) == :post
  end

  test "oauth_request sets authorization header for deauthorize request" do
    defmodule HackneyMock do
      def request(_, _, headers, _, _) do
        kv_headers =
          headers
          |> Enum.reduce(%{}, fn {k, v}, acc -> Map.put(acc, k, v) end)

        {:ok, 200, headers, Poison.encode!(kv_headers)}
      end
    end

    Application.put_env(:stripity_stripe, :http_module, HackneyMock)

    {:ok, body} = Stripe.API.oauth_request(:post, "deauthorize", %{})
    assert body["Authorization"] == "Bearer sk_test_123"

    {:ok, body} = Stripe.API.oauth_request(:post, "deauthorize", %{}, "1234")
    assert body["Authorization"] == "Bearer 1234"

    {:ok, body} = Stripe.API.oauth_request(:post, "token", %{})
    assert Map.keys(body) |> Enum.member?("Authorization") == false
  end
end
