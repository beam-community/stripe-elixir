defmodule Stripe.ChargeTest do
  use Stripe.StripeCase, async: true

  test "is listable" do
    assert {:ok, %Stripe.List{data: charges}} = Stripe.Charge.list()
    assert_stripe_requested(:get, "/v1/charges")
    assert is_list(charges)
    assert %Stripe.Charge{} = hd(charges)
  end

  test "is retrievable" do
    assert {:ok, %Stripe.Charge{}} = Stripe.Charge.retrieve("ch_123")
    assert_stripe_requested(:get, "/v1/charges/ch_123")
  end

  test "is creatable" do
    params = %{amount: 100, currency: "USD", source: "src_123"}
    assert {:ok, %Stripe.Charge{}} = Stripe.Charge.create(params)
    assert_stripe_requested(:post, "/v1/charges")
  end

  test "is updateable" do
    assert {:ok, %Stripe.Charge{}} = Stripe.Charge.update("ch_123", %{metadata: %{foo: "bar"}})
    assert_stripe_requested(:post, "/v1/charges/ch_123")
  end

  test "is captureable" do
    {:ok, %Stripe.Charge{} = charge} = Stripe.Charge.retrieve("ch_123")
    assert_stripe_requested(:get, "/v1/charges/ch_123")

    assert {:ok, %Stripe.Charge{}} = Stripe.Charge.capture(charge, %{amount: 1000})
    assert_stripe_requested(:post, "/v1/charges/ch_123/capture")
  end

  test "is captureable with idempotency opts" do
    opts = [idempotency_key: "test"]
    {:ok, %Stripe.Charge{} = charge} = Stripe.Charge.retrieve("ch_123")
    assert_stripe_requested(:get, "/v1/charges/ch_123")

    assert {:ok, %Stripe.Charge{}} = Stripe.Charge.capture(charge, %{amount: 1000}, opts)

    assert_stripe_requested(:post, "/v1/charges/ch_123/capture",
      headers: {"Idempotency-Key", "test"}
    )
  end

  test "is retrievable with expansions opts" do
    opts = [expand: ["balance_transaction"]]
    assert {:ok, %Stripe.Charge{}} = Stripe.Charge.retrieve("ch_123", opts)

    assert_stripe_requested(:get, "/v1/charges/ch_123",
      query: %{"expand[0]": "balance_transaction"}
    )
  end
end
