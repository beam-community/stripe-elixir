defmodule Stripe.Connect.OAuthTest do
  use ExUnit.Case

  import Mox

  test "oauth methods works" do
    verify_on_exit!()

    Stripe.APIMock
    |> expect(:oauth_request, fn method, _endpoint, _body -> method end)

    Stripe.Connect.OAuthMock
    |> expect(:token, fn url -> Stripe.APIMock.oauth_request(:post, url, %{body: "body"}) end)
    |> expect(:deauthorize_url, fn url -> url end)
    |> expect(:authorize_url, fn %{url: url} -> url end)

    assert Stripe.Connect.OAuthMock.token("1234") == :post
    assert Stripe.Connect.OAuthMock.authorize_url(%{url: "www"}) == "www"
    assert Stripe.Connect.OAuthMock.deauthorize_url("www.google.com") == "www.google.com"
  end
end
