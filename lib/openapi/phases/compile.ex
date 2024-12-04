defmodule Stripe.OpenApi.Phases.Compile do
  @moduledoc false
  def run(blueprint, _options) do
    modules = Enum.map(blueprint.components, fn {_k, component} -> component.module end)

    for {_name, component} <- blueprint.components do
      funcs_types =
        for operation <- component.operations,
            operation_definition =
              lookup_operation(
                {operation["path"], String.to_atom(operation["operation"])},
                blueprint.operations
              ),
            operation_definition != nil do
          arguments =
            operation_definition.path_parameters
            |> Enum.map(&String.to_atom(&1.name))

          params? =
            match?({:object, _, [_ | _]}, operation_definition.query_parameters) ||
              match?({:object, _, [_ | _]}, operation_definition.body_parameters)

          argument_names =
            arguments
            |> Enum.map(fn
              name ->
                Macro.var(name, __MODULE__)
            end)

          argument_values =
            arguments
            |> Enum.reject(&(&1 == :params))
            |> Enum.map(fn name ->
              Macro.var(name, __MODULE__)
            end)

          argument_specs =
            arguments
            |> Enum.map(fn
              :params ->
                quote do
                  params :: map()
                end

              name ->
                quote do
                  unquote(Macro.var(name, __MODULE__)) :: binary()
                end
            end)

          function_name =
            operation_definition
            |> to_func_name(operation)
            |> Macro.underscore()
            |> String.to_atom()

          success_response_spec = return_spec(operation_definition.success_response)

          params =
            cond do
              operation_definition.query_parameters != {:object, [], []} ->
                operation_definition.query_parameters

              operation_definition.body_parameters != {:object, [], []} ->
                operation_definition.body_parameters

              true ->
                []
            end

          {param_specs, object_types} = unnest_object_types(params)

          object_types = MapSet.to_list(object_types)

          function_code =
            if params? do
              quote do
                @spec unquote(function_name)(
                        unquote_splicing(argument_specs),
                        params :: unquote(to_inline_spec(param_specs)),
                        opts :: Keyword.t()
                      ) ::
                        {:ok, unquote(success_response_spec)}
                        | {:error, Stripe.ApiErrors.t()}
                        | {:error, term()}
                def unquote(function_name)(
                      unquote_splicing(argument_names),
                      params \\ %{},
                      opts \\ []
                    ) do
                  path =
                    Stripe.OpenApi.Path.replace_path_params(
                      unquote(operation_definition.path),
                      unquote(operation_definition.path_parameters),
                      unquote(argument_names)
                    )

                  Stripe.Request.new_request(opts)
                  |> Stripe.Request.put_endpoint(path)
                  |> Stripe.Request.put_params(params)
                  |> Stripe.Request.put_method(unquote(operation_definition.method))
                  |> Stripe.Request.make_request()
                end
              end
            else
              if operation_definition.path == "/v1/files" and operation_definition.method == :post do
                quote do
                  @spec unquote(function_name)(
                          unquote_splicing(argument_specs),
                          opts :: Keyword.t()
                        ) ::
                          {:ok, unquote(success_response_spec)}
                          | {:error, Stripe.ApiErrors.t()}
                          | {:error, term()}
                  def unquote(function_name)(
                        params \\ %{},
                        opts \\ []
                      ) do
                    Stripe.Request.new_request(opts)
                    |> Stripe.Request.put_endpoint(unquote(operation_definition.path))
                    |> Stripe.Request.put_params(params)
                    |> Stripe.Request.put_method(unquote(operation_definition.method))
                    |> Stripe.Request.make_file_upload_request()
                  end
                end
              else
                quote do
                  @spec unquote(function_name)(
                          unquote_splicing(argument_specs),
                          opts :: Keyword.t()
                        ) ::
                          {:ok, unquote(success_response_spec)}
                          | {:error, Stripe.ApiErrors.t()}
                          | {:error, term()}
                  def unquote(function_name)(
                        unquote_splicing(argument_names),
                        opts \\ []
                      ) do
                    path =
                      Stripe.OpenApi.Path.replace_path_params(
                        unquote(operation_definition.path),
                        unquote(operation_definition.path_parameters),
                        unquote(argument_values)
                      )

                    Stripe.Request.new_request(opts)
                    |> Stripe.Request.put_endpoint(path)
                    |> Stripe.Request.put_method(unquote(operation_definition.method))
                    |> Stripe.Request.make_request()
                  end
                end
              end
            end

          deprecated =
            if operation_definition.deprecated do
              quote do
                @deprecated "Stripe has deprecated this operation"
              end
            else
              quote do
              end
            end

          ast =
            quote do
              unquote(deprecated)

              @doc unquote(operation_definition.description)

              unquote(function_code)
            end

          {ast, object_types}
        end

      {funcs, types} = Enum.unzip(funcs_types)
      fields = component.properties |> Map.keys() |> Enum.map(&String.to_atom/1)

      # TODO fix  uniq
      types =
        List.flatten(types)
        |> Enum.uniq_by(fn {_, meta, _} -> meta[:name] end)
        |> Enum.sort()
        |> Enum.map(&to_type_spec/1)

      specs =
        Enum.map(component.properties, fn {key, value} ->
          {String.to_atom(key), build_spec(value, modules)}
        end)
        |> Enum.sort()

      typedoc_fields =
        component.properties
        |> Enum.sort()
        |> Enum.map_join("\n", fn {key, value} -> typedoc(key, value) end)

      typedoc = """
      The `#{component.name}` type.

      #{typedoc_fields}
      """

      type_doc =
        if fields != nil do
          quote do
            defstruct unquote(fields)

            @typedoc unquote(typedoc)
            @type t :: %__MODULE__{
                    unquote_splicing(specs)
                  }
          end
        else
          quote do
          end
        end

      body =
        quote do
          use Stripe.Entity

          @moduledoc unquote(component.description)
          unquote(type_doc)

          unquote_splicing(types)

          unquote_splicing(funcs)
        end

      # Module.create(component.module, body, Macro.Env.location(__ENV__))
      code =
        quote do
          defmodule unquote(component.module) do
            unquote(body)
          end
        end

      bin =
        code
        |> Macro.to_string()
        |> Code.format_string!()

      [_ | names] = Module.split(component.module)
      filename = names |> Enum.map_join("__", &Macro.underscore/1)

      File.write!("lib/generated/#{filename}.ex", bin)
    end

    {:ok, blueprint}
  end

  defp unnest_object_types(params) do
    Macro.postwalk(params, MapSet.new(), fn
      {:object, meta, children}, acc ->
        if meta[:name] == nil || children == [] do
          {{:object, meta, children}, acc}
        else
          {{:ref, [name: meta[:name]], []}, MapSet.put(acc, {:object, meta, children})}
        end

      other, acc ->
        {other, acc}
    end)
  end

  defp to_type_spec({:object, meta, children}) do
    specs = Enum.map(children, &to_spec_map/1)

    name = type_spec_name(meta[:name])

    quote do
      @typedoc unquote(meta[:description])
      @type unquote(Macro.var(name, __MODULE__)) :: %{
              unquote_splicing(specs)
            }
    end
  end

  defp to_type_spec({:array, meta, [child]} = _ast) do
    name = type_spec_name(meta[:name])

    quote do
      @typedoc unquote(meta[:description])
      @type unquote(Macro.var(name, __MODULE__)) :: unquote(to_type(child))
    end
  end

  defp to_type_spec({_, meta, children}) do
    specs = Enum.map(children, &to_spec_map/1)

    name = type_spec_name(meta[:name])

    quote do
      @typedoc unquote(meta[:description])
      @type unquote(Macro.var(name, __MODULE__)) :: %{
              unquote_splicing(specs)
            }
    end
  end

  defp type_spec_name(name) do
    if name in [:reference] do
      :reference_0
    else
      name
    end
  end

  defp to_inline_spec({_, _meta, children}) do
    specs = Enum.map(children, &to_spec_map/1)

    quote do
      %{
        unquote_splicing(specs)
      }
    end
  end

  defp to_spec_map({:array, meta, [_type]} = ast) do
    {to_name(meta), to_type(ast)}
  end

  defp to_spec_map({:any_of, meta, [type | tail]}) do
    {to_name(meta),
     quote do
       unquote(to_type(type)) | unquote(to_type(tail))
     end}
  end

  defp to_spec_map({:ref, meta, _} = ast) do
    {to_name(meta), to_type(ast)}
  end

  defp to_spec_map({_type, meta, _children} = ast) do
    {to_name(meta), to_type(ast)}
  end

  defp to_name(meta) do
    if meta[:required] do
      meta[:name]
    else
      quote do
        optional(unquote(meta[:name]))
      end
    end
  end

  def to_type([type]) do
    quote do
      unquote(to_type(type))
    end
  end

  def to_type([type | tail]) do
    quote do
      unquote(to_type(type)) | unquote(to_type(tail))
    end
  end

  def to_type({:ref, meta, _}) do
    Macro.var(meta[:name], __MODULE__)
  end

  def to_type({:array, _meta, [type]}) do
    quote do
      list(unquote(to_type(type)))
    end
  end

  def to_type({:any_of, _, [type | tail]}) do
    quote do
      unquote(to_type(type)) | unquote(to_type(tail))
    end
  end

  def to_type({:string, metadata, _}) do
    if metadata[:enum] do
      to_type(metadata[:enum])
    else
      to_type(:string)
    end
  end

  def to_type({:object, metadata, _}) do
    if metadata[:name] == :metadata do
      quote do
        %{optional(binary) => binary}
      end
    else
      quote do
        map()
      end
    end
  end

  def to_type({type, _, _}) do
    to_type(type)
  end

  def to_type(type) when type in [:boolean, :number, :integer, :float] do
    quote do
      unquote(Macro.var(type, __MODULE__))
    end
  end

  def to_type(:string) do
    quote do
      binary
    end
  end

  def to_type(type) do
    type
  end

  defp return_spec(%OpenApiGen.Blueprint.Reference{name: name}) do
    module = module_from_ref(name)

    quote do
      unquote(module).t()
    end
  end

  defp return_spec(%OpenApiGen.Blueprint.ListOf{type_of: type}) do
    quote do
      Stripe.List.t(unquote(return_spec(type)))
    end
  end

  defp return_spec(%OpenApiGen.Blueprint.SearchResult{type_of: type}) do
    quote do
      Stripe.SearchResult.t(unquote(return_spec(type)))
    end
  end

  defp return_spec(%{any_of: [type]} = _type) do
    return_spec(type)
  end

  defp return_spec(%OpenApiGen.Blueprint.AnyOf{any_of: [any_of | tail]} = type) do
    type = Map.put(type, :any_of, tail)
    {:|, [], [return_spec(any_of), return_spec(type)]}
  end

  defp return_spec(_) do
    []
  end

  defp build_spec(%{"nullable" => true} = type, modules) do
    type = Map.delete(type, "nullable")
    {:|, [], [build_spec(type, modules), nil]}
  end

  defp build_spec(%{"anyOf" => [type]} = _type, modules) do
    build_spec(type, modules)
  end

  defp build_spec(%{"anyOf" => [any_of | tail]} = type, modules) do
    type = Map.put(type, "anyOf", tail)
    {:|, [], [build_spec(any_of, modules), build_spec(type, modules)]}
  end

  defp build_spec(%{"type" => "string"}, _) do
    quote do
      binary
    end
  end

  defp build_spec(%{"type" => "boolean"}, _) do
    quote do
      boolean
    end
  end

  defp build_spec(%{"type" => "integer"}, _) do
    quote do
      integer
    end
  end

  defp build_spec(%{"$ref" => ref}, modules) do
    module = module_from_ref(ref)

    if module in modules do
      quote do
        unquote(module).t()
      end
    else
      quote do
        term
      end
    end
  end

  defp build_spec(_, _) do
    quote do
      term
    end
  end

  defp module_from_ref(ref) do
    module =
      ref |> String.split("/") |> List.last() |> String.split(".") |> Enum.map(&Macro.camelize/1)

    Module.concat(["Stripe" | module])
  end

  defp typedoc(field, props) do
    "  * `#{field}` #{props["description"]}"
  end

  defp lookup_operation(path, operations) do
    Map.get(operations, path)
  end

  # NOTE: This is a mapping of operation ids to function names. This is necessary
  # to avoid breaking changes. In the future, we should remove this mapping and
  # use the operation id directly as the function name.
  #
  # Temporarily, I am adding all the existing ones although using
  # stripe_extension["method_name"] could be default while we only add new ones.
  # That will be done in follow up work since it would be difficult to assess
  # the situation.
  @operation_identity_mapping %{
    {"GetClimateProductsProduct", "/v1/climate/products/{product}", "retrieve"} => "retrieve",
    {"GetClimateProducts", "/v1/climate/products", "list"} => "list",
    {"PostPaymentMethods", "/v1/payment_methods", "create"} => "create",
    {"GetPaymentMethodsPaymentMethod", "/v1/payment_methods/{payment_method}", "retrieve"} =>
      "retrieve",
    {"PostPaymentMethodsPaymentMethod", "/v1/payment_methods/{payment_method}", "update"} =>
      "update",
    {"GetPaymentMethods", "/v1/payment_methods", "list"} => "list",
    {"PostPaymentMethodsPaymentMethodAttach", "/v1/payment_methods/{payment_method}/attach",
     "attach"} => "attach",
    {"PostPaymentMethodsPaymentMethodDetach", "/v1/payment_methods/{payment_method}/detach",
     "detach"} => "detach",
    {"GetTaxRegistrations", "/v1/tax/registrations", "list"} => "list",
    {"PostTaxRegistrations", "/v1/tax/registrations", "create"} => "create",
    {"GetTaxRegistrationsId", "/v1/tax/registrations/{id}", "retrieve"} => "retrieve",
    {"PostTaxRegistrationsId", "/v1/tax/registrations/{id}", "update"} => "update",
    {"GetTreasuryCreditReversals", "/v1/treasury/credit_reversals", "list"} => "list",
    {"GetTreasuryCreditReversalsCreditReversal",
     "/v1/treasury/credit_reversals/{credit_reversal}", "retrieve"} => "retrieve",
    {"PostTreasuryCreditReversals", "/v1/treasury/credit_reversals", "create"} => "create",
    {"GetFinancialConnectionsTransactionsTransaction",
     "/v1/financial_connections/transactions/{transaction}", "retrieve"} => "retrieve",
    {"GetFinancialConnectionsTransactions", "/v1/financial_connections/transactions", "list"} =>
      "list",
    {"GetRadarValueLists", "/v1/radar/value_lists", "list"} => "list",
    {"GetRadarValueListsValueList", "/v1/radar/value_lists/{value_list}", "retrieve"} =>
      "retrieve",
    {"PostRadarValueLists", "/v1/radar/value_lists", "create"} => "create",
    {"PostRadarValueListsValueList", "/v1/radar/value_lists/{value_list}", "update"} => "update",
    {"DeleteRadarValueListsValueList", "/v1/radar/value_lists/{value_list}", "delete"} =>
      "delete",
    {"GetIssuingAuthorizations", "/v1/issuing/authorizations", "list"} => "list",
    {"GetIssuingAuthorizationsAuthorization", "/v1/issuing/authorizations/{authorization}",
     "retrieve"} => "retrieve",
    {"PostIssuingAuthorizationsAuthorization", "/v1/issuing/authorizations/{authorization}",
     "update"} => "update",
    {"PostIssuingAuthorizationsAuthorizationApprove",
     "/v1/issuing/authorizations/{authorization}/approve", "approve"} => "approve",
    {"PostIssuingAuthorizationsAuthorizationDecline",
     "/v1/issuing/authorizations/{authorization}/decline", "decline"} => "decline",
    {"PostTestHelpersIssuingAuthorizations", "/v1/test_helpers/issuing/authorizations", "create"} =>
      "create",
    {"PostTestHelpersIssuingAuthorizationsAuthorizationIncrement",
     "/v1/test_helpers/issuing/authorizations/{authorization}/increment",
     "increment"} => "increment",
    {"PostTestHelpersIssuingAuthorizationsAuthorizationReverse",
     "/v1/test_helpers/issuing/authorizations/{authorization}/reverse", "reverse"} => "reverse",
    {"PostTestHelpersIssuingAuthorizationsAuthorizationExpire",
     "/v1/test_helpers/issuing/authorizations/{authorization}/expire", "expire"} => "expire",
    {"PostTestHelpersIssuingAuthorizationsAuthorizationCapture",
     "/v1/test_helpers/issuing/authorizations/{authorization}/capture", "capture"} => "capture",
    {"GetCreditNotesCreditNoteLines", "/v1/credit_notes/{credit_note}/lines", "list"} => "list",
    {"GetPaymentMethodDomainsPaymentMethodDomain",
     "/v1/payment_method_domains/{payment_method_domain}", "retrieve"} => "retrieve",
    {"GetPaymentMethodDomains", "/v1/payment_method_domains", "list"} => "list",
    {"PostPaymentMethodDomains", "/v1/payment_method_domains", "create"} => "create",
    {"PostPaymentMethodDomainsPaymentMethodDomain",
     "/v1/payment_method_domains/{payment_method_domain}", "update"} => "update",
    {"PostPaymentMethodDomainsPaymentMethodDomainValidate",
     "/v1/payment_method_domains/{payment_method_domain}/validate", "validate"} => "validate",
    {"PostAccountsAccountLoginLinks", "/v1/accounts/{account}/login_links", "create"} => "create",
    {"GetApplePayDomains", "/v1/apple_pay/domains", "list"} => "list",
    {"PostApplePayDomains", "/v1/apple_pay/domains", "create"} => "create",
    {"GetApplePayDomainsDomain", "/v1/apple_pay/domains/{domain}", "retrieve"} => "retrieve",
    {"DeleteApplePayDomainsDomain", "/v1/apple_pay/domains/{domain}", "delete"} => "delete",
    {"PostTransfersIdReversals", "/v1/transfers/{id}/reversals", "create"} => "create",
    {"GetTransfersIdReversals", "/v1/transfers/{id}/reversals", "list"} => "list",
    {"GetTransfersTransferReversalsId", "/v1/transfers/{transfer}/reversals/{id}", "retrieve"} =>
      "retrieve",
    {"PostTransfersTransferReversalsId", "/v1/transfers/{transfer}/reversals/{id}", "update"} =>
      "update",
    {"GetClimateOrdersOrder", "/v1/climate/orders/{order}", "retrieve"} => "retrieve",
    {"GetClimateOrders", "/v1/climate/orders", "list"} => "list",
    {"PostClimateOrders", "/v1/climate/orders", "create"} => "create",
    {"PostClimateOrdersOrder", "/v1/climate/orders/{order}", "update"} => "update",
    {"PostClimateOrdersOrderCancel", "/v1/climate/orders/{order}/cancel", "cancel"} => "cancel",
    {"GetSetupAttempts", "/v1/setup_attempts", "list"} => "list",
    {"GetTokensToken", "/v1/tokens/{token}", "retrieve"} => "retrieve",
    {"PostTokens", "/v1/tokens", "create"} => "create",
    {"GetPaymentLinks", "/v1/payment_links", "list"} => "list",
    {"GetPaymentLinksPaymentLink", "/v1/payment_links/{payment_link}", "retrieve"} => "retrieve",
    {"GetPaymentLinksPaymentLinkLineItems", "/v1/payment_links/{payment_link}/line_items",
     "list_line_items"} => "list_line_items",
    {"PostPaymentLinks", "/v1/payment_links", "create"} => "create",
    {"PostPaymentLinksPaymentLink", "/v1/payment_links/{payment_link}", "update"} => "update",
    {"PostTopups", "/v1/topups", "create"} => "create",
    {"GetTopups", "/v1/topups", "list"} => "list",
    {"GetTopupsTopup", "/v1/topups/{topup}", "retrieve"} => "retrieve",
    {"PostTopupsTopup", "/v1/topups/{topup}", "update"} => "update",
    {"PostTopupsTopupCancel", "/v1/topups/{topup}/cancel", "cancel"} => "cancel",
    {"PostCustomersCustomerSourcesId", "/v1/customers/{customer}/sources/{id}", "update"} =>
      "update",
    {"DeleteCustomersCustomerSourcesId", "/v1/customers/{customer}/sources/{id}", "delete"} =>
      "delete",
    {"GetCoupons", "/v1/coupons", "list"} => "list",
    {"PostCoupons", "/v1/coupons", "create"} => "create",
    {"GetCouponsCoupon", "/v1/coupons/{coupon}", "retrieve"} => "retrieve",
    {"PostCouponsCoupon", "/v1/coupons/{coupon}", "update"} => "update",
    {"DeleteCouponsCoupon", "/v1/coupons/{coupon}", "delete"} => "delete",
    {"PostTerminalReadersReader", "/v1/terminal/readers/{reader}", "update"} => "update",
    {"GetTerminalReadersReader", "/v1/terminal/readers/{reader}", "retrieve"} => "retrieve",
    {"PostTerminalReaders", "/v1/terminal/readers", "create"} => "create",
    {"GetTerminalReaders", "/v1/terminal/readers", "list"} => "list",
    {"DeleteTerminalReadersReader", "/v1/terminal/readers/{reader}", "delete"} => "delete",
    {"PostTerminalReadersReaderProcessPaymentIntent",
     "/v1/terminal/readers/{reader}/process_payment_intent",
     "process_payment_intent"} => "process_payment_intent",
    {"PostTerminalReadersReaderProcessSetupIntent",
     "/v1/terminal/readers/{reader}/process_setup_intent",
     "process_setup_intent"} => "process_setup_intent",
    {"PostTerminalReadersReaderCancelAction", "/v1/terminal/readers/{reader}/cancel_action",
     "cancel_action"} => "cancel_action",
    {"PostTerminalReadersReaderSetReaderDisplay",
     "/v1/terminal/readers/{reader}/set_reader_display",
     "set_reader_display"} => "set_reader_display",
    {"PostTerminalReadersReaderRefundPayment", "/v1/terminal/readers/{reader}/refund_payment",
     "refund_payment"} => "refund_payment",
    {"PostTestHelpersTerminalReadersReaderPresentPaymentMethod",
     "/v1/test_helpers/terminal/readers/{reader}/present_payment_method",
     "present_payment_method"} => "present_payment_method",
    {"GetSubscriptionItems", "/v1/subscription_items", "list"} => "list",
    {"GetSubscriptionItemsItem", "/v1/subscription_items/{item}", "retrieve"} => "retrieve",
    {"PostSubscriptionItems", "/v1/subscription_items", "create"} => "create",
    {"PostSubscriptionItemsItem", "/v1/subscription_items/{item}", "update"} => "update",
    {"DeleteSubscriptionItemsItem", "/v1/subscription_items/{item}", "delete"} => "delete",
    {"GetSubscriptionItemsSubscriptionItemUsageRecordSummaries",
     "/v1/subscription_items/{subscription_item}/usage_record_summaries",
     "usage_record_summaries"} => "usage_record_summaries",
    {"PostTerminalConnectionTokens", "/v1/terminal/connection_tokens", "create"} => "create",
    {"PostTerminalConfigurations", "/v1/terminal/configurations", "create"} => "create",
    {"GetTerminalConfigurations", "/v1/terminal/configurations", "list"} => "list",
    {"GetTerminalConfigurationsConfiguration", "/v1/terminal/configurations/{configuration}",
     "retrieve"} => "retrieve",
    {"PostTerminalConfigurationsConfiguration", "/v1/terminal/configurations/{configuration}",
     "update"} => "update",
    {"DeleteTerminalConfigurationsConfiguration", "/v1/terminal/configurations/{configuration}",
     "delete"} => "delete",
    {"GetApplicationFees", "/v1/application_fees", "list"} => "list",
    {"GetApplicationFeesId", "/v1/application_fees/{id}", "retrieve"} => "retrieve",
    {"GetFiles", "/v1/files", "list"} => "list",
    {"GetFilesFile", "/v1/files/{file}", "retrieve"} => "retrieve",
    {"PostFiles", "/v1/files", "create"} => "create",
    {"GetReviews", "/v1/reviews", "list"} => "list",
    {"GetReviewsReview", "/v1/reviews/{review}", "retrieve"} => "retrieve",
    {"PostReviewsReviewApprove", "/v1/reviews/{review}/approve", "approve"} => "approve",
    {"GetBalance", "/v1/balance", "retrieve"} => "retrieve",
    {"GetCustomersCustomerCashBalance", "/v1/customers/{customer}/cash_balance", "retrieve"} =>
      "retrieve",
    {"PostCustomersCustomerCashBalance", "/v1/customers/{customer}/cash_balance", "update"} =>
      "update",
    {"GetPaymentIntentsSearch", "/v1/payment_intents/search", "search"} => "search",
    {"PostPaymentIntents", "/v1/payment_intents", "create"} => "create",
    {"GetPaymentIntents", "/v1/payment_intents", "list"} => "list",
    {"GetPaymentIntentsIntent", "/v1/payment_intents/{intent}", "retrieve"} => "retrieve",
    {"PostPaymentIntentsIntent", "/v1/payment_intents/{intent}", "update"} => "update",
    {"PostPaymentIntentsIntentConfirm", "/v1/payment_intents/{intent}/confirm", "confirm"} =>
      "confirm",
    {"PostPaymentIntentsIntentCancel", "/v1/payment_intents/{intent}/cancel", "cancel"} =>
      "cancel",
    {"PostPaymentIntentsIntentCapture", "/v1/payment_intents/{intent}/capture", "capture"} =>
      "capture",
    {"PostPaymentIntentsIntentIncrementAuthorization",
     "/v1/payment_intents/{intent}/increment_authorization",
     "increment_authorization"} => "increment_authorization",
    {"PostPaymentIntentsIntentVerifyMicrodeposits",
     "/v1/payment_intents/{intent}/verify_microdeposits",
     "verify_microdeposits"} => "verify_microdeposits",
    {"PostPaymentIntentsIntentApplyCustomerBalance",
     "/v1/payment_intents/{intent}/apply_customer_balance",
     "apply_customer_balance"} => "apply_customer_balance",
    {"GetAccountsAccountCapabilities", "/v1/accounts/{account}/capabilities", "list"} => "list",
    {"GetAccountsAccountCapabilitiesCapability",
     "/v1/accounts/{account}/capabilities/{capability}", "retrieve"} => "retrieve",
    {"PostAccountsAccountCapabilitiesCapability",
     "/v1/accounts/{account}/capabilities/{capability}", "update"} => "update",
    {"GetSubscriptionSchedules", "/v1/subscription_schedules", "list"} => "list",
    {"PostSubscriptionSchedules", "/v1/subscription_schedules", "create"} => "create",
    {"GetSubscriptionSchedulesSchedule", "/v1/subscription_schedules/{schedule}", "retrieve"} =>
      "retrieve",
    {"PostSubscriptionSchedulesSchedule", "/v1/subscription_schedules/{schedule}", "update"} =>
      "update",
    {"PostSubscriptionSchedulesScheduleCancel", "/v1/subscription_schedules/{schedule}/cancel",
     "cancel"} => "cancel",
    {"PostSubscriptionSchedulesScheduleRelease", "/v1/subscription_schedules/{schedule}/release",
     "release"} => "release",
    {"PostTreasuryFinancialAccounts", "/v1/treasury/financial_accounts", "create"} => "create",
    {"PostTreasuryFinancialAccountsFinancialAccount",
     "/v1/treasury/financial_accounts/{financial_account}", "update"} => "update",
    {"PostTreasuryFinancialAccountsFinancialAccountFeatures",
     "/v1/treasury/financial_accounts/{financial_account}/features",
     "update_features"} => "update_features",
    {"GetTreasuryFinancialAccounts", "/v1/treasury/financial_accounts", "list"} => "list",
    {"GetTreasuryFinancialAccountsFinancialAccount",
     "/v1/treasury/financial_accounts/{financial_account}", "retrieve"} => "retrieve",
    {"GetTreasuryFinancialAccountsFinancialAccountFeatures",
     "/v1/treasury/financial_accounts/{financial_account}/features",
     "retrieve_features"} => "retrieve_features",
    {"GetChargesSearch", "/v1/charges/search", "search"} => "search",
    {"GetCharges", "/v1/charges", "list"} => "list",
    {"PostCharges", "/v1/charges", "create"} => "create",
    {"GetChargesCharge", "/v1/charges/{charge}", "retrieve"} => "retrieve",
    {"PostChargesCharge", "/v1/charges/{charge}", "update"} => "update",
    {"PostChargesChargeCapture", "/v1/charges/{charge}/capture", "capture"} => "capture",
    {"GetCustomersCustomerSources", "/v1/customers/{customer}/sources", "list"} => "list",
    {"GetCustomersCustomerSourcesId", "/v1/customers/{customer}/sources/{id}", "retrieve"} =>
      "retrieve",
    {"PostCustomersCustomerSources", "/v1/customers/{customer}/sources", "create"} => "create",
    {"GetCustomersSearch", "/v1/customers/search", "search"} => "search",
    {"GetCustomers", "/v1/customers", "list"} => "list",
    {"PostCustomers", "/v1/customers", "create"} => "create",
    {"GetCustomersCustomer", "/v1/customers/{customer}", "retrieve"} => "retrieve",
    {"PostCustomersCustomer", "/v1/customers/{customer}", "update"} => "update",
    {"DeleteCustomersCustomer", "/v1/customers/{customer}", "delete"} => "delete",
    {"GetCustomersCustomerPaymentMethods", "/v1/customers/{customer}/payment_methods",
     "list_payment_methods"} => "list_payment_methods",
    {"GetCustomersCustomerPaymentMethodsPaymentMethod",
     "/v1/customers/{customer}/payment_methods/{payment_method}",
     "retrieve_payment_method"} => "retrieve_payment_method",
    {"GetCustomersCustomerBalanceTransactions", "/v1/customers/{customer}/balance_transactions",
     "balance_transactions"} => "balance_transactions",
    {"PostTestHelpersCustomersCustomerFundCashBalance",
     "/v1/test_helpers/customers/{customer}/fund_cash_balance",
     "fund_cash_balance"} => "fund_cash_balance",
    {"PostCustomersCustomerFundingInstructions", "/v1/customers/{customer}/funding_instructions",
     "create_funding_instructions"} => "create_funding_instructions",
    {"DeleteCustomersCustomerDiscount", "/v1/customers/{customer}/discount", "delete_discount"} =>
      "delete_discount",
    {"GetReportingReportTypesReportType", "/v1/reporting/report_types/{report_type}", "retrieve"} =>
      "retrieve",
    {"GetReportingReportTypes", "/v1/reporting/report_types", "list"} => "list",
    {"PostTaxCalculations", "/v1/tax/calculations", "create"} => "create",
    {"GetTaxCalculationsCalculationLineItems", "/v1/tax/calculations/{calculation}/line_items",
     "list_line_items"} => "list_line_items",
    {"GetAccountsAccountExternalAccounts", "/v1/accounts/{account}/external_accounts", "list"} =>
      "list",
    {"GetAccountsAccountExternalAccountsId", "/v1/accounts/{account}/external_accounts/{id}",
     "retrieve"} => "retrieve",
    {"PostAccountsAccountExternalAccounts", "/v1/accounts/{account}/external_accounts", "create"} =>
      "create",
    {"PostAccountsAccountExternalAccountsId", "/v1/accounts/{account}/external_accounts/{id}",
     "update"} => "update",
    {"DeleteAccountsAccountExternalAccountsId", "/v1/accounts/{account}/external_accounts/{id}",
     "delete"} => "delete",
    {"GetTreasuryTransactionsId", "/v1/treasury/transactions/{id}", "retrieve"} => "retrieve",
    {"GetTreasuryTransactions", "/v1/treasury/transactions", "list"} => "list",
    {"GetIssuingTokens", "/v1/issuing/tokens", "list"} => "list",
    {"GetIssuingTokensToken", "/v1/issuing/tokens/{token}", "retrieve"} => "retrieve",
    {"PostIssuingTokensToken", "/v1/issuing/tokens/{token}", "update"} => "update",
    {"GetWebhookEndpoints", "/v1/webhook_endpoints", "list"} => "list",
    {"GetWebhookEndpointsWebhookEndpoint", "/v1/webhook_endpoints/{webhook_endpoint}", "retrieve"} =>
      "retrieve",
    {"PostWebhookEndpoints", "/v1/webhook_endpoints", "create"} => "create",
    {"PostWebhookEndpointsWebhookEndpoint", "/v1/webhook_endpoints/{webhook_endpoint}", "update"} =>
      "update",
    {"DeleteWebhookEndpointsWebhookEndpoint", "/v1/webhook_endpoints/{webhook_endpoint}",
     "delete"} => "delete",
    {"GetPricesSearch", "/v1/prices/search", "search"} => "search",
    {"GetPrices", "/v1/prices", "list"} => "list",
    {"PostPrices", "/v1/prices", "create"} => "create",
    {"GetPricesPrice", "/v1/prices/{price}", "retrieve"} => "retrieve",
    {"PostPricesPrice", "/v1/prices/{price}", "update"} => "update",
    {"PostCustomersCustomerSourcesId", "/v1/customers/{customer}/sources/{id}", "update"} =>
      "update",
    {"DeleteCustomersCustomerSourcesId", "/v1/customers/{customer}/sources/{id}", "delete"} =>
      "delete",
    {"PostCustomersCustomerSourcesIdVerify", "/v1/customers/{customer}/sources/{id}/verify",
     "verify"} => "verify",
    {"GetInvoicesSearch", "/v1/invoices/search", "search"} => "search",
    {"GetInvoicesUpcoming", "/v1/invoices/upcoming", "upcoming"} => "upcoming",
    {"PostInvoicesInvoice", "/v1/invoices/{invoice}", "update"} => "update",
    {"PostInvoicesInvoicePay", "/v1/invoices/{invoice}/pay", "pay"} => "pay",
    {"GetInvoicesUpcomingLines", "/v1/invoices/upcoming/lines", "upcoming_lines"} =>
      "upcoming_lines",
    {"PostInvoices", "/v1/invoices", "create"} => "create",
    {"GetInvoices", "/v1/invoices", "list"} => "list",
    {"GetInvoicesInvoice", "/v1/invoices/{invoice}", "retrieve"} => "retrieve",
    {"DeleteInvoicesInvoice", "/v1/invoices/{invoice}", "delete"} => "delete",
    {"PostInvoicesInvoiceFinalize", "/v1/invoices/{invoice}/finalize", "finalize_invoice"} =>
      "finalize_invoice",
    {"PostInvoicesInvoiceSend", "/v1/invoices/{invoice}/send", "send_invoice"} => "send_invoice",
    {"PostInvoicesInvoiceMarkUncollectible", "/v1/invoices/{invoice}/mark_uncollectible",
     "mark_uncollectible"} => "mark_uncollectible",
    {"PostInvoicesInvoiceVoid", "/v1/invoices/{invoice}/void", "void_invoice"} => "void_invoice",
    {"GetCustomersCustomerCashBalanceTransactionsTransaction",
     "/v1/customers/{customer}/cash_balance_transactions/{transaction}",
     "retrieve"} => "retrieve",
    {"GetCustomersCustomerCashBalanceTransactions",
     "/v1/customers/{customer}/cash_balance_transactions", "list"} => "list",
    {"GetIssuingCards", "/v1/issuing/cards", "list"} => "list",
    {"PostIssuingCards", "/v1/issuing/cards", "create"} => "create",
    {"GetIssuingCardsCard", "/v1/issuing/cards/{card}", "retrieve"} => "retrieve",
    {"PostIssuingCardsCard", "/v1/issuing/cards/{card}", "update"} => "update",
    {"PostTestHelpersIssuingCardsCardShippingDeliver",
     "/v1/test_helpers/issuing/cards/{card}/shipping/deliver", "deliver_card"} => "deliver_card",
    {"PostTestHelpersIssuingCardsCardShippingShip",
     "/v1/test_helpers/issuing/cards/{card}/shipping/ship", "ship_card"} => "ship_card",
    {"PostTestHelpersIssuingCardsCardShippingReturn",
     "/v1/test_helpers/issuing/cards/{card}/shipping/return", "return_card"} => "return_card",
    {"PostTestHelpersIssuingCardsCardShippingFail",
     "/v1/test_helpers/issuing/cards/{card}/shipping/fail", "fail_card"} => "fail_card",
    {"GetChargesChargeRefunds", "/v1/charges/{charge}/refunds", "list"} => "list",
    {"GetChargesChargeRefundsRefund", "/v1/charges/{charge}/refunds/{refund}", "retrieve"} =>
      "retrieve",
    {"PostRefunds", "/v1/refunds", "create"} => "create",
    {"PostRefundsRefund", "/v1/refunds/{refund}", "update"} => "update",
    {"PostRefundsRefundCancel", "/v1/refunds/{refund}/cancel", "cancel"} => "cancel",
    {"PostTestHelpersRefundsRefundExpire", "/v1/test_helpers/refunds/{refund}/expire", "expire"} =>
      "expire",
    {"GetBalanceTransactions", "/v1/balance_transactions", "list"} => "list",
    {"GetBalanceTransactionsId", "/v1/balance_transactions/{id}", "retrieve"} => "retrieve",
    {"PostAccountLinks", "/v1/account_links", "create"} => "create",
    {"GetPromotionCodesPromotionCode", "/v1/promotion_codes/{promotion_code}", "retrieve"} =>
      "retrieve",
    {"PostPromotionCodes", "/v1/promotion_codes", "create"} => "create",
    {"PostPromotionCodesPromotionCode", "/v1/promotion_codes/{promotion_code}", "update"} =>
      "update",
    {"GetPromotionCodes", "/v1/promotion_codes", "list"} => "list",
    {"PostIdentityVerificationSessions", "/v1/identity/verification_sessions", "create"} =>
      "create",
    {"GetIdentityVerificationSessionsSession", "/v1/identity/verification_sessions/{session}",
     "retrieve"} => "retrieve",
    {"GetIdentityVerificationSessions", "/v1/identity/verification_sessions", "list"} => "list",
    {"PostIdentityVerificationSessionsSessionCancel",
     "/v1/identity/verification_sessions/{session}/cancel", "cancel"} => "cancel",
    {"PostIdentityVerificationSessionsSessionRedact",
     "/v1/identity/verification_sessions/{session}/redact", "redact"} => "redact",
    {"PostIdentityVerificationSessionsSession", "/v1/identity/verification_sessions/{session}",
     "update"} => "update",
    {"GetTerminalLocationsLocation", "/v1/terminal/locations/{location}", "retrieve"} =>
      "retrieve",
    {"PostTerminalLocations", "/v1/terminal/locations", "create"} => "create",
    {"PostTerminalLocationsLocation", "/v1/terminal/locations/{location}", "update"} => "update",
    {"GetTerminalLocations", "/v1/terminal/locations", "list"} => "list",
    {"DeleteTerminalLocationsLocation", "/v1/terminal/locations/{location}", "delete"} =>
      "delete",
    {"GetAccount", "/v1/account", "retrieve"} => "retrieve",
    {"PostAccountsAccount", "/v1/accounts/{account}", "update"} => "update",
    {"GetAccounts", "/v1/accounts", "list"} => "list",
    {"PostAccounts", "/v1/accounts", "create"} => "create",
    {"DeleteAccountsAccount", "/v1/accounts/{account}", "delete"} => "delete",
    {"PostAccountsAccountReject", "/v1/accounts/{account}/reject", "reject"} => "reject",
    {"GetAccountsAccountPersons", "/v1/accounts/{account}/persons", "persons"} => "persons",
    {"GetAccountsAccountCapabilities", "/v1/accounts/{account}/capabilities", "capabilities"} =>
      "capabilities",
    {"GetProductsSearch", "/v1/products/search", "search"} => "search",
    {"PostProducts", "/v1/products", "create"} => "create",
    {"GetProductsId", "/v1/products/{id}", "retrieve"} => "retrieve",
    {"PostProductsId", "/v1/products/{id}", "update"} => "update",
    {"GetProducts", "/v1/products", "list"} => "list",
    {"DeleteProductsId", "/v1/products/{id}", "delete"} => "delete",
    {"GetAppsSecretsFind", "/v1/apps/secrets/find", "find"} => "find",
    {"PostAppsSecrets", "/v1/apps/secrets", "create"} => "create",
    {"PostAppsSecretsDelete", "/v1/apps/secrets/delete", "delete_where"} => "delete_where",
    {"GetAppsSecrets", "/v1/apps/secrets", "list"} => "list",
    {"GetTaxSettings", "/v1/tax/settings", "retrieve"} => "retrieve",
    {"PostTaxSettings", "/v1/tax/settings", "update"} => "update",
    {"GetInvoiceitems", "/v1/invoiceitems", "list"} => "list",
    {"PostInvoiceitems", "/v1/invoiceitems", "create"} => "create",
    {"GetInvoiceitemsInvoiceitem", "/v1/invoiceitems/{invoiceitem}", "retrieve"} => "retrieve",
    {"PostInvoiceitemsInvoiceitem", "/v1/invoiceitems/{invoiceitem}", "update"} => "update",
    {"DeleteInvoiceitemsInvoiceitem", "/v1/invoiceitems/{invoiceitem}", "delete"} => "delete",
    {"GetClimateSuppliersSupplier", "/v1/climate/suppliers/{supplier}", "retrieve"} => "retrieve",
    {"GetClimateSuppliers", "/v1/climate/suppliers", "list"} => "list",
    {"GetIdentityVerificationReportsReport", "/v1/identity/verification_reports/{report}",
     "retrieve"} => "retrieve",
    {"GetIdentityVerificationReports", "/v1/identity/verification_reports", "list"} => "list",
    {"GetReportingReportRunsReportRun", "/v1/reporting/report_runs/{report_run}", "retrieve"} =>
      "retrieve",
    {"PostReportingReportRuns", "/v1/reporting/report_runs", "create"} => "create",
    {"GetReportingReportRuns", "/v1/reporting/report_runs", "list"} => "list",
    {"GetTestHelpersTestClocksTestClock", "/v1/test_helpers/test_clocks/{test_clock}", "retrieve"} =>
      "retrieve",
    {"PostTestHelpersTestClocks", "/v1/test_helpers/test_clocks", "create"} => "create",
    {"DeleteTestHelpersTestClocksTestClock", "/v1/test_helpers/test_clocks/{test_clock}",
     "delete"} => "delete",
    {"PostTestHelpersTestClocksTestClockAdvance",
     "/v1/test_helpers/test_clocks/{test_clock}/advance", "advance"} => "advance",
    {"GetTestHelpersTestClocks", "/v1/test_helpers/test_clocks", "list"} => "list",
    {"GetCustomersCustomerBalanceTransactionsTransaction",
     "/v1/customers/{customer}/balance_transactions/{transaction}", "retrieve"} => "retrieve",
    {"GetCustomersCustomerBalanceTransactions", "/v1/customers/{customer}/balance_transactions",
     "list"} => "list",
    {"PostCustomersCustomerBalanceTransactions", "/v1/customers/{customer}/balance_transactions",
     "create"} => "create",
    {"PostCustomersCustomerBalanceTransactionsTransaction",
     "/v1/customers/{customer}/balance_transactions/{transaction}", "update"} => "update",
    {"GetExchangeRates", "/v1/exchange_rates", "list"} => "list",
    {"GetExchangeRatesRateId", "/v1/exchange_rates/{rate_id}", "retrieve"} => "retrieve",
    {"DeleteCustomersCustomerSourcesId", "/v1/customers/{customer}/sources/{id}", "detach"} =>
      "detach",
    {"GetSourcesSource", "/v1/sources/{source}", "retrieve"} => "retrieve",
    {"PostSources", "/v1/sources", "create"} => "create",
    {"PostSourcesSource", "/v1/sources/{source}", "update"} => "update",
    {"PostSourcesSourceVerify", "/v1/sources/{source}/verify", "verify"} => "verify",
    {"GetSourcesSourceSourceTransactions", "/v1/sources/{source}/source_transactions",
     "source_transactions"} => "source_transactions",
    {"PostSetupIntents", "/v1/setup_intents", "create"} => "create",
    {"GetSetupIntents", "/v1/setup_intents", "list"} => "list",
    {"GetSetupIntentsIntent", "/v1/setup_intents/{intent}", "retrieve"} => "retrieve",
    {"PostSetupIntentsIntent", "/v1/setup_intents/{intent}", "update"} => "update",
    {"PostSetupIntentsIntentConfirm", "/v1/setup_intents/{intent}/confirm", "confirm"} =>
      "confirm",
    {"PostSetupIntentsIntentCancel", "/v1/setup_intents/{intent}/cancel", "cancel"} => "cancel",
    {"PostSetupIntentsIntentVerifyMicrodeposits",
     "/v1/setup_intents/{intent}/verify_microdeposits",
     "verify_microdeposits"} => "verify_microdeposits",
    {"GetIssuingDisputes", "/v1/issuing/disputes", "list"} => "list",
    {"PostIssuingDisputes", "/v1/issuing/disputes", "create"} => "create",
    {"PostIssuingDisputesDispute", "/v1/issuing/disputes/{dispute}", "update"} => "update",
    {"GetIssuingDisputesDispute", "/v1/issuing/disputes/{dispute}", "retrieve"} => "retrieve",
    {"PostIssuingDisputesDisputeSubmit", "/v1/issuing/disputes/{dispute}/submit", "submit"} =>
      "submit",
    {"GetFileLinksLink", "/v1/file_links/{link}", "retrieve"} => "retrieve",
    {"PostFileLinks", "/v1/file_links", "create"} => "create",
    {"PostFileLinksLink", "/v1/file_links/{link}", "update"} => "update",
    {"GetFileLinks", "/v1/file_links", "list"} => "list",
    {"PostEphemeralKeys", "/v1/ephemeral_keys", "create"} => "create",
    {"DeleteEphemeralKeysKey", "/v1/ephemeral_keys/{key}", "delete"} => "delete",
    {"PostApplicationFeesIdRefunds", "/v1/application_fees/{id}/refunds", "create"} => "create",
    {"GetApplicationFeesIdRefunds", "/v1/application_fees/{id}/refunds", "list"} => "list",
    {"GetApplicationFeesFeeRefundsId", "/v1/application_fees/{fee}/refunds/{id}", "retrieve"} =>
      "retrieve",
    {"PostApplicationFeesFeeRefundsId", "/v1/application_fees/{fee}/refunds/{id}", "update"} =>
      "update",
    {"GetBillingPortalConfigurations", "/v1/billing_portal/configurations", "list"} => "list",
    {"PostBillingPortalConfigurations", "/v1/billing_portal/configurations", "create"} =>
      "create",
    {"PostBillingPortalConfigurationsConfiguration",
     "/v1/billing_portal/configurations/{configuration}", "update"} => "update",
    {"GetBillingPortalConfigurationsConfiguration",
     "/v1/billing_portal/configurations/{configuration}", "retrieve"} => "retrieve",
    {"GetEvents", "/v1/events", "list"} => "list",
    {"GetEventsId", "/v1/events/{id}", "retrieve"} => "retrieve",
    {"PostCustomerSessions", "/v1/customer_sessions", "create"} => "create",
    {"GetIssuingCardholders", "/v1/issuing/cardholders", "list"} => "list",
    {"PostIssuingCardholders", "/v1/issuing/cardholders", "create"} => "create",
    {"GetIssuingCardholdersCardholder", "/v1/issuing/cardholders/{cardholder}", "retrieve"} =>
      "retrieve",
    {"PostIssuingCardholdersCardholder", "/v1/issuing/cardholders/{cardholder}", "update"} =>
      "update",
    {"GetCheckoutSessions", "/v1/checkout/sessions", "list"} => "list",
    {"GetCheckoutSessionsSession", "/v1/checkout/sessions/{session}", "retrieve"} => "retrieve",
    {"PostCheckoutSessions", "/v1/checkout/sessions", "create"} => "create",
    {"GetCheckoutSessionsSessionLineItems", "/v1/checkout/sessions/{session}/line_items",
     "list_line_items"} => "list_line_items",
    {"PostCheckoutSessionsSessionExpire", "/v1/checkout/sessions/{session}/expire", "expire"} =>
      "expire",
    {"GetSigmaScheduledQueryRuns", "/v1/sigma/scheduled_query_runs", "list"} => "list",
    {"GetSigmaScheduledQueryRunsScheduledQueryRun",
     "/v1/sigma/scheduled_query_runs/{scheduled_query_run}", "retrieve"} => "retrieve",
    {"PostTreasuryOutboundPayments", "/v1/treasury/outbound_payments", "create"} => "create",
    {"GetTreasuryOutboundPaymentsId", "/v1/treasury/outbound_payments/{id}", "retrieve"} =>
      "retrieve",
    {"GetTreasuryOutboundPayments", "/v1/treasury/outbound_payments", "list"} => "list",
    {"PostTreasuryOutboundPaymentsIdCancel", "/v1/treasury/outbound_payments/{id}/cancel",
     "cancel"} => "cancel",
    {"PostTestHelpersTreasuryOutboundPaymentsIdFail",
     "/v1/test_helpers/treasury/outbound_payments/{id}/fail", "fail"} => "fail",
    {"PostTestHelpersTreasuryOutboundPaymentsIdPost",
     "/v1/test_helpers/treasury/outbound_payments/{id}/post", "post"} => "post",
    {"PostTestHelpersTreasuryOutboundPaymentsIdReturn",
     "/v1/test_helpers/treasury/outbound_payments/{id}/return",
     "return_outbound_payment"} => "return_outbound_payment",
    {"GetFinancialConnectionsAccounts", "/v1/financial_connections/accounts", "list"} => "list",
    {"GetFinancialConnectionsAccountsAccount", "/v1/financial_connections/accounts/{account}",
     "retrieve"} => "retrieve",
    {"GetFinancialConnectionsAccountsAccountOwners",
     "/v1/financial_connections/accounts/{account}/owners", "list_owners"} => "list_owners",
    {"PostFinancialConnectionsAccountsAccountRefresh",
     "/v1/financial_connections/accounts/{account}/refresh", "refresh"} => "refresh",
    {"PostFinancialConnectionsAccountsAccountDisconnect",
     "/v1/financial_connections/accounts/{account}/disconnect", "disconnect"} => "disconnect",
    {"PostFinancialConnectionsAccountsAccountSubscribe",
     "/v1/financial_connections/accounts/{account}/subscribe", "subscribe"} => "subscribe",
    {"PostFinancialConnectionsAccountsAccountUnsubscribe",
     "/v1/financial_connections/accounts/{account}/unsubscribe", "unsubscribe"} => "unsubscribe",
    {"PostTreasuryDebitReversals", "/v1/treasury/debit_reversals", "create"} => "create",
    {"GetTreasuryDebitReversalsDebitReversal", "/v1/treasury/debit_reversals/{debit_reversal}",
     "retrieve"} => "retrieve",
    {"GetTreasuryDebitReversals", "/v1/treasury/debit_reversals", "list"} => "list",
    {"PostTransfers", "/v1/transfers", "create"} => "create",
    {"GetTransfers", "/v1/transfers", "list"} => "list",
    {"GetTransfersTransfer", "/v1/transfers/{transfer}", "retrieve"} => "retrieve",
    {"PostTransfersTransfer", "/v1/transfers/{transfer}", "update"} => "update",
    {"GetQuotesQuote", "/v1/quotes/{quote}", "retrieve"} => "retrieve",
    {"PostQuotes", "/v1/quotes", "create"} => "create",
    {"PostQuotesQuote", "/v1/quotes/{quote}", "update"} => "update",
    {"PostQuotesQuoteCancel", "/v1/quotes/{quote}/cancel", "cancel"} => "cancel",
    {"PostQuotesQuoteFinalize", "/v1/quotes/{quote}/finalize", "finalize_quote"} =>
      "finalize_quote",
    {"PostQuotesQuoteAccept", "/v1/quotes/{quote}/accept", "accept"} => "accept",
    {"GetQuotes", "/v1/quotes", "list"} => "list",
    {"GetQuotesQuoteLineItems", "/v1/quotes/{quote}/line_items", "list_line_items"} =>
      "list_line_items",
    {"GetQuotesQuoteComputedUpfrontLineItems", "/v1/quotes/{quote}/computed_upfront_line_items",
     "list_computed_upfront_line_items"} => "list_computed_upfront_line_items",
    {"GetQuotesQuotePdf", "/v1/quotes/{quote}/pdf", "pdf"} => "pdf",
    {"GetRadarEarlyFraudWarnings", "/v1/radar/early_fraud_warnings", "list"} => "list",
    {"GetRadarEarlyFraudWarningsEarlyFraudWarning",
     "/v1/radar/early_fraud_warnings/{early_fraud_warning}", "retrieve"} => "retrieve",
    {"GetTaxRates", "/v1/tax_rates", "list"} => "list",
    {"GetTaxRatesTaxRate", "/v1/tax_rates/{tax_rate}", "retrieve"} => "retrieve",
    {"PostTaxRates", "/v1/tax_rates", "create"} => "create",
    {"PostTaxRatesTaxRate", "/v1/tax_rates/{tax_rate}", "update"} => "update",
    {"GetPaymentMethodConfigurations", "/v1/payment_method_configurations", "list"} => "list",
    {"GetPaymentMethodConfigurationsConfiguration",
     "/v1/payment_method_configurations/{configuration}", "retrieve"} => "retrieve",
    {"PostPaymentMethodConfigurationsConfiguration",
     "/v1/payment_method_configurations/{configuration}", "update"} => "update",
    {"PostPaymentMethodConfigurations", "/v1/payment_method_configurations", "create"} =>
      "create",
    {"GetDisputes", "/v1/disputes", "list"} => "list",
    {"GetDisputesDispute", "/v1/disputes/{dispute}", "retrieve"} => "retrieve",
    {"PostDisputesDispute", "/v1/disputes/{dispute}", "update"} => "update",
    {"PostDisputesDisputeClose", "/v1/disputes/{dispute}/close", "close"} => "close",
    {"GetTaxCodes", "/v1/tax_codes", "list"} => "list",
    {"GetTaxCodesId", "/v1/tax_codes/{id}", "retrieve"} => "retrieve",
    {"GetTaxTransactionsTransaction", "/v1/tax/transactions/{transaction}", "retrieve"} =>
      "retrieve",
    {"PostTaxTransactionsCreateReversal", "/v1/tax/transactions/create_reversal",
     "create_reversal"} => "create_reversal",
    {"PostTaxTransactionsCreateFromCalculation", "/v1/tax/transactions/create_from_calculation",
     "create_from_calculation"} => "create_from_calculation",
    {"GetTaxTransactionsTransactionLineItems", "/v1/tax/transactions/{transaction}/line_items",
     "list_line_items"} => "list_line_items",
    {"GetSubscriptionsSearch", "/v1/subscriptions/search", "search"} => "search",
    {"GetSubscriptions", "/v1/subscriptions", "list"} => "list",
    {"PostSubscriptions", "/v1/subscriptions", "create"} => "create",
    {"PostSubscriptionsSubscriptionExposedId", "/v1/subscriptions/{subscription_exposed_id}",
     "update"} => "update",
    {"GetSubscriptionsSubscriptionExposedId", "/v1/subscriptions/{subscription_exposed_id}",
     "retrieve"} => "retrieve",
    {"DeleteSubscriptionsSubscriptionExposedId", "/v1/subscriptions/{subscription_exposed_id}",
     "cancel"} => "cancel",
    {"PostSubscriptionsSubscriptionResume", "/v1/subscriptions/{subscription}/resume", "resume"} =>
      "resume",
    {"DeleteSubscriptionsSubscriptionExposedIdDiscount",
     "/v1/subscriptions/{subscription_exposed_id}/discount",
     "delete_discount"} => "delete_discount",
    {"GetShippingRates", "/v1/shipping_rates", "list"} => "list",
    {"GetShippingRatesShippingRateToken", "/v1/shipping_rates/{shipping_rate_token}", "retrieve"} =>
      "retrieve",
    {"PostShippingRates", "/v1/shipping_rates", "create"} => "create",
    {"PostShippingRatesShippingRateToken", "/v1/shipping_rates/{shipping_rate_token}", "update"} =>
      "update",
    {"GetTreasuryReceivedDebits", "/v1/treasury/received_debits", "list"} => "list",
    {"GetTreasuryReceivedDebitsId", "/v1/treasury/received_debits/{id}", "retrieve"} =>
      "retrieve",
    {"PostTestHelpersTreasuryReceivedDebits", "/v1/test_helpers/treasury/received_debits",
     "create"} => "create",
    {"PostFinancialConnectionsSessions", "/v1/financial_connections/sessions", "create"} =>
      "create",
    {"GetFinancialConnectionsSessionsSession", "/v1/financial_connections/sessions/{session}",
     "retrieve"} => "retrieve",
    {"PostTreasuryInboundTransfersInboundTransferCancel",
     "/v1/treasury/inbound_transfers/{inbound_transfer}/cancel", "cancel"} => "cancel",
    {"PostTreasuryInboundTransfers", "/v1/treasury/inbound_transfers", "create"} => "create",
    {"GetTreasuryInboundTransfersId", "/v1/treasury/inbound_transfers/{id}", "retrieve"} =>
      "retrieve",
    {"GetTreasuryInboundTransfers", "/v1/treasury/inbound_transfers", "list"} => "list",
    {"PostTestHelpersTreasuryInboundTransfersIdSucceed",
     "/v1/test_helpers/treasury/inbound_transfers/{id}/succeed", "succeed"} => "succeed",
    {"PostTestHelpersTreasuryInboundTransfersIdFail",
     "/v1/test_helpers/treasury/inbound_transfers/{id}/fail", "fail"} => "fail",
    {"PostTestHelpersTreasuryInboundTransfersIdReturn",
     "/v1/test_helpers/treasury/inbound_transfers/{id}/return",
     "return_inbound_transfer"} => "return_inbound_transfer",
    {"GetMandatesMandate", "/v1/mandates/{mandate}", "retrieve"} => "retrieve",
    {"GetRadarValueListItems", "/v1/radar/value_list_items", "list"} => "list",
    {"GetRadarValueListItemsItem", "/v1/radar/value_list_items/{item}", "retrieve"} => "retrieve",
    {"PostRadarValueListItems", "/v1/radar/value_list_items", "create"} => "create",
    {"DeleteRadarValueListItemsItem", "/v1/radar/value_list_items/{item}", "delete"} => "delete",
    {"GetTreasuryReceivedCredits", "/v1/treasury/received_credits", "list"} => "list",
    {"GetTreasuryReceivedCreditsId", "/v1/treasury/received_credits/{id}", "retrieve"} =>
      "retrieve",
    {"PostTestHelpersTreasuryReceivedCredits", "/v1/test_helpers/treasury/received_credits",
     "create"} => "create",
    {"PostTreasuryOutboundTransfers", "/v1/treasury/outbound_transfers", "create"} => "create",
    {"GetTreasuryOutboundTransfersOutboundTransfer",
     "/v1/treasury/outbound_transfers/{outbound_transfer}", "retrieve"} => "retrieve",
    {"GetTreasuryOutboundTransfers", "/v1/treasury/outbound_transfers", "list"} => "list",
    {"PostTreasuryOutboundTransfersOutboundTransferCancel",
     "/v1/treasury/outbound_transfers/{outbound_transfer}/cancel", "cancel"} => "cancel",
    {"PostTestHelpersTreasuryOutboundTransfersOutboundTransferFail",
     "/v1/test_helpers/treasury/outbound_transfers/{outbound_transfer}/fail", "fail"} => "fail",
    {"PostTestHelpersTreasuryOutboundTransfersOutboundTransferPost",
     "/v1/test_helpers/treasury/outbound_transfers/{outbound_transfer}/post", "post"} => "post",
    {"PostTestHelpersTreasuryOutboundTransfersOutboundTransferReturn",
     "/v1/test_helpers/treasury/outbound_transfers/{outbound_transfer}/return",
     "return_outbound_transfer"} => "return_outbound_transfer",
    {"GetPayoutsPayout", "/v1/payouts/{payout}", "retrieve"} => "retrieve",
    {"GetPayouts", "/v1/payouts", "list"} => "list",
    {"PostPayouts", "/v1/payouts", "create"} => "create",
    {"PostPayoutsPayout", "/v1/payouts/{payout}", "update"} => "update",
    {"PostPayoutsPayoutCancel", "/v1/payouts/{payout}/cancel", "cancel"} => "cancel",
    {"PostPayoutsPayoutReverse", "/v1/payouts/{payout}/reverse", "reverse"} => "reverse",
    {"GetTreasuryTransactionEntriesId", "/v1/treasury/transaction_entries/{id}", "retrieve"} =>
      "retrieve",
    {"GetTreasuryTransactionEntries", "/v1/treasury/transaction_entries", "list"} => "list",
    {"PostCreditNotes", "/v1/credit_notes", "create"} => "create",
    {"GetCreditNotesPreview", "/v1/credit_notes/preview", "preview"} => "preview",
    {"GetCreditNotesId", "/v1/credit_notes/{id}", "retrieve"} => "retrieve",
    {"GetCreditNotes", "/v1/credit_notes", "list"} => "list",
    {"PostCreditNotesId", "/v1/credit_notes/{id}", "update"} => "update",
    {"PostCreditNotesIdVoid", "/v1/credit_notes/{id}/void", "void_credit_note"} =>
      "void_credit_note",
    {"GetCreditNotesPreviewLines", "/v1/credit_notes/preview/lines", "preview_lines"} =>
      "preview_lines",
    {"GetInvoicesInvoiceLines", "/v1/invoices/{invoice}/lines", "list"} => "list",
    {"PostInvoicesInvoiceLinesLineItemId", "/v1/invoices/{invoice}/lines/{line_item_id}",
     "update"} => "update",
    {"GetIssuingTransactions", "/v1/issuing/transactions", "list"} => "list",
    {"GetIssuingTransactionsTransaction", "/v1/issuing/transactions/{transaction}", "retrieve"} =>
      "retrieve",
    {"PostIssuingTransactionsTransaction", "/v1/issuing/transactions/{transaction}", "update"} =>
      "update",
    {"PostTestHelpersIssuingTransactionsCreateForceCapture",
     "/v1/test_helpers/issuing/transactions/create_force_capture",
     "create_force_capture"} => "create_force_capture",
    {"PostTestHelpersIssuingTransactionsCreateUnlinkedRefund",
     "/v1/test_helpers/issuing/transactions/create_unlinked_refund",
     "create_unlinked_refund"} => "create_unlinked_refund",
    {"PostTestHelpersIssuingTransactionsTransactionRefund",
     "/v1/test_helpers/issuing/transactions/{transaction}/refund", "refund"} => "refund",
    {"PostSubscriptionItemsSubscriptionItemUsageRecords",
     "/v1/subscription_items/{subscription_item}/usage_records", "create"} => "create",
    {"PostCustomersCustomerTaxIds", "/v1/customers/{customer}/tax_ids", "create"} => "create",
    {"GetCustomersCustomerTaxIdsId", "/v1/customers/{customer}/tax_ids/{id}", "retrieve"} =>
      "retrieve",
    {"GetCustomersCustomerTaxIds", "/v1/customers/{customer}/tax_ids", "list"} => "list",
    {"DeleteCustomersCustomerTaxIdsId", "/v1/customers/{customer}/tax_ids/{id}", "delete"} =>
      "delete",
    {"GetSubscriptionItemsSubscriptionItemUsageRecordSummaries",
     "/v1/subscription_items/{subscription_item}/usage_record_summaries", "list"} => "list",
    {"GetCountrySpecs", "/v1/country_specs", "list"} => "list",
    {"GetCountrySpecsCountry", "/v1/country_specs/{country}", "retrieve"} => "retrieve",
    {"GetAccountsAccountPersons", "/v1/accounts/{account}/persons", "list"} => "list",
    {"GetAccountsAccountPersonsPerson", "/v1/accounts/{account}/persons/{person}", "retrieve"} =>
      "retrieve",
    {"PostAccountsAccountPersons", "/v1/accounts/{account}/persons", "create"} => "create",
    {"PostAccountsAccountPersonsPerson", "/v1/accounts/{account}/persons/{person}", "update"} =>
      "update",
    {"DeleteAccountsAccountPersonsPerson", "/v1/accounts/{account}/persons/{person}", "delete"} =>
      "delete",
    {"PostBillingPortalSessions", "/v1/billing_portal/sessions", "create"} => "create",
    {"PostAccountSessions", "/v1/account_sessions", "create"} => "create",
    {"GetPlans", "/v1/plans", "list"} => "list",
    {"PostPlans", "/v1/plans", "create"} => "create",
    {"GetPlansPlan", "/v1/plans/{plan}", "retrieve"} => "retrieve",
    {"PostPlansPlan", "/v1/plans/{plan}", "update"} => "update",
    {"DeletePlansPlan", "/v1/plans/{plan}", "delete"} => "delete",
    {"PostCustomersCustomerSourcesId", "/v1/customers/{customer}/sources/{id}", "update_source"} =>
      "update_source",
    {"DeleteCustomersCustomerSourcesId", "/v1/customers/{customer}/sources/{id}", "delete_source"} =>
      "delete_source",
    {"PostAccountsAccountExternalAccountsId", "/v1/accounts/{account}/external_accounts/{id}",
     "update_external_account"} => "update_external_account",
    {"DeleteAccountsAccountExternalAccountsId", "/v1/accounts/{account}/external_accounts/{id}",
     "delete_external_account"} => "delete_external_account",
    {"GetRefunds", "/v1/refunds", "list"} => "list",
    {"GetRefundsRefund", "/v1/refunds/{refund}", "retrieve"} => "retrieve",
    {"GetAccount", "/v1/account", "show"} => "show",
    {"GetAccountsAccount", "/v1/accounts/{account}", "retrieve"} => "retrieve"
  }

  defp to_func_name(operation, stripe_extension) do
    # NOTE: Well, Operation ID suppose to be unique, but it's not. So, we need to use a tuple to make it unique.
    key = {operation.id, operation.path, stripe_extension["method_name"]}

    case Map.get(@operation_identity_mapping, key) do
      nil ->
        suggested_mapping = ~s(#{inspect(key)} => "#{stripe_extension["method_name"]}",\n)

        raise """
        Unregistered Operation

        - Stripe Extension: #{inspect(operation)}


        - Operation: #{inspect(operation)}

        - Suggested Mapping: "#{suggested_mapping}"
        """

      # TODO: Fallback to old mapping when the operation is not registered.
      # Waiting until I can successfully codegen newer versions of the spec.
      # stripe_extension["method_name"]

      name ->
        name
    end
  end
end
