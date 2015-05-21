defmodule Blinky.Gpio do
  use GenServer

  @export "/sys/class/gpio/export"
  @unexport "/sys/class/gpio/unexport"

  def start_link(pin_number) do
    GenServer.start_link(__MODULE__, pin_number)
  end

  ## GenServer callbacks

  def init(pin_number) when is_number(pin_number) do
    case File.write(@export, pin_number |> Integer.to_string) do
      {:error, err} -> {:stop, err}
      :ok ->
        case File.write(pin_direction_path(pin_number), "out") do
          {:error, err} -> {:stop, err}
          :ok -> {:ok, pin_number}
        end
    end
  end

  def handle_call(:on, _from, pin_number) do
    {:reply, File.write(pin_value_path(pin_number), "1"), pin_number}
  end

  def handle_call(:off, _from, pin_number) do
    {:reply, File.write(pin_value_path(pin_number), "0"), pin_number}
  end

  def terminate(_reason, pin_number) do
    File.write(@unexport, pin_number)
    :ok
  end

  ## Private API

  defp pin_direction_path(pin_number), do: "/sys/class/gpio/gpio#{pin_number}/direction"
  defp pin_value_path(pin_number), do: "/sys/class/gpio/gpio#{pin_number}/value"
end
