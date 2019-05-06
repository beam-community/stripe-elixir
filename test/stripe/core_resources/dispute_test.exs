defmodule Stripe.DisputeTest do
  use Stripe.StripeCase, async: true

  test "is retrievable" do
    assert {:ok, %Stripe.Dispute{}} = Stripe.Dispute.retrieve("cus_123")
    assert_stripe_requested(:get, "/v1/disputes/cus_123")
  end

  test "is updateable" do
    params = %{metadata: %{key: "value"}}
    assert {:ok, %Stripe.Dispute{}} = Stripe.Dispute.update("cus_123", params)
    assert_stripe_requested(:post, "/v1/disputes/cus_123")
  end

  test "is closeable" do
    {:ok, dispute} = Stripe.Dispute.retrieve("cus_123")
    assert_stripe_requested(:get, "/v1/disputes/#{dispute.id}")

    assert {:ok, %Stripe.Dispute{}} = Stripe.Dispute.close(dispute)
    assert_stripe_requested(:post, "/v1/disputes/#{dispute.id}/close")
  end

  test "is listable" do
    assert {:ok, %Stripe.List{data: disputes}} = Stripe.Dispute.list()
    assert_stripe_requested(:get, "/v1/disputes")
    assert is_list(disputes)
    assert %Stripe.Dispute{} = hd(disputes)
  end
end
