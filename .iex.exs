defmodule R do
  def test do
    value = %{
      a: 1,
      b: [1, 2],
      c: "3",
      d: %{
        e: "f"
      }
    }
    SystemRegistry.update([:state], value)
  end

  def up(link) do
    value = %{
      address: "192.168.1.100",
      subnet: "255.255.255.0",
      router: "192.168.1.1",
      dns: ["8.8.8.8", "8.8.4.4"]}
    state_scope(link)
    |> SystemRegistry.update(value)

    value = %{
      address: "192.168.1.100",
      subnet: "255.255.255.0",
      router: "192.168.1.1",
      dns: ["8.8.8.8", "8.8.4.4"]}
    config_scope(link)
    |> SystemRegistry.update(value, priority: :default)
  end

  def down(link) do
    state_scope(link)
    |> SystemRegistry.delete()
    config_scope(link)
    |> SystemRegistry.delete()
  end

  def mod(link, key, value) do
    SystemRegistry.update(state_scope(link) ++ [key], value)
  end

  defp state_scope(link), do: [:state, :network_interface, link]
  defp config_scope(link), do: [:config, :network_interface, link]
end
