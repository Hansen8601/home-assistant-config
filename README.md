# Home Assistant Config Files

This is my home assistant configuration and documentation on how I created my test/development server and live docker setup, just in case it's useful to others or if I need to rebuild.

Thanks to all the great developers and supporters involved in the home assistant project. This is an amazing community.

## Devices

- Docker running on a ubuntu Hyper-V virtual machine running
  - [Home Assistant](https://home-assistant.io/)
  - Mosca MQTT
  - SmarthThings Bridge
  - HomeBridge
- Several apple devices (iphones, ipads, apple TVs)
- Smarthings Hub
- Raspberry Pi [pi-mqtt-gpio](https://github.com/Hansen8601/pi-mqtt-gpio1-config) for garage door control
- esp8266 fireplace controller
- - [GE Z-Wave Wireless Smart Lighting Control](https://www.amazon.com/gp/product/B006LQFHN2/ref=oh_aui_detailpage_o00_s00?ie=UTF8&psc=1)
- two ecobee 3 smart thermostats
- Denon AVR 3000 receiver
- Harmony Hub

## Screenshots

![Home](https://github.com/Hansen8601/home-assistant-config/raw/master/images/screen1.PNG)
![Rooms](https://github.com/Hansen8601/home-assistant-config/raw/master/images/screen2.PNG)
![Media](https://github.com/Hansen8601/home-assistant-config/raw/master/images/screen3.PNG)
![Climate](https://github.com/Hansen8601/home-assistant-config/raw/master/images/screen4.PNG)

## My Test & Development Server Setup

I have a virtual linux server used for testing and development. Config changes can be done there and then pushed to production via github, or done dirctly on the production server and then backed up to github.

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

## Docker HASS

Moved from a Raspberry Pi to docker running on a virtual Ubuntu server on 12/27/2017.

The files are located in /opt/docker-compose-projects/home-assistant


## My Setup

#### Docker Compose File


```
version: '2'
services:
  mqtt:
      image: matteocollina/mosca
      volumes:
          - /opt/docker-compose-projects/home-assistant/mosca:/config
      ports:
          - 1883:1883
      restart: unless-stopped

  mqttbridge:
      image: stjohnjohnson/smartthings-mqtt-bridge:latest
      depends_on:
          - mqtt
      volumes:
          - /opt/docker-compose-projects/home-assistant/mqtt-bridge:/config
      ports:
          - 8080:8080
      depends_on:
          - mqtt
      restart: unless-stopped

  homeassistant:
      image: homeassistant/home-assistant:latest
      ports:
          - 192.168.1.22:80:80
          - 192.168.1.22:8123:8123
      volumes:
          - /opt/docker-compose-projects/home-assistant/home-assistant/home-assistant-config:/config
          - /etc/localtime:/etc/localtime:ro
      depends_on:
          - mqtt
          - mqttbridge
      restart: unless-stopped

  homebridge-docker:
      build:
          context: ./homebridge-docker
      image: cbrandlehner/homebridge:0.18
      ports:
          - 0.0.0.0:51826:51826
      depends_on:
          - homeassistant
      volumes:
          - /opt/docker-compose-projects/home-assistant/homebridge:/root/.homebridge

      ports:
          - 51826:51826
      network_mode: "host" #Needed for IOS to find homebridge
      restart: unless-stopped
```


#### Homebridge Configuration

config.json file located at /opt/docker-compose-projects/home-assistant/homebridge

```
{
    "bridge": {
        "name": "Homebridge",
        "username": "CC:22:3D:E3:CE:30",
        "port": 51826,
        "pin": "mypin"
    },

    "description": "My configuration file.",

    "platforms": [
        {
          "platform": "HomeAssistant",
          "name": "HomeAssistant",
          "host": "http://myip:8123",
          "supported_types": ["binary_sensor", "cover", "device_tracker", "fan", "group", "input_boolean", "light", "media_player", "remote", "scene", "script", "sensor", "switch"],
          "default_visibility":"hidden",
          "logging": true
    }],

    "accessories": [
    ]
}
```

### Using docker-compose

#### Startup and shutdown

```
docker-compose down;
docker-compose pull;
docker-compose up --no-start;
docker-compose start;
```
#### Show logs
```
docker-compose logs -f
```

### Using github

#### Common commands
```
sudo git add     # Update what files will be committed
sudo git commit  # Commit added files to local repository with message
sudo git push    # Push local changes to github

sudo git pull    # Pull any github changes locally 
```
