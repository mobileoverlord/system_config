defmodule SystemConfig.Processor.ConfigMeta do
  use SystemRegistry.Processor

  @mount "config"

  require Logger
  alias SystemRegistry.Transaction
  import SystemRegistry.Processor.Utils

  def init(opts) do
    Logger.debug "Init Meta Processor"
    mount = opts[:mount] || @mount

    {:ok, %{
      opts: opts
    }}
  end

  def handle_validate(%Transaction{} = _t, s) do
    {:ok, :ok, s}
  end

  def handle_commit(%Transaction{} = t, s) do

    {:ok, :ok, s}
  end
end
