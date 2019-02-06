defmodule Stripe.RecipientTest do
  use Stripe.StripeCase, async: true

  test "is retrievable using plural endpoint" do
    assert {:ok, %Stripe.Recipient{}} = Stripe.Recipient.retrieve("recip_123")
    assert_stripe_requested(:get, "/v1/recipients/recip_123")
  end

  test "is creatable" do
    assert {:ok, %Stripe.Recipient{}} =
             Stripe.Recipient.create(%{name: "scooter", type: "standard"})

    assert_stripe_requested(:post, "/v1/recipients")
  end

  test "is updateable" do
    assert {:ok, %Stripe.Recipient{id: id}} =
             Stripe.Recipient.update("recip_123", %{metadata: %{foo: "bar"}})

    assert_stripe_requested(:post, "/v1/recipients/#{id}")
  end

  test "is deletable" do
    assert {:ok, %Stripe.Recipient{}} = Stripe.Recipient.delete("recip_123")
    assert_stripe_requested(:delete, "/v1/recipients/recip_123")
  end

  test "is listable" do
    assert {:ok, %Stripe.List{data: recipients}} = Stripe.Recipient.list()
    assert_stripe_requested(:get, "/v1/recipients")
    assert is_list(recipients)
    assert %Stripe.Recipient{} = hd(recipients)
  end
end
