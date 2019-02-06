ExUnit.start()
# Stripe.start
Application.ensure_all_started(:erlexec)
Application.ensure_all_started(:exexec)
Application.ensure_all_started(:mox)
ExUnit.configure(exclude: [disabled: true], seed: 0)
Logger.configure(level: :info)

{:ok, pid} = Stripe.StripeMock.start_link(port: 12123, global: true)

Application.put_env(:stripity_stripe, :api_base_url, "http://localhost:12123/v1/")
Application.put_env(:stripity_stripe, :api_upload_url, "http://localhost:12123/v1/")
Application.put_env(:stripity_stripe, :api_key, "sk_test_123")
Application.put_env(:stripity_stripe, :log_level, :debug)

Mox.defmock(Stripe.Connect.OAuthMock, for: Stripe.Connect.OAuth)
Mox.defmock(Stripe.APIMock, for: Stripe.API)

defmodule Helper do
  @fixture_path "./test/fixtures/"

  def load_fixture(filename) do
    File.read!(@fixture_path <> filename) |> Stripe.API.json_library().decode!()
  end

  def wait_until_stripe_mock_launch() do
    case Stripe.Charge.list() do
      {:error, %Stripe.Error{code: :network_error}} ->
        # It might be connection refused.
        Process.sleep(250)
        wait_until_stripe_mock_launch()

      _ ->
        true
    end
  end
end

Helper.wait_until_stripe_mock_launch()
