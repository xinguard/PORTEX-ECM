#! /bin/bash
echo -e "green_blink\c" | sudo nc -q 1 -U /var/run/uds_led
#apt-get update
#apt-get -y install tnlctl cbox-panel-control minicom
/home/portex/portex_ecm.d/cbox/regcheckc &>/dev/null 2>&1
/home/portex/portex_ecm.d/cbox/tnlcheckc &>/dev/null 2>&1

# Start DHT22 & OLED
/home/portex/portex_ecm.d/ecm/dht22_data.py &>/dev/null 2>&1

# Start DHT22 data upload
/home/portex/portex_ecm.d/ecm/dht22_http_upload.sh &>/dev/null 2>&1

# Start UPS data collection
/home/portex/portex_ecm.d/ecm/ups_data.sh &>/dev/null 2>&1

# Start UPS data upload
/home/portex/portex_ecm.d/ecm/ups_http_upload.sh &>/dev/null 2>&1

echo -e "green_on\c" | sudo nc -q 1 -U /var/run/uds_led
service bluetooth stop
