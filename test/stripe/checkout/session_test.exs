defmodule Stripe.SessionTest do
  use Stripe.StripeCase, async: true

  test "is creatable" do
    params = %{
      cancel_url: "https://stripe.com",
      payment_method_types: ["card"],
      success_url: "https://stripe.com"
    }

    assert {:ok, %Stripe.Session{}} = Stripe.Session.create(params)
    assert_stripe_requested(:post, "/v1/checkout/sessions")
  end
end
