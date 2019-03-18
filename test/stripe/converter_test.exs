defmodule Stripe.ConverterTest do
  use ExUnit.Case

  alias Stripe.Converter

  test "converts a 'customer.updated' event response properly" do
    expected_result = %Stripe.Event{
      account: "acct_0000000000000000",
      api_version: "2016-07-06",
      created: 1_483_537_031,
      data: %{
        object: %Stripe.Customer{
          id: "cus_9ryX7lUQ4Dcpf7",
          object: "customer",
          account_balance: 0,
          created: 1_483_535_628,
          currency: nil,
          default_source: nil,
          delinquent: false,
          description: nil,
          email: "test2@mail.com",
          livemode: false,
          metadata: %{},
          sources: %Stripe.List{
            object: "list",
            data: [],
            has_more: false,
            total_count: 0,
            url: "/v1/customers/cus_9ryX7lUQ4Dcpf7/sources"
          },
          subscriptions: %Stripe.List{
            object: "list",
            data: [],
            has_more: false,
            total_count: 0,
            url: "/v1/customers/cus_9ryX7lUQ4Dcpf7/subscriptions"
          },
          tax_info: nil
        },
        previous_attributes: %{
          description: "testcustomer",
          email: "test@mail.com",
          metadata: %{test: "key"}
        }
      },
      id: "evt_19YEx1BKl1F6IRFfb1cFLHzZ",
      livemode: false,
      object: "event",
      pending_webhooks: 0,
      request: "req_9ryusbEBenV0BX",
      type: "customer.updated"
    }

    fixture = Helper.load_fixture("event_with_customer.json")
    result = Converter.convert_result(fixture)

    assert result == expected_result
  end

  test "converts review.opened event properly" do
    expected_result = %Stripe.Event{
      account: "acct_445dwy73iNyGMfgu",
      api_version: "2019-02-19",
      created: 1551702604,
      data: %{
        object: %Stripe.Review{
          billing_zip: nil,
          charge: "ch_1EAFvj73iNyGMfgutk44a8nD",
          closed_reason: nil,
          created: 1551702603,
          id: "prv_1EAFvj73iNyGMfgu81yzEb0D",
          ip_address: "172.16.1.4",
          ip_address_location: %{
            city: "Samara",
            country: "RU",
            latitude: 34,
            longitude: 33,
            region: "65"
          },
          livemode: false,
          object: "review",
          open: true,
          opened_reason: "rule",
          payment_intent: nil,
          reason: "rule",
          session: %{
            browser: "Firefox",
            device: "Other",
            platform: "Mac OS X 10.14",
            version: "65.0"
          }
        }
      },
      id: "evt_1EAFvk73iNyGMfguDACcQT5X",
      livemode: false,
      object: "event",
      pending_webhooks: 4,
      request: %{
        id: "req_3zmMCPEWZ2R24x",
        idempotency_key: "1551702602859892291_xgpCTQ"
      },
      type: "review.opened"
    }
    fixture = Helper.load_fixture("review_opened.json")
    result = Converter.convert_result(fixture)

    assert result == expected_result
  end

  test "converts a list response properly" do
    expected_result = %Stripe.List{
      object: "list",
      data: [
        %Stripe.Card{
          id: "card_19YDiuBKl1F6IRFflldIp6Dc",
          object: "card",
          address_city: nil,
          address_country: nil,
          address_line1: nil,
          address_line1_check: nil,
          address_line2: nil,
          address_state: nil,
          address_zip: nil,
          address_zip_check: nil,
          brand: "Visa",
          country: "US",
          customer: "cus_9ryX7lUQ4Dcpf7",
          cvc_check: nil,
          dynamic_last4: nil,
          exp_month: 8,
          exp_year: 2018,
          funding: "credit",
          last4: "4242",
          metadata: %{},
          name: nil,
          tokenization_method: nil
        },
        %Stripe.Card{
          id: "card_abcdiuBKl1F6IRFflldIp6Dc",
          object: "card",
          address_city: nil,
          address_country: nil,
          address_line1: nil,
          address_line1_check: nil,
          address_line2: nil,
          address_state: nil,
          address_zip: nil,
          address_zip_check: nil,
          brand: "Visa",
          country: "US",
          customer: "cus_9ryX7lUQ4Dcpf7",
          cvc_check: nil,
          dynamic_last4: nil,
          exp_month: 12,
          exp_year: 2020,
          funding: "credit",
          last4: "4242",
          metadata: %{},
          name: nil,
          tokenization_method: nil
        }
      ],
      has_more: false,
      total_count: 2,
      url: "/v1/customers/cus_9ryX7lUQ4Dcpf7/sources"
    }

    fixture = Helper.load_fixture("card_list.json")
    result = Converter.convert_result(fixture)

    assert result == expected_result
  end

  test "converts a customer response with a list of sources properly" do
    expected_result = %Stripe.Customer{
      id: "cus_9ryX7lUQ4Dcpf7",
      object: "customer",
      account_balance: 0,
      created: 1_483_535_628,
      currency: "usd",
      default_source: nil,
      delinquent: false,
      description: nil,
      discount: nil,
      email: "test2@mail.com",
      livemode: false,
      metadata: %{},
      shipping: nil,
      sources: %Stripe.List{
        object: "list",
        data: [],
        has_more: false,
        total_count: 0,
        url: "/v1/customers/cus_9ryX7lUQ4Dcpf7/sources"
      },
      subscriptions: %Stripe.List{
        object: "list",
        data: [],
        has_more: false,
        total_count: 0,
        url: "/v1/customers/cus_9ryX7lUQ4Dcpf7/subscriptions"
      }
    }

    fixture = Helper.load_fixture("customer.json")
    result = Converter.convert_result(fixture)

    assert result == expected_result
  end

  test "converts a discount response properly" do
    expected_result = %Stripe.Discount{
      coupon: %Stripe.Coupon{
        amount_off: nil,
        created: 1_532_358_691,
        currency: nil,
        duration: "repeating",
        duration_in_months: 24,
        id: "student-discount",
        livemode: false,
        max_redemptions: nil,
        metadata: %{},
        object: "coupon",
        percent_off: 50.5,
        redeem_by: nil,
        times_redeemed: 3,
        valid: true
      },
      customer: "cus_DCUJlLSyrGaqab",
      end: 1_595_517_288,
      object: "discount",
      start: 1_532_358_888,
      subscription: "sub_DG9Uq9WOevR9Uo"
    }

    fixture = Helper.load_fixture("discount.json")
    result = Converter.convert_result(fixture)

    assert result == expected_result
  end

  test "converts a recipient response properly" do
    expected_result = %Stripe.Recipient{
      id: "rp_19p5Zf2eZvKYlo2CipXKLoSU",
      object: "recipient",
      active_account: %Stripe.BankAccount{
        id: "ba_19p5Ze2eZvKYlo2C1fs6Ar4u",
        object: "bank_account",
        account_holder_name: nil,
        account_holder_type: nil,
        bank_name: "STRIPE TEST BANK",
        country: "US",
        currency: "usd",
        customer: nil,
        fingerprint: "1JWtPxqbdX5Gamtc",
        last4: "6789",
        metadata: %{},
        routing_number: "110000000",
        status: "new"
      },
      cards: %Stripe.List{
        object: "list",
        data: [],
        has_more: false,
        total_count: 0,
        url: "/v1/recipients/rp_19p5Zf2eZvKYlo2CipXKLoSU/cards"
      },
      created: 1_487_552_563,
      default_card: nil,
      description: nil,
      email: nil,
      livemode: false,
      metadata: %{},
      migrated_to: "acct_1AIQkLDw6ebINMj3",
      name: "John Doe",
      type: "individual"
    }

    fixture = Helper.load_fixture("recipient.json")
    result = Converter.convert_result(fixture)

    assert result == expected_result
  end

  test "converts a deleted response properly" do
    expected_result = %{
      deleted: true,
      id: "card_1A49JREym4h6pgdFkbcuN03L"
    }

    fixture = Helper.load_fixture("card_deleted.json")
    result = Converter.convert_result(fixture)

    assert result == expected_result
  end

  test "converts a checkout.session response properly" do
    expected_result = %Stripe.Session{
      id: "CdWP8EBmSp1tJNIw4ZLF6w3XKd8MNKkEvlnSK7QmwFlDZ8rrjqBn9VI9vKiVdhfE",
      livemode: false,
      object: "checkout.session"
    }

    fixture = Helper.load_fixture("session.json")
    result = Converter.convert_result(fixture)

    assert result == expected_result
  end
end
