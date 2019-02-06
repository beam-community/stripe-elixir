defmodule Stripe.LineItemTest do
  use Stripe.StripeCase, async: true

  describe "retrieve/2" do
    test "retrieves an invoice" do
      assert {:ok, %Stripe.List{data: line_items}} = Stripe.LineItem.retrieve("in_1234")
      assert_stripe_requested(:get, "/v1/invoices/in_1234/lines")
      assert is_list(line_items)
      assert %Stripe.LineItem{} = hd(line_items)
    end
  end
end
