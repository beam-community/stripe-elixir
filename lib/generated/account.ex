defmodule Stripe.Account do
  use Stripe.Entity

  @moduledoc "This is an object representing a Stripe account. You can retrieve it to see\nproperties on the account like its current requirements or if the account is\nenabled to make live charges or receive payouts.\n\nFor Custom accounts, the properties below are always returned. For other accounts, some properties are returned until that\naccount has started to go through Connect Onboarding. Once you create an [Account Link](https://stripe.com/docs/api/account_links)\nfor a Standard or Express account, some parameters are no longer returned. These are marked as **Custom Only** or **Custom and Express**\nbelow. Learn about the differences [between accounts](https://stripe.com/docs/connect/accounts)."
  (
    defstruct [
      :business_profile,
      :business_type,
      :capabilities,
      :charges_enabled,
      :company,
      :controller,
      :country,
      :created,
      :default_currency,
      :details_submitted,
      :email,
      :external_accounts,
      :future_requirements,
      :id,
      :individual,
      :metadata,
      :object,
      :payouts_enabled,
      :requirements,
      :settings,
      :tos_acceptance,
      :type
    ]

    @typedoc "The `account` type.\n\n  * `business_profile` Business information about the account.\n  * `business_type` The business type.\n  * `capabilities` \n  * `charges_enabled` Whether the account can create live charges.\n  * `company` \n  * `controller` \n  * `country` The account's country.\n  * `created` Time at which the account was connected. Measured in seconds since the Unix epoch.\n  * `default_currency` Three-letter ISO currency code representing the default currency for the account. This must be a currency that [Stripe supports in the account's country](https://stripe.com/docs/payouts).\n  * `details_submitted` Whether account details have been submitted. Standard accounts cannot receive payouts before this is true.\n  * `email` An email address associated with the account. It's not used for authentication and Stripe doesn't market to this field without explicit approval from the platform.\n  * `external_accounts` External accounts (bank accounts and debit cards) currently attached to this account\n  * `future_requirements` \n  * `id` Unique identifier for the object.\n  * `individual` \n  * `metadata` Set of [key-value pairs](https://stripe.com/docs/api/metadata) that you can attach to an object. This can be useful for storing additional information about the object in a structured format.\n  * `object` String representing the object's type. Objects of the same type share the same value.\n  * `payouts_enabled` Whether Stripe can send payouts to this account.\n  * `requirements` \n  * `settings` Options for customizing how the account functions within Stripe.\n  * `tos_acceptance` \n  * `type` The Stripe account type. Can be `standard`, `express`, or `custom`.\n"
    @type t :: %__MODULE__{
            business_profile: term | nil,
            business_type: binary | nil,
            capabilities: term,
            charges_enabled: boolean,
            company: term,
            controller: term,
            country: binary,
            created: integer,
            default_currency: binary,
            details_submitted: boolean,
            email: binary | nil,
            external_accounts: term,
            future_requirements: term,
            id: binary,
            individual: Stripe.Person.t(),
            metadata: term,
            object: binary,
            payouts_enabled: boolean,
            requirements: term,
            settings: term | nil,
            tos_acceptance: term,
            type: binary
          }
  )

  (
    @typedoc "The acss_debit_payments capability."
    @type acss_debit_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "A document showing address, either a passport, local ID card, or utility bill from a well-known utility company."
    @type additional_document :: %{optional(:back) => binary, optional(:front) => binary}
  )

  (
    @typedoc "The company's primary address."
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
    @typedoc "The Kana variation of the company's primary address (Japan only)."
    @type address_kana :: %{
            optional(:city) => binary,
            optional(:country) => binary,
            optional(:line1) => binary,
            optional(:line2) => binary,
            optional(:postal_code) => binary,
            optional(:state) => binary,
            optional(:town) => binary
          }
  )

  (
    @typedoc "The Kanji variation of the the individual's primary address (Japan only)."
    @type address_kanji :: %{
            optional(:city) => binary,
            optional(:country) => binary,
            optional(:line1) => binary,
            optional(:line2) => binary,
            optional(:postal_code) => binary,
            optional(:state) => binary,
            optional(:town) => binary
          }
  )

  (
    @typedoc "The affirm_payments capability."
    @type affirm_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The afterpay_clearpay_payments capability."
    @type afterpay_clearpay_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The au_becs_debit_payments capability."
    @type au_becs_debit_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "Settings specific to Bacs Direct Debit payments."
    @type bacs_debit_payments :: %{optional(:display_name) => binary}
  )

  (
    @typedoc "The bancontact_payments capability."
    @type bancontact_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "One or more documents that support the [Bank account ownership verification](https://support.stripe.com/questions/bank-account-ownership-verification) requirement. Must be a document associated with the account’s primary active bank account that displays the last 4 digits of the account number, either a statement or a voided check."
    @type bank_account_ownership_verification :: %{optional(:files) => list(binary)}
  )

  (
    @typedoc "The bank_transfer_payments capability."
    @type bank_transfer_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The blik_payments capability."
    @type blik_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The boleto_payments capability."
    @type boleto_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "Settings used to apply the account's branding to email receipts, invoices, Checkout, and other products."
    @type branding :: %{
            optional(:icon) => binary,
            optional(:logo) => binary,
            optional(:primary_color) => binary,
            optional(:secondary_color) => binary
          }
  )

  (
    @typedoc "Business information about the account."
    @type business_profile :: %{
            optional(:mcc) => binary,
            optional(:monthly_estimated_revenue) => monthly_estimated_revenue,
            optional(:name) => binary,
            optional(:product_description) => binary,
            optional(:support_address) => support_address,
            optional(:support_email) => binary,
            optional(:support_phone) => binary,
            optional(:support_url) => binary | binary,
            optional(:url) => binary
          }
  )

  (
    @typedoc "Each key of the dictionary represents a capability, and each capability maps to its settings (e.g. whether it has been requested or not). Each capability will be inactive until you have provided its specific requirements and Stripe has verified them. An account may have some of its requested capabilities be active and some be inactive."
    @type capabilities :: %{
            optional(:link_payments) => link_payments,
            optional(:card_issuing) => card_issuing,
            optional(:treasury) => treasury,
            optional(:oxxo_payments) => oxxo_payments,
            optional(:affirm_payments) => affirm_payments,
            optional(:promptpay_payments) => promptpay_payments,
            optional(:bank_transfer_payments) => bank_transfer_payments,
            optional(:sofort_payments) => sofort_payments,
            optional(:acss_debit_payments) => acss_debit_payments,
            optional(:cashapp_payments) => cashapp_payments,
            optional(:cartes_bancaires_payments) => cartes_bancaires_payments,
            optional(:india_international_payments) => india_international_payments,
            optional(:bacs_debit_payments) => bacs_debit_payments,
            optional(:tax_reporting_us_1099_misc) => tax_reporting_us_1099_misc,
            optional(:paynow_payments) => paynow_payments,
            optional(:klarna_payments) => klarna_payments,
            optional(:us_bank_account_ach_payments) => us_bank_account_ach_payments,
            optional(:card_payments) => card_payments,
            optional(:p24_payments) => p24_payments,
            optional(:boleto_payments) => boleto_payments,
            optional(:fpx_payments) => fpx_payments,
            optional(:au_becs_debit_payments) => au_becs_debit_payments,
            optional(:konbini_payments) => konbini_payments,
            optional(:ideal_payments) => ideal_payments,
            optional(:afterpay_clearpay_payments) => afterpay_clearpay_payments,
            optional(:blik_payments) => blik_payments,
            optional(:zip_payments) => zip_payments,
            optional(:bancontact_payments) => bancontact_payments,
            optional(:giropay_payments) => giropay_payments,
            optional(:legacy_payments) => legacy_payments,
            optional(:sepa_debit_payments) => sepa_debit_payments,
            optional(:revolut_pay_payments) => revolut_pay_payments,
            optional(:transfers) => transfers,
            optional(:eps_payments) => eps_payments,
            optional(:grabpay_payments) => grabpay_payments,
            optional(:tax_reporting_us_1099_k) => tax_reporting_us_1099_k,
            optional(:jcb_payments) => jcb_payments
          }
  )

  (
    @typedoc "Settings specific to the account's use of the Card Issuing product."
    @type card_issuing :: %{optional(:tos_acceptance) => tos_acceptance}
  )

  (
    @typedoc "The card_payments capability."
    @type card_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The cartes_bancaires_payments capability."
    @type cartes_bancaires_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The cashapp_payments capability."
    @type cashapp_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "Information about the company or business. This field is available for any `business_type`."
    @type company :: %{
            optional(:address) => address,
            optional(:address_kana) => address_kana,
            optional(:address_kanji) => address_kanji,
            optional(:directors_provided) => boolean,
            optional(:executives_provided) => boolean,
            optional(:export_license_id) => binary,
            optional(:export_purpose_code) => binary,
            optional(:name) => binary,
            optional(:name_kana) => binary,
            optional(:name_kanji) => binary,
            optional(:owners_provided) => boolean,
            optional(:ownership_declaration) => ownership_declaration,
            optional(:phone) => binary,
            optional(:registration_number) => binary,
            optional(:structure) =>
              :free_zone_establishment
              | :free_zone_llc
              | :government_instrumentality
              | :governmental_unit
              | :incorporated_non_profit
              | :incorporated_partnership
              | :limited_liability_partnership
              | :llc
              | :multi_member_llc
              | :private_company
              | :private_corporation
              | :private_partnership
              | :public_company
              | :public_corporation
              | :public_partnership
              | :single_member_llc
              | :sole_establishment
              | :sole_proprietorship
              | :tax_exempt_government_instrumentality
              | :unincorporated_association
              | :unincorporated_non_profit
              | :unincorporated_partnership,
            optional(:tax_id) => binary,
            optional(:tax_id_registrar) => binary,
            optional(:vat_id) => binary,
            optional(:verification) => verification
          }
  )

  (
    @typedoc "One or more documents that demonstrate proof of a company's license to operate."
    @type company_license :: %{optional(:files) => list(binary)}
  )

  (
    @typedoc "One or more documents showing the company's Memorandum of Association."
    @type company_memorandum_of_association :: %{optional(:files) => list(binary)}
  )

  (
    @typedoc "(Certain countries only) One or more documents showing the ministerial decree legalizing the company's establishment."
    @type company_ministerial_decree :: %{optional(:files) => list(binary)}
  )

  (
    @typedoc "One or more documents that demonstrate proof of a company's registration with the appropriate local authorities."
    @type company_registration_verification :: %{optional(:files) => list(binary)}
  )

  (
    @typedoc "One or more documents that demonstrate proof of a company's tax ID."
    @type company_tax_id_verification :: %{optional(:files) => list(binary)}
  )

  (
    @typedoc nil
    @type created :: %{
            optional(:gt) => integer,
            optional(:gte) => integer,
            optional(:lt) => integer,
            optional(:lte) => integer
          }
  )

  (
    @typedoc "Automatically declines certain charge types regardless of whether the card issuer accepted or declined the charge."
    @type decline_on :: %{optional(:avs_failure) => boolean, optional(:cvc_failure) => boolean}
  )

  (
    @typedoc nil
    @type dob :: %{
            optional(:day) => integer,
            optional(:month) => integer,
            optional(:year) => integer
          }
  )

  (
    @typedoc "A document verifying the business."
    @type document :: %{optional(:back) => binary, optional(:front) => binary}
  )

  (
    @typedoc "Documents that may be submitted to satisfy various informational requests."
    @type documents :: %{
            optional(:bank_account_ownership_verification) => bank_account_ownership_verification,
            optional(:company_license) => company_license,
            optional(:company_memorandum_of_association) => company_memorandum_of_association,
            optional(:company_ministerial_decree) => company_ministerial_decree,
            optional(:company_registration_verification) => company_registration_verification,
            optional(:company_tax_id_verification) => company_tax_id_verification,
            optional(:proof_of_registration) => proof_of_registration
          }
  )

  (
    @typedoc "The eps_payments capability."
    @type eps_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The fpx_payments capability."
    @type fpx_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The giropay_payments capability."
    @type giropay_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The grabpay_payments capability."
    @type grabpay_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The ideal_payments capability."
    @type ideal_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The india_international_payments capability."
    @type india_international_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "Information about the person represented by the account. This field is null unless `business_type` is set to `individual`."
    @type individual :: %{
            optional(:address) => address,
            optional(:address_kana) => address_kana,
            optional(:address_kanji) => address_kanji,
            optional(:dob) => dob | binary,
            optional(:email) => binary,
            optional(:first_name) => binary,
            optional(:first_name_kana) => binary,
            optional(:first_name_kanji) => binary,
            optional(:full_name_aliases) => list(binary) | binary,
            optional(:gender) => binary,
            optional(:id_number) => binary,
            optional(:id_number_secondary) => binary,
            optional(:last_name) => binary,
            optional(:last_name_kana) => binary,
            optional(:last_name_kanji) => binary,
            optional(:maiden_name) => binary,
            optional(:metadata) => %{optional(binary) => binary} | binary,
            optional(:phone) => binary,
            optional(:political_exposure) => :existing | :none,
            optional(:registered_address) => registered_address,
            optional(:ssn_last_4) => binary,
            optional(:verification) => verification
          }
  )

  (
    @typedoc "The jcb_payments capability."
    @type jcb_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The klarna_payments capability."
    @type klarna_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The konbini_payments capability."
    @type konbini_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The legacy_payments capability."
    @type legacy_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The link_payments capability."
    @type link_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "An estimate of the monthly revenue of the business. Only accepted for accounts in Brazil and India."
    @type monthly_estimated_revenue :: %{
            optional(:amount) => integer,
            optional(:currency) => binary
          }
  )

  (
    @typedoc "This hash is used to attest that the beneficial owner information provided to Stripe is both current and correct."
    @type ownership_declaration :: %{
            optional(:date) => integer,
            optional(:ip) => binary,
            optional(:user_agent) => binary
          }
  )

  (
    @typedoc "The oxxo_payments capability."
    @type oxxo_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The p24_payments capability."
    @type p24_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "Settings that apply across payment methods for charging on the account."
    @type payments :: %{
            optional(:statement_descriptor) => binary,
            optional(:statement_descriptor_kana) => binary,
            optional(:statement_descriptor_kanji) => binary
          }
  )

  (
    @typedoc "The paynow_payments capability."
    @type paynow_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "Settings specific to the account's payouts."
    @type payouts :: %{
            optional(:debit_negative_balances) => boolean,
            optional(:schedule) => schedule,
            optional(:statement_descriptor) => binary
          }
  )

  (
    @typedoc "The promptpay_payments capability."
    @type promptpay_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "One or more documents showing the company’s proof of registration with the national business registry."
    @type proof_of_registration :: %{optional(:files) => list(binary)}
  )

  (
    @typedoc "The individual's registered address."
    @type registered_address :: %{
            optional(:city) => binary,
            optional(:country) => binary,
            optional(:line1) => binary,
            optional(:line2) => binary,
            optional(:postal_code) => binary,
            optional(:state) => binary
          }
  )

  (
    @typedoc nil
    @type relationship :: %{
            optional(:director) => boolean,
            optional(:executive) => boolean,
            optional(:legal_guardian) => boolean,
            optional(:owner) => boolean,
            optional(:representative) => boolean
          }
  )

  (
    @typedoc "The revolut_pay_payments capability."
    @type revolut_pay_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "Details on when funds from charges are available, and when they are paid out to an external account. For details, see our [Setting Bank and Debit Card Payouts](https://stripe.com/docs/connect/bank-transfers#payout-information) documentation."
    @type schedule :: %{
            optional(:delay_days) => :minimum | integer,
            optional(:interval) => :daily | :manual | :monthly | :weekly,
            optional(:monthly_anchor) => integer,
            optional(:weekly_anchor) =>
              :friday | :monday | :saturday | :sunday | :thursday | :tuesday | :wednesday
          }
  )

  (
    @typedoc "The sepa_debit_payments capability."
    @type sepa_debit_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "Options for customizing how the account functions within Stripe."
    @type settings :: %{
            optional(:bacs_debit_payments) => bacs_debit_payments,
            optional(:branding) => branding,
            optional(:card_issuing) => card_issuing,
            optional(:card_payments) => card_payments,
            optional(:payments) => payments,
            optional(:payouts) => payouts,
            optional(:treasury) => treasury
          }
  )

  (
    @typedoc "The sofort_payments capability."
    @type sofort_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "A publicly available mailing address for sending support issues to."
    @type support_address :: %{
            optional(:city) => binary,
            optional(:country) => binary,
            optional(:line1) => binary,
            optional(:line2) => binary,
            optional(:postal_code) => binary,
            optional(:state) => binary
          }
  )

  (
    @typedoc "The tax_reporting_us_1099_k capability."
    @type tax_reporting_us_1099_k :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The tax_reporting_us_1099_misc capability."
    @type tax_reporting_us_1099_misc :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "Details on the account's acceptance of the [Stripe Issuing Terms and Disclosures](https://stripe.com/docs/issuing/connect/tos_acceptance)."
    @type tos_acceptance :: %{
            optional(:date) => integer,
            optional(:ip) => binary,
            optional(:user_agent) => binary | binary
          }
  )

  (
    @typedoc "The transfers capability."
    @type transfers :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The treasury capability."
    @type treasury :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The us_bank_account_ach_payments capability."
    @type us_bank_account_ach_payments :: %{optional(:requested) => boolean}
  )

  (
    @typedoc "The individual's verification document information."
    @type verification :: %{
            optional(:additional_document) => additional_document,
            optional(:document) => document
          }
  )

  (
    @typedoc "The zip_payments capability."
    @type zip_payments :: %{optional(:requested) => boolean}
  )

  (
    nil

    @doc "<p>Retrieves the details of an account.</p>\n\n#### Details\n\n * Method: `get`\n * Path: `/v1/account`\n"
    (
      @spec show(params :: %{optional(:expand) => list(binary)}, opts :: Keyword.t()) ::
              {:ok, Stripe.Account.t()} | {:error, Stripe.ApiErrors.t()} | {:error, term()}
      def show(params \\ %{}, opts \\ []) do
        path = Stripe.OpenApi.Path.replace_path_params("/v1/account", [], [])

        Stripe.Request.new_request(opts)
        |> Stripe.Request.put_endpoint(path)
        |> Stripe.Request.put_params(params)
        |> Stripe.Request.put_method(:get)
        |> Stripe.Request.make_request()
      end
    )
  )

  (
    nil

    @doc "<p>Retrieves the details of an account.</p>\n\n#### Details\n\n * Method: `get`\n * Path: `/v1/accounts/{account}`\n"
    (
      @spec retrieve(
              account :: binary(),
              params :: %{optional(:expand) => list(binary)},
              opts :: Keyword.t()
            ) :: {:ok, Stripe.Account.t()} | {:error, Stripe.ApiErrors.t()} | {:error, term()}
      def retrieve(account, params \\ %{}, opts \\ []) do
        path =
          Stripe.OpenApi.Path.replace_path_params(
            "/v1/accounts/{account}",
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
              }
            ],
            [account]
          )

        Stripe.Request.new_request(opts)
        |> Stripe.Request.put_endpoint(path)
        |> Stripe.Request.put_params(params)
        |> Stripe.Request.put_method(:get)
        |> Stripe.Request.make_request()
      end
    )
  )

  (
    nil

    @doc "<p>Updates a <a href=\"/docs/connect/accounts\">connected account</a> by setting the values of the parameters passed. Any parameters not provided are\nleft unchanged.</p>\n\n<p>For Custom accounts, you can update any information on the account. For other accounts, you can update all information until that\naccount has started to go through Connect Onboarding. Once you create an <a href=\"/docs/api/account_links\">Account Link</a>\nfor a Standard or Express account, some parameters can no longer be changed. These are marked as <strong>Custom Only</strong> or <strong>Custom and Express</strong>\nbelow.</p>\n\n<p>To update your own account, use the <a href=\"https://dashboard.stripe.com/settings/account\">Dashboard</a>. Refer to our\n<a href=\"/docs/connect/updating-accounts\">Connect</a> documentation to learn more about updating accounts.</p>\n\n#### Details\n\n * Method: `post`\n * Path: `/v1/accounts/{account}`\n"
    (
      @spec update(
              account :: binary(),
              params :: %{
                optional(:account_token) => binary,
                optional(:business_profile) => business_profile,
                optional(:business_type) =>
                  :company | :government_entity | :individual | :non_profit,
                optional(:capabilities) => capabilities,
                optional(:company) => company,
                optional(:default_currency) => binary,
                optional(:documents) => documents,
                optional(:email) => binary,
                optional(:expand) => list(binary),
                optional(:external_account) => binary,
                optional(:individual) => individual,
                optional(:metadata) => %{optional(binary) => binary} | binary,
                optional(:settings) => settings,
                optional(:tos_acceptance) => tos_acceptance
              },
              opts :: Keyword.t()
            ) :: {:ok, Stripe.Account.t()} | {:error, Stripe.ApiErrors.t()} | {:error, term()}
      def update(account, params \\ %{}, opts \\ []) do
        path =
          Stripe.OpenApi.Path.replace_path_params(
            "/v1/accounts/{account}",
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
              }
            ],
            [account]
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

    @doc "<p>Returns a list of accounts connected to your platform via <a href=\"/docs/connect\">Connect</a>. If you’re not a platform, the list is empty.</p>\n\n#### Details\n\n * Method: `get`\n * Path: `/v1/accounts`\n"
    (
      @spec list(
              params :: %{
                optional(:created) => created | integer,
                optional(:ending_before) => binary,
                optional(:expand) => list(binary),
                optional(:limit) => integer,
                optional(:starting_after) => binary
              },
              opts :: Keyword.t()
            ) ::
              {:ok, Stripe.List.t(Stripe.Account.t())}
              | {:error, Stripe.ApiErrors.t()}
              | {:error, term()}
      def list(params \\ %{}, opts \\ []) do
        path = Stripe.OpenApi.Path.replace_path_params("/v1/accounts", [], [])

        Stripe.Request.new_request(opts)
        |> Stripe.Request.put_endpoint(path)
        |> Stripe.Request.put_params(params)
        |> Stripe.Request.put_method(:get)
        |> Stripe.Request.make_request()
      end
    )
  )

  (
    nil

    @doc "<p>With <a href=\"/docs/connect\">Connect</a>, you can create Stripe accounts for your users.\nTo do this, you’ll first need to <a href=\"https://dashboard.stripe.com/account/applications/settings\">register your platform</a>.</p>\n\n<p>If you’ve already collected information for your connected accounts, you <a href=\"/docs/connect/best-practices#onboarding\">can prefill that information</a> when\ncreating the account. Connect Onboarding won’t ask for the prefilled information during account onboarding.\nYou can prefill any information on the account.</p>\n\n#### Details\n\n * Method: `post`\n * Path: `/v1/accounts`\n"
    (
      @spec create(
              params :: %{
                optional(:account_token) => binary,
                optional(:business_profile) => business_profile,
                optional(:business_type) =>
                  :company | :government_entity | :individual | :non_profit,
                optional(:capabilities) => capabilities,
                optional(:company) => company,
                optional(:country) => binary,
                optional(:default_currency) => binary,
                optional(:documents) => documents,
                optional(:email) => binary,
                optional(:expand) => list(binary),
                optional(:external_account) => binary,
                optional(:individual) => individual,
                optional(:metadata) => %{optional(binary) => binary} | binary,
                optional(:settings) => settings,
                optional(:tos_acceptance) => tos_acceptance,
                optional(:type) => :custom | :express | :standard
              },
              opts :: Keyword.t()
            ) :: {:ok, Stripe.Account.t()} | {:error, Stripe.ApiErrors.t()} | {:error, term()}
      def create(params \\ %{}, opts \\ []) do
        path = Stripe.OpenApi.Path.replace_path_params("/v1/accounts", [], [])

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

    @doc "<p>With <a href=\"/docs/connect\">Connect</a>, you can delete accounts you manage.</p>\n\n<p>Accounts created using test-mode keys can be deleted at any time. Standard accounts created using live-mode keys cannot be deleted. Custom or Express accounts created using live-mode keys can only be deleted once all balances are zero.</p>\n\n<p>If you want to delete your own account, use the <a href=\"https://dashboard.stripe.com/settings/account\">account information tab in your account settings</a> instead.</p>\n\n#### Details\n\n * Method: `delete`\n * Path: `/v1/accounts/{account}`\n"
    (
      @spec delete(account :: binary(), opts :: Keyword.t()) ::
              {:ok, Stripe.DeletedAccount.t()} | {:error, Stripe.ApiErrors.t()} | {:error, term()}
      def delete(account, opts \\ []) do
        path =
          Stripe.OpenApi.Path.replace_path_params(
            "/v1/accounts/{account}",
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
              }
            ],
            [account]
          )

        Stripe.Request.new_request(opts)
        |> Stripe.Request.put_endpoint(path)
        |> Stripe.Request.put_method(:delete)
        |> Stripe.Request.make_request()
      end
    )
  )

  (
    nil

    @doc "<p>With <a href=\"/docs/connect\">Connect</a>, you may flag accounts as suspicious.</p>\n\n<p>Test-mode Custom and Express accounts can be rejected at any time. Accounts created using live-mode keys may only be rejected once all balances are zero.</p>\n\n#### Details\n\n * Method: `post`\n * Path: `/v1/accounts/{account}/reject`\n"
    (
      @spec reject(
              account :: binary(),
              params :: %{optional(:expand) => list(binary), optional(:reason) => binary},
              opts :: Keyword.t()
            ) :: {:ok, Stripe.Account.t()} | {:error, Stripe.ApiErrors.t()} | {:error, term()}
      def reject(account, params \\ %{}, opts \\ []) do
        path =
          Stripe.OpenApi.Path.replace_path_params(
            "/v1/accounts/{account}/reject",
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
              }
            ],
            [account]
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

    @doc "<p>Returns a list of people associated with the account’s legal entity. The people are returned sorted by creation date, with the most recent people appearing first.</p>\n\n#### Details\n\n * Method: `get`\n * Path: `/v1/accounts/{account}/persons`\n"
    (
      @spec persons(
              account :: binary(),
              params :: %{
                optional(:ending_before) => binary,
                optional(:expand) => list(binary),
                optional(:limit) => integer,
                optional(:relationship) => relationship,
                optional(:starting_after) => binary
              },
              opts :: Keyword.t()
            ) ::
              {:ok, Stripe.List.t(Stripe.Person.t())}
              | {:error, Stripe.ApiErrors.t()}
              | {:error, term()}
      def persons(account, params \\ %{}, opts \\ []) do
        path =
          Stripe.OpenApi.Path.replace_path_params(
            "/v1/accounts/{account}/persons",
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
              }
            ],
            [account]
          )

        Stripe.Request.new_request(opts)
        |> Stripe.Request.put_endpoint(path)
        |> Stripe.Request.put_params(params)
        |> Stripe.Request.put_method(:get)
        |> Stripe.Request.make_request()
      end
    )
  )

  (
    nil

    @doc "<p>Returns a list of capabilities associated with the account. The capabilities are returned sorted by creation date, with the most recent capability appearing first.</p>\n\n#### Details\n\n * Method: `get`\n * Path: `/v1/accounts/{account}/capabilities`\n"
    (
      @spec capabilities(
              account :: binary(),
              params :: %{optional(:expand) => list(binary)},
              opts :: Keyword.t()
            ) ::
              {:ok, Stripe.List.t(Stripe.Capability.t())}
              | {:error, Stripe.ApiErrors.t()}
              | {:error, term()}
      def capabilities(account, params \\ %{}, opts \\ []) do
        path =
          Stripe.OpenApi.Path.replace_path_params(
            "/v1/accounts/{account}/capabilities",
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
              }
            ],
            [account]
          )

        Stripe.Request.new_request(opts)
        |> Stripe.Request.put_endpoint(path)
        |> Stripe.Request.put_params(params)
        |> Stripe.Request.put_method(:get)
        |> Stripe.Request.make_request()
      end
    )
  )
end
