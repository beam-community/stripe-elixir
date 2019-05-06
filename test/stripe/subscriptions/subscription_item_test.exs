defmodule Stripe.SubscriptionItemTest do
  use Stripe.StripeCase, async: true

  describe "retrieve/2" do
    test "retrieves a subscription" do
      assert {:ok, %Stripe.SubscriptionItem{}} = Stripe.SubscriptionItem.retrieve("sub_123")
      assert_stripe_requested(:get, "/v1/subscription_items/sub_123")
    end
  end

  describe "create/2" do
    test "creates a subscription" do
      params = %{
        subscription: "sub_123",
        plan: "plan_123"
      }

      assert {:ok, %Stripe.SubscriptionItem{}} = Stripe.SubscriptionItem.create(params)
      assert_stripe_requested(:post, "/v1/subscription_items")
    end
  end

  describe "update/2" do
    test "updates a subscription item" do
      params = %{metadata: %{foo: "bar"}}
      assert {:ok, subscription_item} = Stripe.SubscriptionItem.update("sub_123", params)
      assert_stripe_requested(:post, "/v1/subscription_items/#{subscription_item.id}")
    end
  end

  describe "delete/2" do
    test "deletes a subscription item" do
      {:ok, subscription_item} = Stripe.SubscriptionItem.retrieve("sub_123")
      assert_stripe_requested(:get, "/v1/subscription_items/#{subscription_item.id}")

      assert {:ok, %Stripe.SubscriptionItem{}} = Stripe.SubscriptionItem.delete("sub_123")
      assert_stripe_requested(:delete, "/v1/subscription_items/#{subscription_item.id}")
    end
  end

  describe "list/2" do
    test "lists all subscription_items" do
      assert {:ok, %Stripe.List{data: subscriptions}} = Stripe.SubscriptionItem.list("sub_123")
      assert_stripe_requested(:get, "/v1/subscription_items", query: %{subscription: "sub_123"})
      assert is_list(subscriptions)
      assert %Stripe.SubscriptionItem{} = hd(subscriptions)
    end
  end
end
