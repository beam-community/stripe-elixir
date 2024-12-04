defmodule Stripe.Card do
  use Stripe.Entity

  @moduledoc "You can store multiple cards on a customer in order to charge the customer\nlater. You can also store multiple debit cards on a recipient in order to\ntransfer to those cards later.\n\nRelated guide: [Card payments with Sources](https://stripe.com/docs/sources/cards)"
  (
    defstruct [
      :account,
      :address_city,
      :address_country,
      :address_line1,
      :address_line1_check,
      :address_line2,
      :address_state,
      :address_zip,
      :address_zip_check,
      :available_payout_methods,
      :brand,
      :country,
      :currency,
      :customer,
      :cvc_check,
      :default_for_currency,
      :description,
      :dynamic_last4,
      :exp_month,
      :exp_year,
      :fingerprint,
      :funding,
      :id,
      :iin,
      :issuer,
      :last4,
      :metadata,
      :name,
      :object,
      :status,
      :tokenization_method
    ]

    @typedoc "The `card` type.\n\n  * `account` The account this card belongs to. This attribute will not be in the card object if the card belongs to a customer or recipient instead.\n  * `address_city` City/District/Suburb/Town/Village.\n  * `address_country` Billing address country, if provided when creating card.\n  * `address_line1` Address line 1 (Street address/PO Box/Company name).\n  * `address_line1_check` If `address_line1` was provided, results of the check: `pass`, `fail`, `unavailable`, or `unchecked`.\n  * `address_line2` Address line 2 (Apartment/Suite/Unit/Building).\n  * `address_state` State/County/Province/Region.\n  * `address_zip` ZIP or postal code.\n  * `address_zip_check` If `address_zip` was provided, results of the check: `pass`, `fail`, `unavailable`, or `unchecked`.\n  * `available_payout_methods` A set of available payout methods for this card. Only values from this set should be passed as the `method` when creating a payout.\n  * `brand` Card brand. Can be `American Express`, `Diners Club`, `Discover`, `Eftpos Australia`, `JCB`, `MasterCard`, `UnionPay`, `Visa`, or `Unknown`.\n  * `country` Two-letter ISO code representing the country of the card. You could use this attribute to get a sense of the international breakdown of cards you've collected.\n  * `currency` Three-letter [ISO code for currency](https://stripe.com/docs/payouts). Only applicable on accounts (not customers or recipients). The card can be used as a transfer destination for funds in this currency.\n  * `customer` The customer that this card belongs to. This attribute will not be in the card object if the card belongs to an account or recipient instead.\n  * `cvc_check` If a CVC was provided, results of the check: `pass`, `fail`, `unavailable`, or `unchecked`. A result of unchecked indicates that CVC was provided but hasn't been checked yet. Checks are typically performed when attaching a card to a Customer object, or when creating a charge. For more details, see [Check if a card is valid without a charge](https://support.stripe.com/questions/check-if-a-card-is-valid-without-a-charge).\n  * `default_for_currency` Whether this card is the default external account for its currency.\n  * `description` A high-level description of the type of cards issued in this range. (For internal use only and not typically available in standard API requests.)\n  * `dynamic_last4` (For tokenized numbers only.) The last four digits of the device account number.\n  * `exp_month` Two-digit number representing the card's expiration month.\n  * `exp_year` Four-digit number representing the card's expiration year.\n  * `fingerprint` Uniquely identifies this particular card number. You can use this attribute to check whether two customers who’ve signed up with you are using the same card number, for example. For payment methods that tokenize card information (Apple Pay, Google Pay), the tokenized number might be provided instead of the underlying card number.\n\n*As of May 1, 2021, card fingerprint in India for Connect changed to allow two fingerprints for the same card---one for India and one for the rest of the world.*\n  * `funding` Card funding type. Can be `credit`, `debit`, `prepaid`, or `unknown`.\n  * `id` Unique identifier for the object.\n  * `iin` Issuer identification number of the card. (For internal use only and not typically available in standard API requests.)\n  * `issuer` The name of the card's issuing bank. (For internal use only and not typically available in standard API requests.)\n  * `last4` The last four digits of the card.\n  * `metadata` Set of [key-value pairs](https://stripe.com/docs/api/metadata) that you can attach to an object. This can be useful for storing additional information about the object in a structured format.\n  * `name` Cardholder name.\n  * `object` String representing the object's type. Objects of the same type share the same value.\n  * `status` For external accounts that are cards, possible values are `new` and `errored`. If a payout fails, the status is set to `errored` and [scheduled payouts](https://stripe.com/docs/payouts#payout-schedule) are stopped until account details are updated.\n  * `tokenization_method` If the card number is tokenized, this is the method that was used. Can be `android_pay` (includes Google Pay), `apple_pay`, `masterpass`, `visa_checkout`, or null.\n"
    @type t :: %__MODULE__{
            account: (binary | Stripe.Account.t()) | nil,
            address_city: binary | nil,
            address_country: binary | nil,
            address_line1: binary | nil,
            address_line1_check: binary | nil,
            address_line2: binary | nil,
            address_state: binary | nil,
            address_zip: binary | nil,
            address_zip_check: binary | nil,
            available_payout_methods: term | nil,
            brand: binary,
            country: binary | nil,
            currency: binary | nil,
            customer: (binary | Stripe.Customer.t() | Stripe.DeletedCustomer.t()) | nil,
            cvc_check: binary | nil,
            default_for_currency: boolean | nil,
            description: binary,
            dynamic_last4: binary | nil,
            exp_month: integer,
            exp_year: integer,
            fingerprint: binary | nil,
            funding: binary,
            id: binary,
            iin: binary,
            issuer: binary,
            last4: binary,
            metadata: term | nil,
            name: binary | nil,
            object: binary,
            status: binary | nil,
            tokenization_method: binary | nil
          }
  )

  (
    @typedoc "Owner's address."
    @type address :: %{
            optional(:city) => binary,
            optional(:country) => binary,
            optional(:line1) => binary,
            optional(:line2) => binary,
            optional(:postal_code) => binary,
            optional(:state) => binary
          }
  )

  (
    @typedoc "One or more documents that support the [Bank account ownership verification](https://support.stripe.com/questions/bank-account-ownership-verification) requirement. Must be a document associated with the bank account that displays the last 4 digits of the account number, either a statement or a voided check."
    @type bank_account_ownership_verification :: %{optional(:files) => list(binary)}
  )

  (
    @typedoc "Documents that may be submitted to satisfy various informational requests."
    @type documents :: %{
            optional(:bank_account_ownership_verification) => bank_account_ownership_verification
          }
  )

  (
    @typedoc nil
    @type owner :: %{
            optional(:address) => address,
            optional(:email) => binary,
            optional(:name) => binary,
            optional(:phone) => binary
          }
  )

  (
    nil

    @doc "<p>Update a specified source for a given customer.</p>\n\n#### Details\n\n * Method: `post`\n * Path: `/v1/customers/{customer}/sources/{id}`\n"
    (
      @spec update_source(
              customer :: binary(),
              id :: binary(),
              params :: %{
                optional(:account_holder_name) => binary,
                optional(:account_holder_type) => :company | :individual,
                optional(:address_city) => binary,
                optional(:address_country) => binary,
                optional(:address_line1) => binary,
                optional(:address_line2) => binary,
                optional(:address_state) => binary,
                optional(:address_zip) => binary,
                optional(:exp_month) => binary,
                optional(:exp_year) => binary,
                optional(:expand) => list(binary),
                optional(:metadata) => %{optional(binary) => binary} | binary,
                optional(:name) => binary,
                optional(:owner) => owner
              },
              opts :: Keyword.t()
            ) ::
              {:ok, Stripe.Card.t() | Stripe.BankAccount.t() | Stripe.Source.t()}
              | {:error, Stripe.ApiErrors.t()}
              | {:error, term()}
      def update_source(customer, id, params \\ %{}, opts \\ []) do
        path =
          Stripe.OpenApi.Path.replace_path_params(
            "/v1/customers/{customer}/sources/{id}",
            [
              %OpenApiGen.Blueprint.Parameter{
                in: "path",
                name: "customer",
                required: true,
                schema: %OpenApiGen.Blueprint.Parameter.Schema{
                  name: "customer",
                  title: nil,
                  type: "string",
                  items: [],
                  properties: [],
                  any_of: []
                }
              },
              %OpenApiGen.Blueprint.Parameter{
                in: "path",
                name: "id",
                required: true,
                schema: %OpenApiGen.Blueprint.Parameter.Schema{
                  name: "id",
                  title: nil,
                  type: "string",
                  items: [],
                  properties: [],
                  any_of: []
                }
              }
            ],
            [customer, id]
          )

        Stripe.Request.new_request(opts)
        |> Stripe.Request.put_endpoint(path)
        |> Stripe.Request.put_params(params)
        |> Stripe.Request.put_method(:post)
        |> Stripe.Request.make_request()
      end
    )
  )

  (
    nil

    @doc "<p>Delete a specified source for a given customer.</p>\n\n#### Details\n\n * Method: `delete`\n * Path: `/v1/customers/{customer}/sources/{id}`\n"
    (
      @spec delete_source(
              customer :: binary(),
              id :: binary(),
              params :: %{optional(:expand) => list(binary)},
              opts :: Keyword.t()
            ) ::
              {:ok, Stripe.PaymentSource.t() | Stripe.DeletedPaymentSource.t()}
              | {:error, Stripe.ApiErrors.t()}
              | {:error, term()}
      def delete_source(customer, id, params \\ %{}, opts \\ []) do
        path =
          Stripe.OpenApi.Path.replace_path_params(
            "/v1/customers/{customer}/sources/{id}",
            [
              %OpenApiGen.Blueprint.Parameter{
                in: "path",
                name: "customer",
                required: true,
                schema: %OpenApiGen.Blueprint.Parameter.Schema{
                  name: "customer",
                  title: nil,
                  type: "string",
                  items: [],
                  properties: [],
                  any_of: []
                }
              },
              %OpenApiGen.Blueprint.Parameter{
                in: "path",
                name: "id",
                required: true,
                schema: %OpenApiGen.Blueprint.Parameter.Schema{
                  name: "id",
                  title: nil,
                  type: "string",
                  items: [],
                  properties: [],
                  any_of: []
                }
              }
            ],
            [customer, id]
          )

        Stripe.Request.new_request(opts)
        |> Stripe.Request.put_endpoint(path)
        |> Stripe.Request.put_params(params)
        |> Stripe.Request.put_method(:delete)
        |> Stripe.Request.make_request()
      end
    )
  )

  (
    nil

    @doc "<p>Updates the metadata, account holder name, account holder type of a bank account belonging to a <a href=\"/docs/connect/custom-accounts\">Custom account</a>, and optionally sets it as the default for its currency. Other bank account details are not editable by design.</p>\n\n<p>You can re-enable a disabled bank account by performing an update call without providing any arguments or changes.</p>\n\n#### Details\n\n * Method: `post`\n * Path: `/v1/accounts/{account}/external_accounts/{id}`\n"
    (
      @spec update_external_account(
              account :: binary(),
              id :: binary(),
              params :: %{
                optional(:account_holder_name) => binary,
                optional(:account_holder_type) => :company | :individual,
                optional(:account_type) => :checking | :futsu | :savings | :toza,
                optional(:address_city) => binary,
                optional(:address_country) => binary,
                optional(:address_line1) => binary,
                optional(:address_line2) => binary,
                optional(:address_state) => binary,
                optional(:address_zip) => binary,
                optional(:default_for_currency) => boolean,
                optional(:documents) => documents,
                optional(:exp_month) => binary,
                optional(:exp_year) => binary,
                optional(:expand) => list(binary),
                optional(:metadata) => %{optional(binary) => binary} | binary,
                optional(:name) => binary
              },
              opts :: Keyword.t()
            ) ::
              {:ok, Stripe.ExternalAccount.t()}
              | {:error, Stripe.ApiErrors.t()}
              | {:error, term()}
      def update_external_account(account, id, params \\ %{}, opts \\ []) do
        path =
          Stripe.OpenApi.Path.replace_path_params(
            "/v1/accounts/{account}/external_accounts/{id}",
            [
              %OpenApiGen.Blueprint.Parameter{
                in: "path",
                name: "account",
                required: true,
                schema: %OpenApiGen.Blueprint.Parameter.Schema{
                  name: "account",
                  title: nil,
                  type: "string",
                  items: [],
                  properties: [],
                  any_of: []
                }
              },
              %OpenApiGen.Blueprint.Parameter{
                in: "path",
                name: "id",
                required: true,
                schema: %OpenApiGen.Blueprint.Parameter.Schema{
                  name: "id",
                  title: nil,
                  type: "string",
                  items: [],
                  properties: [],
                  any_of: []
                }
              }
            ],
            [account, id]
          )

        Stripe.Request.new_request(opts)
        |> Stripe.Request.put_endpoint(path)
        |> Stripe.Request.put_params(params)
        |> Stripe.Request.put_method(:post)
        |> Stripe.Request.make_request()
      end
    )
  )

  (
    nil

    @doc "<p>Delete a specified external account for a given account.</p>\n\n#### Details\n\n * Method: `delete`\n * Path: `/v1/accounts/{account}/external_accounts/{id}`\n"
    (
      @spec delete_external_account(account :: binary(), id :: binary(), opts :: Keyword.t()) ::
              {:ok, Stripe.DeletedExternalAccount.t()}
              | {:error, Stripe.ApiErrors.t()}
              | {:error, term()}
      def delete_external_account(account, id, opts \\ []) do
        path =
          Stripe.OpenApi.Path.replace_path_params(
            "/v1/accounts/{account}/external_accounts/{id}",
            [
              %OpenApiGen.Blueprint.Parameter{
                in: "path",
                name: "account",
                required: true,
                schema: %OpenApiGen.Blueprint.Parameter.Schema{
                  name: "account",
                  title: nil,
                  type: "string",
                  items: [],
                  properties: [],
                  any_of: []
                }
              },
              %OpenApiGen.Blueprint.Parameter{
                in: "path",
                name: "id",
                required: true,
                schema: %OpenApiGen.Blueprint.Parameter.Schema{
                  name: "id",
                  title: nil,
                  type: "string",
                  items: [],
                  properties: [],
                  any_of: []
                }
              }
            ],
            [account, id]
          )

        Stripe.Request.new_request(opts)
        |> Stripe.Request.put_endpoint(path)
        |> Stripe.Request.put_method(:delete)
        |> Stripe.Request.make_request()
      end
    )
  )
end
