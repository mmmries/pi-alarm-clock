Pi Alarm Clock
======

This is a little alarm clock application that I made so my 3yo son would know when it was time to come downstairs in the morning.

At 5am it turns on a red LED (indicating that it is time to stay in bed), then at 7am it turns on a green LED indicating that he can come downstairs to play.

## Setting Up The Pi

From vanilla Raspbian (2015-05-15) use a wired ethernet (or USB ethernet) connection and boot the pi.

SSH into the pi with the default credentials:

`username: pi`
`password: raspberry`

Now run `sudo raspi-config` and make the following changes.

* Expand the file system to use the whole MicroSD Card
* Change the default user password (optional)
* Change the default locale to en-US UTF-8 UTF-8
* Change the timezone to America/Denver
* Change the keyboard layout to a US layout
* Change the hostname to pi1

#### Configure WiFi


This setup is based on [these WiFi Settings](http://www.andreagrandi.it/2014/09/02/how-to-configure-edimax-ew-7811un-wifi-dongle-on-raspbian/).

* `nano /etc/network/interfaces`

```
auto lo
iface lo inet loopback

auto eth0
allow-hotplug eth0
iface eth0 inet manual

allow-hotplug wlan0
auto wlan0

iface wlan0 inet dhcp
wpa-ssid YOURESSID
wpa-psk YOURWPAPASSWORD
```

* `echo 'options 8192cu rtw_power_mgnt=0 rtw_enusbss=0' > /etc/modprobe.d/8192cu.conf`


#### Wiring

I connected the red LED to pin 11 (gpio17) and the green LED to pin 15 (gpio22).

#### Install Erlang-mini

```
echo "deb http://packages.erlang-solutions.com/debian wheezy contrib" >> /etc/apt/sources.list
wget http://packages.erlang-solutions.com/debian/erlang_solutions.asc
sudo apt-key add erlang_solutions.asc && rm erlang_solutions.asc
sudo apt-get update
apt-get install -y --force-yes erlang-mini upstart htop
# You will have to confirm the switch to upstart by typing 'Yes, do as I say!'
```

#### Install Precompiled Elixir

```
mkdir /opt/elixir-1.0.4
curl  -L https://github.com/elixir-lang/elixir/releases/download/v1.0.4/Precompiled.zip -o /opt/elixir-1.0.4/precompiled.zip
cd /opt/elixir-1.0.4
unzip precompiled.zip
echo 'export PATH=/opt/elixir-1.0.4/bin:$PATH' >> /etc/bash.bashrc
```

#### Checkout Project And Boot

```
# do this as root so we have access to the gpio pins
git clone git@github.com:mmmries/pi-alarm-clock.git /opt/pi-alarm-clock
cd /opt/pi-alarm-clock
mix local.hex
mix deps.get
MIX_ENV=prod mix compile
MIX_ENV=prod elixir --detached --sname blinky --cookie pi --no-halt -S mix run
```

To stop the project open a remote shell and execute:

```elixir
Application.stop(:blinky)
init:stop()
```

Or from a local iex session (with the same cookie) run:

```elixir
:rpc.call(:pi@pi1, Application, :stop, [:blinky])
:rpc.call(:pi1@pi1, :init, :stop, [])
```

## Connecting Remotely

If you want to checkout what is going on inside the erlang node running on your pi you can connect to it remotely using a command like

```
iex --cookie pi --remsh blinky@pi1
```

__Note__: Make sure you use the same cookie as you used when booting the application on the pi and make sure your computer knows how to resolve the address of the pi

## Checking On The Alarm

The easiest way to check if the alarm clock is still running is to look at the status LED (green LED on the pi). If the application is running it will be blinking the green LED on/off every 1 second as a heartbeat.

Our application also sends all logs via UDP multicast in `prod` and `dev`. So you can run `ruby listen.rb` to listen for those log messages and see what your alarm is telling you.
