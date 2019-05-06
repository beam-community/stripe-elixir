defmodule Stripe.InvoiceitemTest do
  use Stripe.StripeCase, async: true

  describe "create/2" do
    test "creates an invoice" do
      assert {:ok, %Stripe.Invoiceitem{}} =
               Stripe.Invoiceitem.create(%{customer: "cus_123", currency: "usd"})

      assert_stripe_requested(:post, "/v1/invoiceitems")
    end
  end

  describe "retrieve/2" do
    test "retrieves an invoice" do
      assert {:ok, %Stripe.Invoiceitem{}} = Stripe.Invoiceitem.retrieve("ii_1234")
      assert_stripe_requested(:get, "/v1/invoiceitems/ii_1234")
    end
  end

  describe "update/3" do
    test "updates an invoice" do
      params = %{metadata: %{key: "value"}}
      assert {:ok, %Stripe.Invoiceitem{}} = Stripe.Invoiceitem.update("ii_1234", params)
      assert_stripe_requested(:post, "/v1/invoiceitems/ii_1234")
    end
  end

  describe "delete/2" do
    test "deletes an invoice" do
      {:ok, invoiceitem} = Stripe.Invoiceitem.retrieve("ii_1234")
      assert_stripe_requested(:get, "/v1/invoiceitems/#{invoiceitem.id}")

      assert {:ok, _} = Stripe.Invoiceitem.delete("ii_1234")
      assert_stripe_requested(:delete, "/v1/invoiceitems/#{invoiceitem.id}")
    end
  end

  describe "list/2" do
    test "lists all invoiceitems" do
      assert {:ok, %Stripe.List{data: invoiceitems}} = Stripe.Invoiceitem.list()
      assert_stripe_requested(:get, "/v1/invoiceitems")
      assert is_list(invoiceitems)
      assert %Stripe.Invoiceitem{} = hd(invoiceitems)
    end
  end
end
