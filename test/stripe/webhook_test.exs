defmodule Stripe.WebhookTest do
  use ExUnit.Case

  import Stripe.Webhook

  @valid_payload ~S({"object": "event"})

  @valid_scheme "v1"
  @invalid_scheme "v0"

  @secret "secret"

  defp generate_signature(timestamp, payload, secret \\ @secret) do
    :crypto.hmac(:sha256, secret, "#{timestamp}.#{payload}")
    |> Base.encode16(case: :lower)
  end

  defp create_signature_header(timestamp, scheme, signature) do
    "t=#{timestamp},#{scheme}=#{signature}"
  end

  test "payload with a valid signature should return event" do
    timestamp = System.system_time(:second)
    payload = @valid_payload
    signature = generate_signature(timestamp, payload)
    signature_header = create_signature_header(timestamp, @valid_scheme, signature)

    assert {:ok, %Stripe.Event{}} = construct_event(payload, signature_header, @secret)
  end

  test "payload with an invalid signature should fail" do
    timestamp = System.system_time(:second)
    payload = @valid_payload
    signature = generate_signature(timestamp, "random")
    signature_header = create_signature_header(timestamp, @valid_scheme, signature)

    assert {:error, _message} = construct_event(payload, signature_header, @secret)
  end

  test "payload with wrong secret should fail" do
    timestamp = System.system_time(:second)
    payload = @valid_payload
    signature = generate_signature(timestamp, payload, "wrong")
    signature_header = create_signature_header(timestamp, @valid_scheme, signature)

    assert {:error, _message} = construct_event(payload, signature_header, @secret)
  end

  test "payload with missing signature scheme should fail" do
    timestamp = System.system_time(:second)
    payload = @valid_payload
    signature = generate_signature(timestamp, payload)
    signature_header = create_signature_header(timestamp, @invalid_scheme, signature)

    assert {:error, _message} = construct_event(payload, signature_header, @secret)
  end
end
