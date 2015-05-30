defmodule Blinky.Scheduler do
  require Logger
  use GenServer

  ## Public Interface

  def start_link(initial_state, opts \\ []) do
    GenServer.start_link(__MODULE__, initial_state, opts)
  end

  def blink(pid), do: GenServer.cast(pid, :blink)

  ## GenServer callbacks
  @interval 10_000

  def init(state) when state in [:idle, :keep_sleeping, :time_to_wakeup] do
    {:ok, state, @interval}
  end

  def handle_cast(:blink, state) do
    Blinky.Gpio.turn_on(:keep_sleeping)
    Blinky.Gpio.turn_on(:time_to_wakeup)
    :timer.sleep(1000)
    Blinky.Gpio.turn_off(:keep_sleeping)
    Blinky.Gpio.turn_off(:time_to_wakeup)
  end

  def handle_info(:timeout, :idle) do
    case between?(5,6) do
    true ->
      Logger.debug "SCH idle -> keep_sleeping"
      Blinky.Gpio.turn_on(:keep_sleeping)
      {:noreply, :keep_sleeping, @interval}
    false ->
      {:noreply, :idle, @interval}
    end
  end
  def handle_info(:timeout, :keep_sleeping) do
    case between?(5,6) do
    true ->
      {:noreply, :keep_sleeping, @interval}
    false ->
      Logger.debug "SCH keep_sleeping -> time_to_wakeup"
      Blinky.Gpio.turn_off(:keep_sleeping)
      Blinky.Gpio.turn_on(:time_to_wakeup)
      {:noreply, :time_to_wakeup, @interval}
    end
  end
  def handle_info(:timeout, :time_to_wakeup) do
    case between?(7,8) do
    true ->
      {:noreply, :time_to_wakeup, @interval}
    false ->
      Logger.debug "SCH time_to_wakeup -> keep_sleeping"
      Blinky.Gpio.turn_off(:time_to_wakeup)
      {:noreply, :idle, @interval}
    end
  end

  ## Private Interface

  defp between?(min, max) do
    {h, _m, _s} = :erlang.time()
    h >= min && h <= max
  end
end
