defmodule Stripe.PlanTest do
  use Stripe.StripeCase, async: true

  describe "create/2" do
    test "creates a Plan for a customer" do
      params = %{
        amount: 5000,
        currency: "usd",
        id: "sapphire-elite",
        interval: "month",
        nickname: "Sapphire elite",
        product: "abc_123",
        trial_period_days: 10
      }

      assert {:ok, %Stripe.Plan{}} = Stripe.Plan.create(params)
      assert_stripe_requested(:post, "/v1/plans")
    end

    test "creates a Plan for a customer with tiers" do
      params = %{
        amount: 5000,
        billing_scheme: "tiered",
        currency: "usd",
        id: "sapphire-elite",
        interval: "month",
        nickname: "Sapphire elite",
        product: "abc_123",
        tiers: [%{amount: 10, up_to: 12}]
      }

      assert {:ok, %Stripe.Plan{}} = Stripe.Plan.create(params)
      assert_stripe_requested(:post, "/v1/plans")
    end
  end

  describe "retrieve/2" do
    test "retrieves a Plan" do
      assert {:ok, %Stripe.Plan{}} = Stripe.Plan.retrieve("sapphire-elite")
      assert_stripe_requested(:get, "/v1/plans/sapphire-elite")
    end
  end

  describe "update/2" do
    test "updates a Plan" do
      params = %{metadata: %{foo: "bar"}}
      assert {:ok, plan} = Stripe.Plan.update("sapphire-elite", params)
      assert_stripe_requested(:post, "/v1/plans/#{plan.id}")
    end
  end

  describe "delete/2" do
    test "deletes a Plan" do
      {:ok, plan} = Stripe.Plan.retrieve("sapphire-elite")
      assert_stripe_requested(:get, "/v1/plans/#{plan.id}")

      assert {:ok, %Stripe.Plan{}} = Stripe.Plan.delete(plan)
      assert_stripe_requested(:delete, "/v1/plans/#{plan.id}")
    end
  end

  describe "list/2" do
    test "lists all Plans" do
      assert {:ok, %Stripe.List{data: plans}} = Stripe.Plan.list()
      assert_stripe_requested(:get, "/v1/plans")
      assert is_list(plans)
      assert %Stripe.Plan{} = hd(plans)
    end
  end
end
