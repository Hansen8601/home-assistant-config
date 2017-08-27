# Home Assistant Config Files

This is my home assistant configuration and documentation on how I created my development and live setup, just in case it's useful to others or if I need to rebuild.

Thanks to all the great developers and supporters involved in the home assistant project. This is an amazing community.

## Devices

- Several apple devices (iphones, ipads, apple TVs)
- Smarthings Hub
- Raspberry Pi running [Home Assistant](https://home-assistant.io/) and using gpio
- [GE Z-Wave Wireless Smart Lighting Control](https://www.amazon.com/gp/product/B006LQFHN2/ref=oh_aui_detailpage_o00_s00?ie=UTF8&psc=1)
- ecobee 3 smart thermostat
- Denon AVR 3000 receiver
- Harmony Hub

## Screenshots

![Home](https://github.com/Hansen8601/home-assistant-config/raw/master/images/screen1.PNG)
![Rooms](https://github.com/Hansen8601/home-assistant-config/raw/master/images/screen2.PNG)
![Media](https://github.com/Hansen8601/home-assistant-config/raw/master/images/screen3.PNG)
![Climate](https://github.com/Hansen8601/home-assistant-config/raw/master/images/screen4.PNG)

## My Test & Development Server Setup

I have a virtual linux server used for testing and development. All config changes are done there and then pushed to to Raspberry Pi when ready through github. The server has two virtual environments, a test and development environment.

/home/phil/hass-dev/ (put in my /home/phil directory to avoid permission errors)
/home/phil/hass-test/

Activate the venv using the command below, and always do this before running HASS.

``` source /home/phil/hass-test/bin/activate ```

### Test Environment

#### Upgrading
```
source /home/phil/hass-test/bin/activate 
pip3 install --upgrade homeassistant
```

### Development Environment

#### setup
```
git clone https://github.com/hansen8601/home-assistant.git
cd home-assistant
git remote add upstream https://github.com/home-assistant/home-assistant.git
script/setup
pip install --upgrade setuptools
```

#### Update to latest home assistant code
```
git fetch upstream dev  # to pull the latest changes into a local dev branch
git rebase upstream/dev # to put those changes into your feature branch before your changes
```

## Raspberry Pi HASS

Installed 10/8/2016 with Hassbian image from the home assistant website. The address is http://192.168.1.x:8123. 

The following extras are included on the image:
GPIO pins are ready to use.
Mosquitto MQTT broker is installed (not activated by default).
Bluetooth is ready to use (supported models only, no Bluetooth LE).

The Home Assistant configuration is located at /home/homeassistant/.homeassistant/. 
Home Assistant is installed in a virtual Python environment at srv/homeassistant
Home Assistant will be started as a service run by the user homeassistant


## My Raspberry Pi HASS Setup Process

#### Installed Hassbian image

#### Installed NPM for the SmartThings bridge

directions from https://www.losant.com/blog/how-to-install-nodejs-on-raspberry-pi

```
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash;
nvm install v6.9.2; #was 5.7.0
nvm alias default v6.9.2;
```

#### Installed smartthings-mqtt-bridge

smarthings configuration files are in /home/pi/

```
npm install -g smartthings-mqtt-bridge
```

#### Installed pm2 process manager
directions from http://pm2.keymetrics.io/docs/usage/quick-start/
```
npm install pm2@latest -g;
pm2 start smartthings-mqtt-bridge;
pm2 startup;
```

Some useful pm2 commands
```
List:		pm2 list
Logs:		pm2 logs smartthings-mqtt-bridge
Restart:	pm2 restart smartthings-mqtt-bridge
```

#### Install Harmony Hub Control
Harmony hub control was done via command line switches before this was integrated into HASS.  This is no longer being used, and now is integrated into HASS. I had to copy HarmonyHub.AuthorizationToken to / to get it working in hass. Haven't went  back and tested if this has changed in recent updates.

https://github.com/NovaGL/HarmonyHubControl
https://community.home-assistant.io/t/harmony-hub/978/68

```
git clone https://github.com/NovaGL/HarmonyHubControl.git
Make
```

#### Mosquitto mqtt broker

Mosquitto mqtt broker was pre-installed, but not set to auto-start. Enabled mosquitto to autostart
```
sudo systemctl enable mosquitto
sudo systemctl start mosquitto
```

#### Installed HomeBridge 

Directions from https://github.com/nfarina/homebridge/wiki/Running-HomeBridge-on-a-Raspberry-Pi

```
sudo apt-get install -y nodejs;
sudo apt-get install libavahi-compat-libdnssd-dev --assume-yes;
sudo npm install -g --unsafe-perm homebridge hap-nodejs node-gyp;
cd /usr/lib/node_modules/homebridge/;
sudo npm install --unsafe-perm bignum;
cd /usr/lib/node_modules/hap-nodejs/node_modules/mdns;
sudo node-gyp BUILDTYPE=Release rebuild;
sudo npm install -g homebridge-homeassistant;
sudo useradd -rm homebridge;
sudo mkdir /var/homebridge;
cd /var;
sudo chown homebridge:homebridge homebridge;
```

Create 3 files to setup autostart:
```
sudo vi /etc/default/homebridge
sudo vi /etc/systemd/system/homebridge.service
sudo vi /var/homebridge/config.json
```

Then to start homebridge:
```
sudo systemctl daemon-reload;
sudo systemctl enable homebridge;
sudo systemctl start homebridge;
tail -F /var/log/syslog;
```

You can check the status of the homebridge service by calling
```
systemctl status homebridge
```

### Using HASS on the Raspberry Pi

```
sudo systemctl restart home-assistant@homeassistant.service
```

### Upgrading HASS on the Raspberry Pi
```
sudo systemctl stop home-assistant@homeassistant.service;
sudo su -s /bin/bash homeassistant;
source /srv/homeassistant/bin/activate;
pip3 install --upgrade homeassistant;
exit;
sudo systemctl start home-assistant@homeassistant.service;
tail -f /var/log/syslog;
```

### Validating your configuration on the Raspberry Pi
```
Check your configuration on Hassbian
sudo su -s /bin/bash homeassistant
source /srv/homeassistant/bin/activate
hass --script check_config
```


