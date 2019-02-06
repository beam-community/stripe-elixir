defmodule Stripe.SubscriptionItem.UsageTest do
  use Stripe.StripeCase, async: true
  
  describe "create/2" do
    test "create usage record" do
      item_id = "si_123"

      params = %{
        quantity: 10,
        timestamp: 1543335582
      }

      assert {:ok, record} = Stripe.SubscriptionItem.Usage.create(item_id, params)
      assert %{subscription_item: _sub_id} = record
      assert_stripe_requested(:post, "/v1/subscription_items/#{item_id}/usage_records")
    end
  
    test "create usage record with subsctiption item" do
      item = 
        %Stripe.SubscriptionItem{
          id: "si_123"
        }

      params = %{
        quantity: 10,
        timestamp: 1543335582
      }

      assert {:ok, record} = Stripe.SubscriptionItem.Usage.create(Map.get(item, :id), params)
      assert %{subscription_item: _sub_id} = record
      assert_stripe_requested(:post, "/v1/subscription_items/#{item.id}/usage_records")
    end
  end

  describe "list/1" do
    test "list usage records for subscription items" do
      item_id = "si_123"

      assert {:ok, %Stripe.List{data: usages}} = Stripe.SubscriptionItem.Usage.list(item_id)
      assert_stripe_requested(:get, "/v1/subscription_items/#{item_id}/usage_record_summaries")
      assert is_list(usages)
      assert %{subscription_item: _sub_item_id} = hd(usages)
    end
  end

  describe "list/2" do
    test "list usage records for subscription items with params" do
      item_id = "si_123"

      params = %{
        limit: 10
      }

      assert {:ok, %Stripe.List{data: usages}} = Stripe.SubscriptionItem.Usage.list(item_id, params)
      assert_stripe_requested(:get, "/v1/subscription_items/#{item_id}/usage_record_summaries")
      assert is_list(usages)
      assert %{subscription_item: _sub_item_id} = hd(usages)
    end
  end
end
