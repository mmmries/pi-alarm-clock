defmodule Blinky.Gpio do
  require Logger
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
    case write_ignore_ebusy(@export, "#{pin_number}") do
      {:error, err} -> {:stop, err}
      :ok ->
        case write_ignore_ebusy(pin_direction_path(pin_number), "out") do
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
    Logger.debug "stopping GPIO for #{pin_number}"
    {:stop, :normal, pin_number}
  end

  def terminate(_reason, pin_number) do
    Logger.debug "terminating GPIO for #{pin_number}"
    result = write(@unexport, "#{pin_number}")
    Logger.debug "unexport #{pin_number} :: #{result}"
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

  # if the pins have already been initialized (or weren't cleaned up properly)
  # then we get back an {:error, :ebusy}, that is okay for our purposes because
  # it just means we don't need to re-initialize the pin
  defp write_ignore_ebusy(path, data) do
    case write(path, data) do
      {:error, :ebusy} -> :ok
      :ok -> :ok
      {:error, err} -> {:error, err}
    end
  end
end
