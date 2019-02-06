defmodule Stripe.ConfigTest do
  use ExUnit.Case

  defmodule ValueExpansionTestModule do
    def value do
      "test-test"
    end
  end

  test "returns the requested configuration value" do
    Application.put_env(:stripity_stripe, :__test, "test-test")
    assert(Stripe.Config.resolve(:__test) == "test-test")
  end

  test "evaluates functions" do
    Application.put_env(:stripity_stripe, :__test, fn -> "test-test" end)
    assert(Stripe.Config.resolve(:__test) == "test-test")
  end

  test "applies tuples" do
    Application.put_env(
      :stripity_stripe,
      :__test,
      {ValueExpansionTestModule, :value, []}
    )

    assert(Stripe.Config.resolve(:__test) == "test-test")
  end

  test "if no value exists for the given key it uses the default value" do
    Application.put_env(
      :stripity_stripe,
      :__test,
      {ValueExpansionTestModule, :value, []}
    )

    assert(Stripe.Config.resolve(:__fake_test, "test-test") == "test-test")
  end

  test "raises if the key isn't an atom" do
    Application.put_env(
      :stripity_stripe,
      :__test,
      {ValueExpansionTestModule, :value, []}
    )

    assert_raise ArgumentError, ~r/to be an atom/, fn ->
      Stripe.Config.resolve("__test", "test-test")
    end
  end
end
