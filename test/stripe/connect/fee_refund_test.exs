defmodule Stripe.FeeRefundTest do
  use Stripe.StripeCase, async: true

  describe "retrieve/2" do
    test "retrieves a transfer" do
      assert {:ok, %Stripe.FeeRefund{}} = Stripe.FeeRefund.retrieve("fee_123", "fr_123")

      assert_stripe_requested(:get, "/v1/application_fees/fee_123/refunds/fr_123")
    end
  end

  describe "create/2" do
    test "creates a transfer" do
      params = %{
        amount: 123
      }

      assert {:ok, %Stripe.FeeRefund{}} = Stripe.FeeRefund.create("fee_123", params)
      assert_stripe_requested(:post, "/v1/application_fees/fee_123/refunds")
    end
  end

  describe "update/2" do
    test "updates a transfer" do
      params = %{metadata: %{foo: "bar"}}
      assert {:ok, _transfer} = Stripe.FeeRefund.update("fee_123", "fr_123", params)
      assert_stripe_requested(:post, "/v1/application_fees/fee_123/refunds/fr_123")
    end
  end

  describe "list/2" do
    test "lists all application_fees refunds" do
      assert {:ok, %Stripe.List{data: application_fees}} = Stripe.FeeRefund.list("fee_123")
      assert_stripe_requested(:get, "/v1/application_fees/fee_123/refunds")
      assert is_list(application_fees)
      assert %Stripe.FeeRefund{} = hd(application_fees)
    end
  end
end
