defmodule Stripe.BankAccount do
  use Stripe.Entity

  @moduledoc "These bank accounts are payment methods on `Customer` objects.\n\nOn the other hand [External Accounts](https://stripe.com/docs/api#external_accounts) are transfer\ndestinations on `Account` objects for [Custom accounts](https://stripe.com/docs/connect/custom-accounts).\nThey can be bank accounts or debit cards as well, and are documented in the links above.\n\nRelated guide: [Bank debits and transfers](https://stripe.com/docs/payments/bank-debits-transfers)"
  (
    defstruct [
      :account,
      :account_holder_name,
      :account_holder_type,
      :account_type,
      :available_payout_methods,
      :bank_name,
      :country,
      :currency,
      :customer,
      :default_for_currency,
      :fingerprint,
      :future_requirements,
      :id,
      :last4,
      :metadata,
      :object,
      :requirements,
      :routing_number,
      :status
    ]

    @typedoc "The `bank_account` type.\n\n  * `account` The ID of the account that the bank account is associated with.\n  * `account_holder_name` The name of the person or business that owns the bank account.\n  * `account_holder_type` The type of entity that holds the account. This can be either `individual` or `company`.\n  * `account_type` The bank account type. This can only be `checking` or `savings` in most countries. In Japan, this can only be `futsu` or `toza`.\n  * `available_payout_methods` A set of available payout methods for this bank account. Only values from this set should be passed as the `method` when creating a payout.\n  * `bank_name` Name of the bank associated with the routing number (e.g., `WELLS FARGO`).\n  * `country` Two-letter ISO code representing the country the bank account is located in.\n  * `currency` Three-letter [ISO code for the currency](https://stripe.com/docs/payouts) paid out to the bank account.\n  * `customer` The ID of the customer that the bank account is associated with.\n  * `default_for_currency` Whether this bank account is the default external account for its currency.\n  * `fingerprint` Uniquely identifies this particular bank account. You can use this attribute to check whether two bank accounts are the same.\n  * `future_requirements` Information about the [upcoming new requirements for the bank account](https://stripe.com/docs/connect/custom-accounts/future-requirements), including what information needs to be collected, and by when.\n  * `id` Unique identifier for the object.\n  * `last4` The last four digits of the bank account number.\n  * `metadata` Set of [key-value pairs](https://stripe.com/docs/api/metadata) that you can attach to an object. This can be useful for storing additional information about the object in a structured format.\n  * `object` String representing the object's type. Objects of the same type share the same value.\n  * `requirements` Information about the requirements for the bank account, including what information needs to be collected.\n  * `routing_number` The routing transit number for the bank account.\n  * `status` For bank accounts, possible values are `new`, `validated`, `verified`, `verification_failed`, or `errored`. A bank account that hasn't had any activity or validation performed is `new`. If Stripe can determine that the bank account exists, its status will be `validated`. Note that there often isn’t enough information to know (e.g., for smaller credit unions), and the validation is not always run. If customer bank account verification has succeeded, the bank account status will be `verified`. If the verification failed for any reason, such as microdeposit failure, the status will be `verification_failed`. If a payout sent to this bank account fails, we'll set the status to `errored` and will not continue to send [scheduled payouts](https://stripe.com/docs/payouts#payout-schedule) until the bank details are updated.\n\nFor external accounts, possible values are `new`, `errored` and `verification_failed`. If a payouts fails, the status is set to `errored` and scheduled payouts are stopped until account details are updated. In India, if we can't [verify the owner of the bank account](https://support.stripe.com/questions/bank-account-ownership-verification), we'll set the status to `verification_failed`. Other validations aren't run against external accounts because they're only used for payouts. This means the other statuses don't apply.\n"
    @type t :: %__MODULE__{
            account: (binary | Stripe.Account.t()) | nil,
            account_holder_name: binary | nil,
            account_holder_type: binary | nil,
            account_type: binary | nil,
            available_payout_methods: term | nil,
            bank_name: binary | nil,
            country: binary,
            currency: binary,
            customer: (binary | Stripe.Customer.t() | Stripe.DeletedCustomer.t()) | nil,
            default_for_currency: boolean | nil,
            fingerprint: binary | nil,
            future_requirements: term | nil,
            id: binary,
            last4: binary,
            metadata: term | nil,
            object: binary,
            requirements: term | nil,
            routing_number: binary | nil,
            status: binary
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

    @doc "<p>Verify a specified bank account for a given customer.</p>\n\n#### Details\n\n * Method: `post`\n * Path: `/v1/customers/{customer}/sources/{id}/verify`\n"
    (
      @spec verify(
              customer :: binary(),
              id :: binary(),
              params :: %{optional(:amounts) => list(integer), optional(:expand) => list(binary)},
              opts :: Keyword.t()
            ) :: {:ok, Stripe.BankAccount.t()} | {:error, Stripe.ApiErrors.t()} | {:error, term()}
      def verify(customer, id, params \\ %{}, opts \\ []) do
        path =
          Stripe.OpenApi.Path.replace_path_params(
            "/v1/customers/{customer}/sources/{id}/verify",
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
