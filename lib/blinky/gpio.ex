defmodule Blinky.Gpio do
  use GenServer

  @export "/sys/class/gpio/export"
  @unexport "/sys/class/gpio/unexport"

  ## Public Interface

  def start_link(pin_number, opts \\ []) do
    GenServer.start_link(__MODULE__, pin_number, opts)
  end

  def turn_on(pid), do: GenServer.call(pid, :on)
  def turn_off(pid), do: GenServer.call(pid, :off)

  def stop(pid), do: GenServer.cast(pid, :stop)

  ## GenServer callbacks

  def init(pin_number) when is_number(pin_number) do
    case write(@export, pin_number |> Integer.to_string) do
      {:error, err} -> {:stop, err}
      :ok ->
        case write(pin_direction_path(pin_number), "out") do
          {:error, err} -> {:stop, err}
          :ok -> {:ok, pin_number}
        end
    end
  end

  def handle_call(:on, _from, pin_number) do
    {:reply, write(pin_value_path(pin_number), "1"), pin_number}
  end
  def handle_call(:off, _from, pin_number) do
    {:reply, write(pin_value_path(pin_number), "0"), pin_number}
  end

  def handle_cast(:stop, pin_number) do
    {:stop, :normal, pin_number}
  end

  def terminate(_reason, pin_number) do
    write(@unexport, pin_number)
    :ok
  end

  ## Private API

  defp pin_direction_path(pin_number), do: "/sys/class/gpio/gpio#{pin_number}/direction"
  defp pin_value_path(pin_number), do: "/sys/class/gpio/gpio#{pin_number}/value"
  defp write(path, data) do
    case Mix.env do
      :prod -> File.write(path, data)
      _ -> :ok
    end
  end
end
