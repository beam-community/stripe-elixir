defmodule Stripe.PaymentIntentTest do
  use Stripe.StripeCase, async: true

  test "is listable" do
    assert {:ok, %Stripe.List{data: payment_intents}} = Stripe.PaymentIntent.list()
    assert_stripe_requested(:get, "/v1/payment_intents")
    assert is_list(payment_intents)
    assert %Stripe.PaymentIntent{} = hd(payment_intents)
  end

  test "is retrievable" do
    assert {:ok, %Stripe.PaymentIntent{}} = Stripe.PaymentIntent.retrieve("pi_123", %{})
    assert_stripe_requested(:get, "/v1/payment_intents/pi_123")
  end

  test "is creatable" do
    params = %{amount: 100, currency: "USD", payment_method_types: ["card"], source: "src_123"}
    assert {:ok, %Stripe.PaymentIntent{}} = Stripe.PaymentIntent.create(params)
    assert_stripe_requested(:post, "/v1/payment_intents")
  end

  test "is confirmable" do
    assert {:ok, %Stripe.PaymentIntent{}} = Stripe.PaymentIntent.confirm("pi_123", %{})

    assert_stripe_requested(:post, "/v1/payment_intents/pi_123/confirm")
  end

  test "is cancelable" do
    assert {:ok, %Stripe.PaymentIntent{}} =
             Stripe.PaymentIntent.cancel("pi_123", %{cancellation_reason: "requested_by_customer"})

    assert_stripe_requested(:post, "/v1/payment_intents/pi_123/cancel")
  end

  test "is updateable" do
    assert {:ok, %Stripe.PaymentIntent{}} =
             Stripe.PaymentIntent.update("pi_123", %{metadata: %{foo: "bar"}})

    assert_stripe_requested(:post, "/v1/payment_intents/pi_123")
  end

  test "is captureable" do
    {:ok, %Stripe.PaymentIntent{} = payment_intent} = Stripe.PaymentIntent.retrieve("pi_123", %{})

    assert_stripe_requested(:get, "/v1/payment_intents/pi_123")

    assert {:ok, %Stripe.PaymentIntent{}} =
             Stripe.PaymentIntent.capture(payment_intent, %{amount_to_capture: 1000})

    assert_stripe_requested(:post, "/v1/payment_intents/pi_123/capture")
  end
end
