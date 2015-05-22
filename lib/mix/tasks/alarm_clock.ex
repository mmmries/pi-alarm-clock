defmodule Mix.Tasks.AlarmClock do
  use Mix.Task

  @keep_sleeping_pin 17
  @time_to_wakeup_pin 22

  @shortdoc "run the alarm clock program"

  def run(_) do
    keep_sleeping_pid = Blinky.Gpio.start_link(@keep_sleeping_pin)
    time_to_wakeup_pid = Blinky.Gpio.start_link(@time_to_wakeup_pin)
    loop(keep_sleeping_pid, time_to_wakeup_pid)
  end

  defp loop(keep_sleeping_pid, time_to_wakeup_pid) do
    case time_zone do
      :keep_sleeping ->
        Blinky.Gpio.turn_off(time_to_wakeup_pid)
        Blinky.Gpio.turn_on(keep_sleeping_pid)
      :time_to_wakeup ->
        Blinky.Gpio.turn_on(time_to_wakeup_pid)
        Blinky.Gpio.turn_off(keep_sleeping_pid)
      :idle ->
        Blinky.Gpio.turn_off(time_to_wakeup_pid)
        Blinky.Gpio.turn_off(keep_sleeping_pid)
    end
    :timer.sleep(30_000)
    loop(keep_sleeping_pid, time_to_wakeup_pid)
  end

  defp time_zone, do: time_zone(:erlang.time())
  defp time_zone({hr,_min,_sec}) when hr >= 5 and hr <= 6, do: :keep_sleeping
  defp time_zone({hr,_min,_sec}) when hr >= 7 and hr <= 9, do: :time_to_wakeup
  defp time_zone({_hr,_min,_sec}), do: :idle
end
