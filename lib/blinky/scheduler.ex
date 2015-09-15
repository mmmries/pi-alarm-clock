defmodule Blinky.Scheduler do
  require Logger
  use GenServer

  ## Public Interface

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def blink(pid), do: GenServer.cast(pid, :blink)

  def time_to_state(time) do
    cond do
      time in keep_sleeping_range -> :keep_sleeping
      time in time_to_wakeup_range -> :time_to_wakeup
      true -> :idle
    end
  end

  ## GenServer callbacks
  @interval 10_000

  def init(nil) do
    {:ok, nil, @interval}
  end

  def handle_cast(:blink, _state) do
    Blinky.Gpio.turn_on(:keep_sleeping)
    Blinky.Gpio.turn_on(:time_to_wakeup)
    :timer.sleep(1000)
    Blinky.Gpio.turn_off(:keep_sleeping)
    Blinky.Gpio.turn_off(:time_to_wakeup)
    {:noreply, nil, @interval}
  end

  def handle_info(:timeout, current_state) do
    expected_state = time_to_state(:erlang.time())
    cond do
      expected_state == current_state ->
        {:noreply, current_state, @interval}
      true ->
        Logger.debug "setting LEDs to #{expected_state}"
        set_leds(expected_state)
        {:noreply, expected_state, @interval}
    end
  end

  ## Private Interface

  defp set_leds(:keep_sleeping) do
    Blinky.Gpio.turn_on(:keep_sleeping)
    Blinky.Gpio.turn_off(:time_to_wakeup)
  end
  defp set_leds(:time_to_wakeup) do
    Blinky.Gpio.turn_off(:keep_sleeping)
    Blinky.Gpio.turn_on(:time_to_wakeup)
  end
  defp set_leds(:idle) do
    Blinky.Gpio.turn_off(:keep_sleeping)
    Blinky.Gpio.turn_off(:time_to_wakeup)
  end

  defp keep_sleeping_range do
    Application.get_env(Blinky, :keep_sleeping_range, Range.new({5,30,0},{7,14,59}))
  end

  defp time_to_wakeup_range do
    Application.get_env(Blinky, :time_to_wakeup_range, Range.new({7,15,0},{8,29,59}))
  end
end
