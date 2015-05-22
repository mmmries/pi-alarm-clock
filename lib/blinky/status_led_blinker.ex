defmodule Blinky.StatusLedBlinker do
  require Logger

  # Trigger file for LED0
  @led_trigger "/sys/class/leds/led0/trigger"

  # Brightness file for LED0
  @led_brightntess "/sys/class/leds/led0/brightness"

  def start(_type, _args) do
    setup_led
    # Start blinking forever
    blink_forever
  end

  def blink do
    Logger.debug "Status LED blink"
    set_led(true)
    :timer.sleep 1000
    set_led(false)
  end

  def blink_forever do
    blink
    :timer.sleep 1000
    blink_forever
  end

  # Setting the brightness to 1 in case of true and 0 if false
  def set_led(true), do: set_brightness("1")
  def set_led(false), do: set_brightness("0")

  def set_brightness(val) do
      File.write(@led_brightntess, val)
  end

  def setup_led, do: File.write(@led_trigger, "none")
end
