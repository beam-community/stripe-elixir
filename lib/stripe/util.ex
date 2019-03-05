defmodule Stripe.Util do
  @moduledoc false

  @doc """
  Performs a root-level conversion of map keys from strings to atoms.

  This function performs the transformation safely using `String.to_existing_atom/1`, but this has a possibility to raise if
  there is not a corresponding atom.

  It is recommended that you pre-filter maps for known values before
  calling this function.

  ## Examples

  iex> map = %{
  ...>   "a"=> %{
  ...>     "b" => %{
  ...>       "c" => 1
  ...>     }
  ...>   }
  ...> }
  iex> Stripe.Util.map_keys_to_atoms(map)
  %{
    a: %{
      "b" => %{
        "c" => 1
      }
    }
  }
  """
  def map_keys_to_atoms(m) do
    Enum.into(m, %{}, fn
      {k, v} when is_binary(k) ->
        a = String.to_existing_atom(k)
        {a, v}

      entry ->
        entry
    end)
  end

  def atomize_keys(map = %{}) do
    Enum.into(map, %{}, fn {k, v} -> {atomize_key(k), atomize_keys(v)} end)
  end

  def atomize_keys([head | rest]), do: [atomize_keys(head) | atomize_keys(rest)]
  # Default
  def atomize_keys(not_a_map), do: not_a_map

  def atomize_key(k) when is_binary(k), do: String.to_atom(k)
  def atomize_key(k), do: k

  @spec object_name_to_module(String.t()) :: module
  def object_name_to_module("checkout.session"), do: Stripe.Session
  def object_name_to_module("file"), do: Stripe.FileUpload

  def object_name_to_module(object_name) do
    module_name =
      object_name
      |> String.split("_")
      |> Enum.map_join("", &String.capitalize/1)

    Module.concat(Stripe, module_name)
  end

  @spec module_to_string(module) :: String.t()
  def module_to_string(module) do
    module |> Atom.to_string() |> String.trim_leading("Elixir.")
  end

  def multipart_key(:file), do: :file
  def multipart_key(key) when is_atom(key), do: Atom.to_string(key)
  def multipart_key(key), do: key

  def normalize_id(%{id: id}) when id !== nil, do: id
  def normalize_id(id) when is_binary(id), do: id

  defmacro log_deprecation(msg \\ "") do
    if Mix.env() in [:test, :dev] do
      {fun, arity} = __CALLER__.function
      mod = __CALLER__.module

      quote bind_quoted: [mod: mod, fun: fun, arity: arity, msg: msg] do
        require Logger
        Logger.warn("[DEPRECATION] The function #{mod}.#{fun}/#{arity} is deprecated. #{msg}")
      end
    end
  end
end
