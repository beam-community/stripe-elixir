defmodule Stripe.OrderTest do
  use Stripe.StripeCase, async: true

  describe "create/2" do
    test "is creatable" do
      assert {:ok, %Stripe.Order{}} = Stripe.Order.create(%{currency: "USD"})
      assert_stripe_requested(:post, "/v1/orders")
    end
  end

  describe "retrieve/2" do
    test "is retrievable" do
      assert {:ok, %Stripe.Order{}} = Stripe.Order.retrieve("order_123")
      assert_stripe_requested(:get, "/v1/orders/order_123")
    end
  end

  describe "update/3" do
    test "is updateable" do
      params = %{metadata: %{key: "value"}}
      assert {:ok, %Stripe.Order{}} = Stripe.Order.update("order_123", params)
      assert_stripe_requested(:post, "/v1/orders/order_123")
    end
  end

  describe "pay/3" do
    test "is payable" do
      assert {:ok, %Stripe.Order{}} = Stripe.Order.pay("order_123")
      assert_stripe_requested(:post, "/v1/orders/order_123/pay")
    end

    @tag :skip
    test "is payable with card_info" do
      params = %{
        card_info: %{exp_month: 12, exp_year: 2022, number: "2222", object: "card", cvc: 150}
      }

      assert {:ok, %Stripe.Order{}} = Stripe.Order.pay("order_123", params)
      assert_stripe_requested(:post, "/v1/orders/order_123/pay")
    end
  end

  describe "return/3" do
    test "is returnable" do
      assert {:ok, %Stripe.OrderReturn{}} = Stripe.Order.return("order_123")
      assert_stripe_requested(:post, "/v1/orders/order_123/returns")
    end
  end

  describe "list/2" do
    test "is listable" do
      assert {:ok, %Stripe.List{data: orders}} = Stripe.Order.list()
      assert_stripe_requested(:get, "/v1/orders")
      assert is_list(orders)
      assert %Stripe.Order{} = hd(orders)
    end

    test "is listable with params" do
      params = %{status: "paid"}
      assert {:ok, %Stripe.List{data: orders}} = Stripe.Order.list(params)
      assert_stripe_requested(:get, "/v1/orders", query: params)
      assert is_list(orders)
      assert %Stripe.Order{} = hd(orders)
    end
  end
end
