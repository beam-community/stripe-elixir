defmodule Stripe.RefundTest do
  use Stripe.StripeCase, async: true

  test "charge refunds is listable" do
    assert {:ok, %Stripe.List{data: refunds}} = Stripe.Refund.list(%{charge: "ab123"})
    assert_stripe_requested(:get, "/v1/refunds?charge=ab123")
    assert is_list(refunds)
    assert %Stripe.Refund{} = hd(refunds)
  end

  test "charge refund is retrievable" do
    assert {:ok, %Stripe.Refund{}} = Stripe.Refund.retrieve("re123")
    assert_stripe_requested(:get, "/v1/refunds/re123")
  end

  test "is creatable" do
    assert {:ok, %Stripe.Refund{}} = Stripe.Refund.create(%{charge: "ch_123"})
    assert_stripe_requested(:post, "/v1/refunds")
  end

  test "is updateable" do
    assert {:ok, refund} = Stripe.Refund.update("re_123", %{metadata: %{foo: "bar"}})
    assert_stripe_requested(:post, "/v1/refunds/#{refund.id}")
  end

  test "is cancellable" do
    assert {:ok, refund} = Stripe.Refund.cancel("re_123")
    assert_stripe_requested(:post, "/v1/refunds/#{refund.id}/cancel")
  end
end
