defmodule SystemConfig.RegistryChannel do
  use SystemConfig.Web, :channel

  require Logger

  def join(_, payload, socket) do
    if authorized?(payload) do
      reply = SystemRegistry.match(:_)
      {:ok, reply, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("update", %{"scope" => scope, "value" => value}, socket) do
    global = SystemRegistry.match(:_)
    scope = atomize(scope, global) |> IO.inspect(label: "Atomized Scope")
    Logger.debug "Update Value: #{inspect scope} #{inspect value}"
    case SystemRegistry.update(scope, value, priority: :debug) do
      {:ok, val} ->
        Logger.debug "Val: #{inspect val}"
        {:reply, {:ok, SystemRegistry.match(:_)}, socket}
      {:error, error} -> {:reply, {:error, error}, socket}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp atomize(_, _, _ \\ [])
  defp atomize([], _, scope), do: Enum.reverse(scope)
  defp atomize([h | t], global, acc) do
    scope = Enum.reverse([h | acc])
    key =
      case get_in(global, scope) do
        nil -> String.to_existing_atom(h)
        _ -> h
      end
    atomize(t, global, [key | acc])
  end
end
