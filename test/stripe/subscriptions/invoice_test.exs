defmodule Stripe.InvoiceTest do
  use Stripe.StripeCase, async: true

  describe "create/2" do
    test "creates an invoice" do
      assert {:ok, %Stripe.Invoice{}} = Stripe.Invoice.create(%{customer: "cus_123"})
      assert_stripe_requested(:post, "/v1/invoices")
    end
  end

  describe "retrieve/2" do
    test "retrieves an invoice" do
      assert {:ok, %Stripe.Invoice{}} = Stripe.Invoice.retrieve("in_123")
      assert_stripe_requested(:get, "/v1/invoices/in_123")
    end
  end

  describe "upcoming/2" do
    test "retrieves an upcoming invoice for a customer" do
      params = %{customer: "cus_123", subscription: "sub_123"}
      assert {:ok, %Stripe.Invoice{}} = Stripe.Invoice.upcoming(params)

      assert_stripe_requested(
        :get,
        "/v1/invoices/upcoming",
        query: %{customer: "cust_123", subscription: "sub_123"}
      )
    end

    test "retrieves an upcoming invoice for a customer with items" do
      items = [%{plan: "gold", quantity: 2}]
      params = %{customer: "cus_123", subscription_items: items}
      assert {:ok, %Stripe.Invoice{}} = Stripe.Invoice.upcoming(params)

      assert_stripe_requested(
        :get,
        "/v1/invoices/upcoming",
        query: %{
          :customer => "cust_123",
          :"susbscription_items[][plan]" => "gold",
          :"subscription_items[][quantity]" => 2
        }
      )
    end

    test "can be called with an empty string" do
      params = %{coupon: "", customer: "cus_123"}
      assert {:ok, %Stripe.Invoice{}} = Stripe.Invoice.upcoming(params)

      assert_stripe_requested(
        :get,
        "/v1/invoices/upcoming",
        query: %{customer: "cus_123", coupon: ""}
      )
    end
  end

  describe "update/2" do
    test "updates an invoice" do
      params = %{metadata: %{key: "value"}}
      assert {:ok, %Stripe.Invoice{}} = Stripe.Invoice.update("in_123", params)
      assert_stripe_requested(:post, "/v1/invoices/in_123")
    end
  end

  describe "pay/3" do
    test "pays an invoice" do
      {:ok, invoice} = Stripe.Invoice.retrieve("in_123")
      assert {:ok, %Stripe.Invoice{} = _paid_invoice} = Stripe.Invoice.pay(invoice, %{})
      assert_stripe_requested(:post, "/v1/invoices/#{invoice.id}/pay")
    end

    test "pays an invoice with a specific source" do
      {:ok, invoice} = Stripe.Invoice.retrieve("in_123")
      params = %{source: "src_123"}
      assert {:ok, %Stripe.Invoice{} = _paid_invoice} = Stripe.Invoice.pay(invoice, params)

      assert_stripe_requested(:post, "/v1/invoices/#{invoice.id}/pay", body: %{source: "src_123"})
    end
  end

  describe "list/2" do
    test "lists all invoices" do
      assert {:ok, %Stripe.List{data: invoices}} = Stripe.Invoice.list()
      assert_stripe_requested(:get, "/v1/invoices")
      assert is_list(invoices)
      assert %Stripe.Invoice{} = hd(invoices)
    end
  end

  describe "void/2" do
    test "voids an invoice" do
      {:ok, invoice} = Stripe.Invoice.retrieve("in_123")
      assert {:ok, %Stripe.Invoice{} = _voided_invoice} = Stripe.Invoice.void(invoice)
      assert_stripe_requested(:post, "/v1/invoices/#{invoice.id}/void")
    end
  end
end
