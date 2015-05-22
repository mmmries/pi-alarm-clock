Pi Alarm Clock
======

This is a little alarm clock application that I made so my 3yo son would know when it was time to come downstairs in the morning.

At 5am it turns on a red LED (indicating that it is time to stay in bed), then at 7am it turns on a green LED indicating that he can come downstairs to play.

## Setting Up The Pi

#### Wiring

I connected the red LED to pin 11 (gpio17) and the green LED to pin 15 (gpio22).

#### Install Erlang-mini

```
echo "deb http://packages.erlang-solutions.com/debian wheezy contrib\n" >> /etc/apt/sources.list
wget http://packages.erlang-solutions.com/debian/erlang_solutions.asc
sudo apt-key add erlang_solutions.asc && rm erlang_solutions.asc
sudo apt-get update
sudo apt-get install -y erlang-mini
```

#### Install Precompiled Elixir

```
mkdir elixir-1.0.4
curl https://github.com/elixir-lang/elixir/releases/download/v1.0.4/Precompiled.zip -o elixir-1.0.4/precompiled.zip
cd elixir-1.0.4
unzip precompiled.zip
echo 'export PATH=/home/pi/elixir-1.0.4/bin:$PATH' >> /etc/bash.bashrc
```

#### Set Hostname

```
echo 'pi1' > /etc/hostname
```

#### Checkout Project And Boot

```
git clone git@github.com:mmmries/pi-alarm-clock.git
cd pi-alarm-clock
mix local.hex
mix deps.get
mix compile
elixir --detached --sname pi1 --cookie pi S mix alarm_clock
```

## Connecting Remotely

If you want to checkout what is going on inside the erlang node running on your pi you can connect to it remotely using a command like

```
iex --sname laptop --cookie pi --remsh pi1@pi1
```

__Note__: Make sure you use the same cookie as you used when booting the application on the pi and make sure your computer knows how to resolve the address of the pi
