defmodule R do
  def up(link) do
    value = %{
      address: "192.168.1.100",
      subnet: "255.255.255.0",
      router: "192.168.1.1",
      dns: ["8.8.8.8", "8.8.4.4"]}
    scope(link)
    |> SystemRegistry.update(value)
  end

  def down(link) do
    scope(link)
    |> SystemRegistry.delete()
  end

  def mod(link, key, value) do
    SystemRegistry.update(scope(link) ++ [key], value)
  end

  defp scope(link), do: [:state, :network_interface, link]
end
