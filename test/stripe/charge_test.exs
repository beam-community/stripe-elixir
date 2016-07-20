defmodule Stripe.ChargeTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup do
    params = [
      source: [
        object: "card",
        number: "4111111111111111",
        exp_month: 10,
        exp_year: 2020,
        country: "US",
        name: "Ducky Test",
        cvc: 123
      ],
      description: "1000 Widgets"
    ]
    {:ok, [params: params]}
  end

  test "Create with card works", %{params: params} do
    use_cassette "Stripe.ChargeTest/create", match_requests_on: [:query, :request_body] do
      case Stripe.Charges.create(1000,params) do
        {:ok, res} -> assert res.id
        {:error, err} -> flunk err
      end
    end
  end

  test "Create with card, w/key works", %{params: params} do
    use_cassette "Stripe.ChargeTest/create_with_key", match_requests_on: [:query, :request_body] do
      case Stripe.Charges.create(1000,params, Stripe.config_or_env_key) do
        {:ok, res} -> assert res.id
        {:error, err} -> flunk err
      end
    end
  end
  test "List works" do
    use_cassette "Stripe.ChargeTest/list", match_requests_on: [:query, :request_body] do
      case Stripe.Charges.list() do
        {:ok, charges} -> assert length(charges) > 0
        {:error, err} -> flunk err
      end
    end
  end

  test "List w/key works" do
    use_cassette "Stripe.ChargeTest/list_with_key", match_requests_on: [:query, :request_body] do
      case Stripe.Charges.list Stripe.config_or_env_key, 1 do
        {:ok, charges} -> assert length(charges) > 0
        {:error, err} -> flunk err
      end
    end
  end

  test "Get works" do
    use_cassette "Stripe.ChargeTest/get", match_requests_on: [:query, :request_body] do
      {:ok,[first | _]} = Stripe.Charges.list()
      case Stripe.Charges.get(first.id) do
        {:ok, charge} -> assert charge.id == first.id
        {:error, err} -> flunk err
      end
    end
  end

  test "Get w/key works" do
    use_cassette "Stripe.ChargeTest/get_with_key", match_requests_on: [:query, :request_body] do
      {:ok,[first | _]} = Stripe.Charges.list Stripe.config_or_env_key, 1
      case Stripe.Charges.get(first.id, Stripe.config_or_env_key) do
        {:ok, charge} -> assert charge.id == first.id
        {:error, err} -> flunk err
      end
    end
  end

  test "Capture works", %{params: params} do
    use_cassette "Stripe.ChargeTest/capture", match_requests_on: [:query, :request_body] do
      params = Keyword.put_new params, :capture, false
      {:ok, charge} = Stripe.Charges.create(1000,params)
      case Stripe.Charges.capture(charge.id) do
        {:ok, captured} -> assert captured.id == charge.id
        {:error, err} -> flunk err
      end
    end
  end

  test "Capture w/key works", %{params: params} do
    use_cassette "Stripe.ChargeTest/capture_with_key", match_requests_on: [:query, :request_body] do
      params = Keyword.put_new params, :capture, false
      {:ok, charge} = Stripe.Charges.create(1000,params, Stripe.config_or_env_key)
      case Stripe.Charges.capture(charge.id, Stripe.config_or_env_key) do
        {:ok, captured} -> assert captured.id == charge.id
        {:error, err} -> flunk err
      end
    end
  end

  test "Change(Update) works", %{params: params} do
    use_cassette "Stripe.ChargeTest/change", match_requests_on: [:query, :request_body] do
      {:ok, charge} = Stripe.Charges.create(1000,params)
      params = [description: "Changed charge"]
      case Stripe.Charges.change(charge.id, params) do
        {:ok, changed} -> assert changed.description == "Changed charge"
        {:error, err} -> flunk err
      end
    end
  end

  test "Change(Update) w/key works", %{params: params} do
    use_cassette "Stripe.ChargeTest/change_with_key", match_requests_on: [:query, :request_body] do
      {:ok, charge} = Stripe.Charges.create(2000,params, Stripe.config_or_env_key)
      params = [description: "Changed charge"]
      case Stripe.Charges.change(charge.id, params, Stripe.config_or_env_key) do
        {:ok, changed} -> assert changed.description == "Changed charge"
        {:error, err} -> flunk err
      end
    end
  end

  test "Refund works", %{params: params} do
    use_cassette "Stripe.ChargeTest/partial_refund", match_requests_on: [:query, :request_body] do
      {:ok, charge} = Stripe.Charges.create(3000,params)
      case Stripe.Charges.refund_partial(charge.id,500) do
        {:ok, refunded} -> assert refunded.amount == 500
        {:error, err} -> flunk err
      end
    end
  end

  test "Refund w/key works", %{params: params} do
    use_cassette "Stripe.ChargeTest/partial_refund_with_key", match_requests_on: [:query, :request_body] do
      {:ok, charge} = Stripe.Charges.create(5000,params, Stripe.config_or_env_key)
      case Stripe.Charges.refund_partial(charge.id,500, Stripe.config_or_env_key) do
        {:ok, refunded} -> assert refunded.amount == 500
        {:error, err} -> flunk err
      end
    end
  end
end
