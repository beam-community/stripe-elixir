defmodule Stripe.CardTest do
  use Stripe.StripeCase, async: true

  test "exports functions" do
    assert [
             {:__from_json__, 1},
             {:__struct__, 0},
             {:__struct__, 1},
             {:delete_external_account, 2},
             {:delete_external_account, 3},
             {:delete_source, 2},
             {:delete_source, 3},
             {:delete_source, 4},
             {:update_external_account, 2},
             {:update_external_account, 3},
             {:update_external_account, 4},
             {:update_source, 2},
             {:update_source, 3},
             {:update_source, 4}
           ] = Stripe.Card.__info__(:functions)
  end

  describe "update/2" do
    test "updates a card" do
      assert {:ok, _} = Stripe.Card.update_source("cus_123", "card_123", %{name: "sco"})
      assert_stripe_requested(:post, "/v1/customers/cus_123/sources/card_123")
    end
  end

  describe "delete/2" do
    test "deletes a card" do
      assert {:ok, _} = Stripe.Card.delete_source("cus_123", "card_123")
      assert_stripe_requested(:delete, "/v1/customers/cus_123/sources/card_123")
    end
  end
end
