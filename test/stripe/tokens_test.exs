defmodule Stripe.TokensTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @tags disabled: false
  test "Create bank account token works"  do
    use_cassette "Stripe.TokensTest/bank_account" do
      params = [
        bank_account: [
          country: "US",
          currency: "usd",
          routing_number: "110000000",
          account_number: "000123456789"
        ]
      ]
      case Stripe.Tokens.create(params) do
        {:ok, res} ->
          #Apex.ap res
          assert res.id
          assert res.type == "bank_account"
          {:error, err} -> flunk err
      end
    end
  end

  @tags disabled: false
  test "Create credit card token works"  do
    use_cassette "Stripe.TokensTest/credit_card" do
      params = [
        card: [
          number: "4242424242424242",
          exp_month: 8,
          exp_year: 2016,
          cvc: "314"
        ]
      ]
      case Stripe.Tokens.create(params) do
        {:ok, res} ->
          #Apex.ap res
          assert res.id
          assert res.type == "card"
          {:error, err} -> flunk err
      end
    end
  end

  @tags disabled: false
  test "Create credit card token w/key works"  do
    use_cassette "Stripe.TokensTest/credit_card_with_key" do
      params = [
        card: [
          number: "4242424242424242",
          exp_month: 8,
          exp_year: 2016,
          cvc: "314"
        ]
      ]
      case Stripe.Tokens.create(params, Stripe.config_or_env_key) do
        {:ok, res} ->
          #Apex.ap res
          assert res.id
          assert res.type == "card"
          {:error, err} -> flunk err
      end
    end
  end

  @tags disabled: false
  test "Get by id works" do
    use_cassette "Stripe.TokensTest/get_by_id" do
      {:ok, token} = Stripe.Tokens.create [
        card: [
          number: "4242424242424242",
          exp_month: 8,
          exp_year: 2016,
          cvc: "314"
        ]
      ]
      #Apex.ap token
      case Stripe.Tokens.get token.id do
        {:ok, res} ->
          #Apex.ap res
          assert res.id
          assert res.type == "card"
          {:error, err} -> flunk err
      end
    end
  end

  @tags disabled: false
  test "Get by id w/key works" do
    use_cassette "Stripe.TokensTest/get_by_id_with_key" do
      {:ok, token} = Stripe.Tokens.create [
        card: [
          number: "4242424242424242",
          exp_month: 8,
          exp_year: 2016,
          cvc: "314"
        ]
      ]
      #Apex.ap token
      case Stripe.Tokens.get token.id, Stripe.config_or_env_key do
        {:ok, res} ->
          #Apex.ap res
          assert res.id
          assert res.type == "card"
          {:error, err} -> flunk err
      end
    end
  end


  @tags disabled: false
  test "Charge with token works" do
    use_cassette "Stripe.TokensTest/chardge_with_token" do
      {:ok, token} = Stripe.Tokens.create [
        card: [
          number: "4242424242424242",
          exp_month: 8,
          exp_year: 2016,
          cvc: "314"
        ]
      ]
      #Apex.ap token
      params = [
        source: token.id
      ]
      case Stripe.Charges.create 100, params do
        {:ok, res} ->
          #Apex.ap res
          assert res.id
          assert res.status == "succeeded"
          assert res.paid == true
          assert res.object == "charge"
          {:error, err} -> flunk err
      end
    end
  end
end
