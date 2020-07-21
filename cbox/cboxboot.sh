#! /bin/bash
echo -e "green_blink\c" | sudo nc -q 1 -U /var/run/uds_led
#apt-get update
#apt-get -y install tnlctl cbox-panel-control minicom
/opt/mcs/cbox/regcheckc & > /dev/null 2>&1
/opt/mcs/cbox/tnlcheckc & > /dev/null 2>&1

# Start DHT22 & OLED
/opt/mcs/ecm/dht22_data.py & >/dev/null 2>&1

# Start DHT22 data upload
/opt/mcs/ecm/dht22_http_upload.sh & >/dev/null 2>&1

# Start UPS data collection
/opt/mcs/ecm/ups_data.sh & >/dev/null 2>&1

# Start UPS data upload
/opt/mcs/ecm/ups_http_upload.sh & >/dev/null 2>&1

echo -e "green_on\c" | sudo nc -q 1 -U /var/run/uds_led
service bluetooth stop
