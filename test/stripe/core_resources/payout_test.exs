defmodule Stripe.PayoutTest do
  use Stripe.StripeCase, async: true

  describe "create/2" do
    test "creates a card for a customer" do
      params = %{amount: 100, currency: "USD", source_type: "card"}
      assert {:ok, %Stripe.Payout{}} = Stripe.Payout.create(params)
      assert_stripe_requested(:post, "/v1/payouts")
    end
  end

  describe "retrieve/2" do
    test "retrieves a card" do
      assert {:ok, %Stripe.Payout{}} = Stripe.Payout.retrieve("py_123")
      assert_stripe_requested(:get, "/v1/payouts/py_123")
    end
  end

  describe "update/2" do
    test "updates a card" do
      assert {:ok, %Stripe.Payout{}} = Stripe.Payout.update("py_123", %{metadata: %{foo: "bar"}})
      assert_stripe_requested(:post, "/v1/payouts/py_123")
    end
  end

  describe "list/2" do
    test "lists all cards" do
      assert {:ok, %Stripe.List{data: payouts}} = Stripe.Payout.list()
      assert_stripe_requested(:get, "/v1/payouts")
      assert is_list(payouts)
      assert %Stripe.Payout{} = hd(payouts)
    end
  end

  describe "cancel/1" do
    test "cancels a payout" do
      assert {:ok, %Stripe.Payout{}} = Stripe.Payout.cancel("py_123")
      assert_stripe_requested(:post, "/v1/payouts/py_123/cancel")
    end
  end
end
