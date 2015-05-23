defmodule Blinky do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Blinky.Gpio, [17, [name: :keep_sleeping]], id: :keep_sleeping),
      worker(Blinky.Gpio, [22, [name: :time_to_wakeup]], id: :time_to_wakeup),
      worker(Blinky.StatusLedBlinker, []),
      worker(Blinky.Scheduler, [:idle, [name: :scheduler]]),
    ]

    opts = [strategy: :one_for_one, name: Blinky.Supervisor]

    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    :ok
  end
end
