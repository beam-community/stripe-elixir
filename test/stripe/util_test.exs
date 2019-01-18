defmodule Stripe.UtilTest do
  use ExUnit.Case

  import Stripe.Util

  describe "object_name_to_module/1" do
    test "converts all object names to their proper modules" do
      assert object_name_to_module("account") == Stripe.Account
      assert object_name_to_module("application_fee") == Stripe.ApplicationFee
      assert object_name_to_module("fee_refund") == Stripe.FeeRefund
      assert object_name_to_module("bank_account") == Stripe.BankAccount
      assert object_name_to_module("card") == Stripe.Card
      assert object_name_to_module("coupon") == Stripe.Coupon
      assert object_name_to_module("customer") == Stripe.Customer
      assert object_name_to_module("dispute") == Stripe.Dispute
      assert object_name_to_module("event") == Stripe.Event
      assert object_name_to_module("external_account") == Stripe.ExternalAccount
      assert object_name_to_module("file") == Stripe.FileUpload
      assert object_name_to_module("invoice") == Stripe.Invoice
      assert object_name_to_module("invoiceitem") == Stripe.Invoiceitem
      assert object_name_to_module("line_item") == Stripe.LineItem
      assert object_name_to_module("list") == Stripe.List
      assert object_name_to_module("order") == Stripe.Order
      assert object_name_to_module("order_return") == Stripe.OrderReturn
      assert object_name_to_module("plan") == Stripe.Plan
      assert object_name_to_module("product") == Stripe.Product
      assert object_name_to_module("refund") == Stripe.Refund
      assert object_name_to_module("subscription") == Stripe.Subscription
      assert object_name_to_module("subscription_item") == Stripe.SubscriptionItem
      assert object_name_to_module("sku") == Stripe.Sku
      assert object_name_to_module("transfer") == Stripe.Transfer
      assert object_name_to_module("transfer_reversal") == Stripe.TransferReversal
      assert object_name_to_module("token") == Stripe.Token
    end
  end

  describe "multipart_key/1" do
    test "handle all multipart keys" do
      assert multipart_key(:file) == :file
      assert multipart_key(:foo) == "foo"
      assert multipart_key("foo") == "foo"
    end
  end
end
