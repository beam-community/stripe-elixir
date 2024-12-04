defmodule Stripe.BankAccountTest do
  use Stripe.StripeCase, async: true

  describe "update/2" do
    test "updates a bank account" do
      assert {:ok, _} = Stripe.BankAccount.update_source("cus_123", "ba_123")
      assert_stripe_requested(:post, "/v1/customers/cus_123/sources/ba_123")
    end
  end

  describe "delete/2" do
    test "deletes a bank account" do
      assert {:ok, _} = Stripe.BankAccount.delete_source("cus_123", "ba_123")
      assert_stripe_requested(:delete, "/v1/customers/cus_123/sources/ba_123")
    end
  end

  describe "verify/2" do
    test "verifys a bank account" do
      assert {:ok, _} = Stripe.BankAccount.verify("cus_123", "ba_123")
      assert_stripe_requested(:post, "/v1/customers/cus_123/sources/ba_123/verify")
    end
  end
end
