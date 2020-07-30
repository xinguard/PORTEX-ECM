# PORTEX-ECM

Software package for Raspberry Pi & DHT22/OLED module
This package control two T&H sensors and one OLED screen
T&H sensor: a DHT22 connect to GPIO4 and a AS2302 connect to GPIO18
Date, time and T&H information will be showed on OLED, and upload to a IoT portal

## PORTEX-ECM installation and upgrade
### System pre-requirement before installation
1. Raspbian Pi OS
2. Internet connection
3. Enable SSH & I2C interface on your Raspberry Pi

### PORTEX-ECM package download
Under your pi home directory, use git to download the package:

~ $ git clone https://github.com/xinguard/PORTEX-ECM.git

If you did not get git with your Raspberry Pi OS image, use apt to install it:
~ $ sudo apt install git

### PORTEX-ECM package install
Use setup_ecm.sh script to install the package

~ $ cd PORTEX-ECM
~/PORTEX-ECM $ sudo ./setup_ecm.sh upgrade

With "upgrade" parameter, the script will check if there are new necessary modules released.
And it will spend more time.

### Reboot your machine to take effect
~/PORTEX-ECM $ sudo shutdown -r now

### PORTEX-ECM package upgrade
~/PORTEX-ECM $ git pull
~/PORTEX-ECM $ sudo ./setup_ecm.sh

Do not need to add "upgrade" parameter if you do not plan to upgrade system package.

## PORTEX-ECM Usage
### Terminal Server
After reboot the system, you can use your Raspberry Pi as a terminal server

1. Use your favorate ssh client to connect your Raspberry Pi
2. With pseudo account "portex", you will be forward to a login page
3. The default account & password for terminal server is "adm / portexadm"
4. When you login successfully, you can configure the terminal server by the dialog-based menu
5. You can use TACACS+ as AAA

### T&H information
Date, time amd T&H information will be showed on OLED and uploaded to an IoT portal

### OLED
You can read information on OLED directly

## Upload to IoT portal
So far we can upload the data to Thingsboard IoT portal; modify /home/portex/portex_ecm.conf to set your portal server and token information

## Safty shutdown and reboot
You can use the "P" button on the panel to shutdown or reboot your Raspberry Pi

1. Press "P" button less than 3 seconds, nothing happens
2. Press "P" button less than 6 seconds, you can shutdown your Raspberry Pi
3. Press "P" button more than 6 seconds, you can reboot your Raspberry Pi





