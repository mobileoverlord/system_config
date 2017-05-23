defmodule SystemConfig.RegistryChannel do
  use SystemConfig.Web, :channel

  def join(_, payload, socket) do
    if authorized?(payload) do
      reply = SystemRegistry.match(:_)
      {:ok, reply, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
