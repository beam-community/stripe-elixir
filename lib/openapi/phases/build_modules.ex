defmodule Stripe.OpenApi.Phases.BuildModules do
  @method_name_overrides %{
    ["Account"] => %{
      {"retrieve", "/v1/account"} => "show",
      {"retrieve", "/v1/accounts/{account}"} => "retrieve"
    },
    ["BankAccount"] => %{
      {"delete", "/v1/customers/{customer}/sources/{id}"} => "delete_source",
      {"delete", "/v1/accounts/{account}/external_accounts/{id}"} => "delete_external_account",
      {"update", "/v1/customers/{customer}/sources/{id}"} => "update_source",
      {"update", "/v1/accounts/{account}/external_accounts/{id}"} => "update_external_account"
    },
    ["Card"] => %{
      {"delete", "/v1/customers/{customer}/sources/{id}"} => "delete_source",
      {"delete", "/v1/accounts/{account}/external_accounts/{id}"} => "delete_external_account",
      {"update", "/v1/customers/{customer}/sources/{id}"} => "update_source",
      {"update", "/v1/accounts/{account}/external_accounts/{id}"} => "update_external_account"
    }
  }

  @moduledoc false
  def run(blueprint, _options \\ []) do
    components =
      for {name, map} <- blueprint.source["components"]["schemas"],
          map["x-resourceId"] != nil || name == "api_errors",
          into: %{} do
        resource =
          (map["x-resourceId"] || name) |> String.split(".") |> Enum.map(&Macro.camelize/1)

        {name,
         %OpenApiGen.Blueprint.Schema{
           name: name,
           description: map["description"],
           operations:
             (map["x-stripeOperations"] || [])
             |> Enum.reject(&(&1["method_on"] == "collection"))
             |> Enum.map(&%{&1 | "method_name" => method_name(&1, resource)}),
           module: Module.concat(["Stripe" | resource]),
           properties: map["properties"] || %{},
           expandable_fields:
             Map.get(map, "x-expandableFields", []) |> Enum.map(&String.to_atom/1)
         }}
      end

    {:ok, %{blueprint | components: components}}
  end

  defp method_name(op, resource) do
    case @method_name_overrides[resource][{op["method_name"], op["path"]}] do
      nil -> Macro.underscore(op["method_name"])
      value -> value
    end
  end
end
