defmodule Blinky.SchedulerTest do
  use ExUnit.Case, async: true

  test "it knows when it is time keep sleeping" do
    assert :keep_sleeping == Blinky.Scheduler.time_to_state({5,30,0})
    assert :keep_sleeping == Blinky.Scheduler.time_to_state({6,0,0})
    assert :keep_sleeping == Blinky.Scheduler.time_to_state({7,0,0})
  end

  test "it knows when it is time to wakeup" do
    assert :time_to_wakeup == Blinky.Scheduler.time_to_state({7,15,1})
    assert :time_to_wakeup == Blinky.Scheduler.time_to_state({7,20,0})
    assert :time_to_wakeup == Blinky.Scheduler.time_to_state({8,0,0})
  end

  test "it knows when it is idle time" do
    assert :idle == Blinky.Scheduler.time_to_state({8,31,0})
    assert :idle == Blinky.Scheduler.time_to_state({13,0,0})
    assert :idle == Blinky.Scheduler.time_to_state({22,0,0})
  end
end
