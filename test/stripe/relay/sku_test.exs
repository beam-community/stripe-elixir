defmodule Stripe.SkuTest do
  use Stripe.StripeCase, async: true

  test "is creatable" do
    inventory = %{type: "finite", quantity: 500}

    assert {:ok, %Stripe.Sku{}} =
             Stripe.Sku.create(%{
               currency: "USD",
               product: "prod_123",
               price: 100,
               inventory: inventory
             })

    assert_stripe_requested(:post, "/v1/skus")
  end

  test "is retrievable" do
    assert {:ok, %Stripe.Sku{}} = Stripe.Sku.retrieve("sku_123")
    assert_stripe_requested(:get, "/v1/skus/sku_123")
  end

  test "is updateable" do
    params = %{metadata: %{key: "value"}}
    assert {:ok, %Stripe.Sku{}} = Stripe.Sku.update("sku_123", params)
    assert_stripe_requested(:post, "/v1/skus/sku_123")
  end

  test "is updateable via active attribute" do
    params = %{active: false}
    assert {:ok, %Stripe.Sku{}} = Stripe.Sku.update("sku_123", params)
    assert_stripe_requested(:post, "/v1/skus/sku_123")
  end

  test "is deletable" do
    assert {:ok, %Stripe.Sku{}} = Stripe.Sku.delete("sku_123")
    assert_stripe_requested(:delete, "/v1/skus/sku_123")
  end

  test "is listable" do
    assert {:ok, %Stripe.List{data: skus}} = Stripe.Sku.list()
    assert_stripe_requested(:get, "/v1/skus")
    assert is_list(skus)
    assert %Stripe.Sku{} = hd(skus)
  end

  test "is listable with params" do
    params = %{active: false, in_stock: false}
    assert {:ok, %Stripe.List{data: _skus}} = Stripe.Sku.list(params)
    assert_stripe_requested(:get, "/v1/skus", query: params)
  end
end
