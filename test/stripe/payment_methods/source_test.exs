defmodule Stripe.SourceTest do
  use Stripe.StripeCase, async: true

  describe "create/2" do
    test "creates a source for a customer" do
      assert {:ok, %Stripe.Source{}} = Stripe.Source.create(%{type: "bitcoin"})
      assert_stripe_requested(:post, "/v1/sources")
    end
  end

  describe "retrieve/2" do
    test "retrieves a source" do
      assert {:ok, %Stripe.Source{}} = Stripe.Source.retrieve("src_123", %{})
      assert_stripe_requested(:get, "/v1/sources/src_123")
    end
  end

  describe "update/2" do
    test "updates a source" do
      assert {:ok, %Stripe.Source{}} = Stripe.Source.update("src_123", %{})
      assert_stripe_requested(:post, "/v1/sources/src_123")
    end
  end

  describe "attach/2" do
    test "attaches a source to a customer" do
      assert {:ok, _} = Stripe.Source.attach(%{customer: "cus_123", source: "src_123"})

      assert_stripe_requested(:post, "/v1/customers/cus_123/sources")
    end
  end

  describe "detach/2" do
    test "detaches a source from a customer" do
      assert {:ok, %{id: "src_123"}} = Stripe.Source.detach("src_123", %{customer: "cus_123"})

      assert_stripe_requested(:delete, "/v1/customers/cus_123/sources/src_123")
    end
  end
end
