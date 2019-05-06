defmodule Stripe.AccountTest do
  use Stripe.StripeCase, async: true

  test "is retrievable using singular endpoint" do
    assert {:ok, %Stripe.Account{}} = Stripe.Account.retrieve()
    assert_stripe_requested(:get, "/v1/account")
  end

  test "is retrievable using plural endpoint" do
    assert {:ok, %Stripe.Account{}} = Stripe.Account.retrieve("acct_123")
    assert_stripe_requested(:get, "/v1/accounts/acct_123")
  end

  test "is creatable" do
    assert {:ok, %Stripe.Account{}} = Stripe.Account.create(%{metadata: %{}, type: "standard"})
    assert_stripe_requested(:post, "/v1/accounts")
  end

  test "is updateable" do
    assert {:ok, %Stripe.Account{id: id}} =
             Stripe.Account.update("acct_123", %{metadata: %{foo: "bar"}})

    assert_stripe_requested(:post, "/v1/accounts/#{id}")
  end

  test "is deletable" do
    assert {:ok, %Stripe.Account{}} = Stripe.Account.delete("acct_123")
    assert_stripe_requested(:delete, "/v1/accounts/acct_123")
  end

  test "is listable" do
    assert {:ok, %Stripe.List{data: accounts}} = Stripe.Account.list()
    assert_stripe_requested(:get, "/v1/accounts")
    assert is_list(accounts)
    assert %Stripe.Account{} = hd(accounts)
  end

  test "is rejectable" do
    {:ok, account} = Stripe.Account.create(%{metadata: %{}, type: "standard"})

    assert_stripe_requested(:post, "/v1/accounts")

    assert {:ok, %Stripe.Account{} = rejected_account} =
             Stripe.Account.reject(account, "terms_of_service")

    assert_stripe_requested(:post, "/v1/accounts/#{account.id}/reject")
    assert account.id == rejected_account.id
    refute rejected_account.transfers_enabled
    refute rejected_account.charges_enabled
  end

  test "can create a login link" do
    assert {:ok, _login_link} = Stripe.Account.create_login_link("acct_123", %{})
    assert_stripe_requested(:post, "/v1/accounts/acct_123/login_links")
  end
end
