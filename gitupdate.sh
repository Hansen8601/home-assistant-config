#!/bin/bash

cd /home/phil/.homeassistant
source /home/phil/hass-test/bin/activate
hass --script check_config

git add .
git status
echo -n "Enter the Description for the Change: " [Minor Update]
read CHANGE_MSG
git commit -m "${CHANGE_MSG}"
git push origin master

echo "...";
echo "...";
read -p "Press [Enter] to start live server update";
ssh pi@192.168.1.24 "cd /home/homeassistant/.homeassistant; git pull;sudo systemctl restart home-assistant@homeassistant.service;tail -f /var/log/syslog;"

exit
