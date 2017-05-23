defmodule SystemConfig.SystemRegistry do
  use GenServer

  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_opts) do
    SystemRegistry.register()
    {:ok, %{}}
  end

  def handle_info({:system_registry, :global, global}, s) do
    Logger.debug "SystemRegistry Global: #{inspect global}"
    SystemConfig.Endpoint.broadcast("registry", "global", global)
    {:noreply, s}
  end
end
