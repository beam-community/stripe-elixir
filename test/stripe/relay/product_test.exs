defmodule Stripe.Relay.ProductTest do
  use Stripe.StripeCase, async: true

  describe "create/2" do
    test "creates an product" do
      assert {:ok, %Stripe.Product{}} = Stripe.Product.create(%{name: "Plus", type: "service"})
      assert_stripe_requested(:post, "/v1/products")
    end

    test "creates an product with more params" do
      params = %{name: "Plus", type: "service", description: "dowat?"}
      assert {:ok, %Stripe.Product{}} = Stripe.Product.create(params)
      assert_stripe_requested(:post, "/v1/products")
    end
  end

  describe "retrieve/2" do
    test "retrieves an product" do
      assert {:ok, %Stripe.Product{}} = Stripe.Product.retrieve("Plus")
      assert_stripe_requested(:get, "/v1/products/Plus")
    end
  end

  describe "update/2" do
    test "updates an product" do
      params = %{metadata: %{key: "value"}}
      assert {:ok, %Stripe.Product{}} = Stripe.Product.update("Plus", params)
      assert_stripe_requested(:post, "/v1/products/Plus")
    end
  end

  describe "list/2" do
    test "lists all products" do
      assert {:ok, %Stripe.List{data: products}} = Stripe.Product.list()
      assert_stripe_requested(:get, "/v1/products")
      assert is_list(products)
      assert %Stripe.Product{} = hd(products)
    end

    test "lists all products with params" do
      params = %{active: false}
      assert {:ok, %Stripe.List{data: products}} = Stripe.Product.list(params)
      assert_stripe_requested(:get, "/v1/products", query: %{active: false})
      assert is_list(products)
      assert %Stripe.Product{} = hd(products)
    end
  end

  describe "delete/1" do
    test "deletes a product" do
      {:ok, product} = Stripe.Product.retrieve("Plus")
      assert_stripe_requested(:get, "/v1/products/#{product.id}")

      assert {:ok, _} = Stripe.Product.delete("Plus")
      assert_stripe_requested(:delete, "/v1/products/#{product.id}")
    end
  end
end
