defmodule Stripe.Token do
  use Stripe.Entity

  @moduledoc "Tokenization is the process Stripe uses to collect sensitive card or bank\naccount details, or personally identifiable information (PII), directly from\nyour customers in a secure manner. A token representing this information is\nreturned to your server to use. You should use our\n[recommended payments integrations](https://stripe.com/docs/payments) to perform this process\nclient-side. This ensures that no sensitive card data touches your server,\nand allows your integration to operate in a PCI-compliant way.\n\nIf you cannot use client-side tokenization, you can also create tokens using\nthe API with either your publishable or secret API key. Keep in mind that if\nyour integration uses this method, you are responsible for any PCI compliance\nthat may be required, and you must keep your secret API key safe. Unlike with\nclient-side tokenization, your customer's information is not sent directly to\nStripe, so we cannot determine how it is handled or stored.\n\nTokens cannot be stored or used more than once. To store card or bank account\ninformation for later use, you can create [Customer](https://stripe.com/docs/api#customers)\nobjects or [Custom accounts](https://stripe.com/docs/api#external_accounts). Note that\n[Radar](https://stripe.com/docs/radar), our integrated solution for automatic fraud protection,\nperforms best with integrations that use client-side tokenization."
  (
    defstruct [:bank_account, :card, :client_ip, :created, :id, :livemode, :object, :type, :used]

    @typedoc "The `token` type.\n\n  * `bank_account` \n  * `card` \n  * `client_ip` IP address of the client that generated the token.\n  * `created` Time at which the object was created. Measured in seconds since the Unix epoch.\n  * `id` Unique identifier for the object.\n  * `livemode` Has the value `true` if the object exists in live mode or the value `false` if the object exists in test mode.\n  * `object` String representing the object's type. Objects of the same type share the same value.\n  * `type` Type of the token: `account`, `bank_account`, `card`, or `pii`.\n  * `used` Whether this token has already been used (tokens can be used only once).\n"
    @type t :: %__MODULE__{
            bank_account: Stripe.BankAccount.t(),
            card: Stripe.Card.t(),
            client_ip: binary | nil,
            created: integer,
            id: binary,
            livemode: boolean,
            object: binary,
            type: binary,
            used: boolean
          }
  )

  (
    @typedoc "Information for the account this token will represent."
    @type account :: %{
            optional(:business_type) => :company | :government_entity | :individual | :non_profit,
            optional(:company) => company,
            optional(:individual) => individual,
            optional(:tos_shown_and_accepted) => boolean
          }
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
    @typedoc "The Kanji variation of the company's primary address (Japan only)."
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
    @typedoc "The bank account this token will represent."
    @type bank_account :: %{
            optional(:account_holder_name) => binary,
            optional(:account_holder_type) => :company | :individual,
            optional(:account_number) => binary,
            optional(:account_type) => :checking | :futsu | :savings | :toza,
            optional(:country) => binary,
            optional(:currency) => binary,
            optional(:routing_number) => binary
          }
  )

  (
    @typedoc nil
    @type card :: %{
            optional(:address_city) => binary,
            optional(:address_country) => binary,
            optional(:address_line1) => binary,
            optional(:address_line2) => binary,
            optional(:address_state) => binary,
            optional(:address_zip) => binary,
            optional(:currency) => binary,
            optional(:cvc) => binary,
            optional(:exp_month) => binary,
            optional(:exp_year) => binary,
            optional(:name) => binary,
            optional(:number) => binary
          }
  )

  (
    @typedoc "Information about the company or business."
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
            optional(:ownership_declaration_shown_and_signed) => boolean,
            optional(:phone) => binary,
            optional(:registration_number) => binary,
            optional(:structure) =>
              :free_zone_establishment
              | :free_zone_llc
              | :government_instrumentality
              | :governmental_unit
              | :incorporated_non_profit
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
              | :unincorporated_non_profit,
            optional(:tax_id) => binary,
            optional(:tax_id_registrar) => binary,
            optional(:vat_id) => binary,
            optional(:verification) => verification
          }
  )

  (
    @typedoc "One or more documents that demonstrate proof that this person is authorized to represent the company."
    @type company_authorization :: %{optional(:files) => list(binary)}
  )

  (
    @typedoc "The updated CVC value this token will represent."
    @type cvc_update :: %{optional(:cvc) => binary}
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
            optional(:company_authorization) => company_authorization,
            optional(:passport) => passport,
            optional(:visa) => visa
          }
  )

  (
    @typedoc "Information about the person represented by the account."
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
    @typedoc "This hash is used to attest that the beneficial owner information provided to Stripe is both current and correct."
    @type ownership_declaration :: %{
            optional(:date) => integer,
            optional(:ip) => binary,
            optional(:user_agent) => binary
          }
  )

  (
    @typedoc "One or more documents showing the person's passport page with photo and personal data."
    @type passport :: %{optional(:files) => list(binary)}
  )

  (
    @typedoc "Information for the person this token will represent."
    @type person :: %{
            optional(:address) => address,
            optional(:address_kana) => address_kana,
            optional(:address_kanji) => address_kanji,
            optional(:dob) => dob | binary,
            optional(:documents) => documents,
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
            optional(:nationality) => binary,
            optional(:phone) => binary,
            optional(:political_exposure) => binary,
            optional(:registered_address) => registered_address,
            optional(:relationship) => relationship,
            optional(:ssn_last_4) => binary,
            optional(:verification) => verification
          }
  )

  (
    @typedoc "The PII this token will represent."
    @type pii :: %{optional(:id_number) => binary}
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
    @typedoc "The relationship that this person has with the account's legal entity."
    @type relationship :: %{
            optional(:director) => boolean,
            optional(:executive) => boolean,
            optional(:owner) => boolean,
            optional(:percent_ownership) => number | binary,
            optional(:representative) => boolean,
            optional(:title) => binary
          }
  )

  (
    @typedoc "Information on the verification state of the company."
    @type verification :: %{optional(:document) => document}
  )

  (
    @typedoc "One or more documents showing the person's visa required for living in the country where they are residing."
    @type visa :: %{optional(:files) => list(binary)}
  )

  (
    nil

    @doc "<p>Retrieves the token with the given ID.</p>\n\n#### Details\n\n * Method: `get`\n * Path: `/v1/tokens/{token}`\n"
    (
      @spec retrieve(
              token :: binary(),
              params :: %{optional(:expand) => list(binary)},
              opts :: Keyword.t()
            ) :: {:ok, Stripe.Token.t()} | {:error, Stripe.ApiErrors.t()} | {:error, term()}
      def retrieve(token, params \\ %{}, opts \\ []) do
        path =
          Stripe.OpenApi.Path.replace_path_params(
            "/v1/tokens/{token}",
            [
              %OpenApiGen.Blueprint.Parameter{
                in: "path",
                name: "token",
                required: true,
                schema: %OpenApiGen.Blueprint.Parameter.Schema{
                  name: "token",
                  title: nil,
                  type: "string",
                  items: [],
                  properties: [],
                  any_of: []
                }
              }
            ],
            [token]
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

    @doc "<p>Creates a single-use token that represents a bank account’s details.\nThis token can be used with any API method in place of a bank account dictionary. This token can be used only once, by attaching it to a <a href=\"#accounts\">Custom account</a>.</p>\n\n#### Details\n\n * Method: `post`\n * Path: `/v1/tokens`\n"
    (
      @spec create(
              params :: %{
                optional(:account) => account,
                optional(:bank_account) => bank_account,
                optional(:card) => card | binary,
                optional(:customer) => binary,
                optional(:cvc_update) => cvc_update,
                optional(:expand) => list(binary),
                optional(:person) => person,
                optional(:pii) => pii
              },
              opts :: Keyword.t()
            ) :: {:ok, Stripe.Token.t()} | {:error, Stripe.ApiErrors.t()} | {:error, term()}
      def create(params \\ %{}, opts \\ []) do
        path = Stripe.OpenApi.Path.replace_path_params("/v1/tokens", [], [])

        Stripe.Request.new_request(opts)
        |> Stripe.Request.put_endpoint(path)
        |> Stripe.Request.put_params(params)
        |> Stripe.Request.put_method(:post)
        |> Stripe.Request.make_request()
      end
    )
  )
end