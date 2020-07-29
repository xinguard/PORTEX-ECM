#!/bin/bash
#
# Define UPS SNMP OID
#
OID_UPS_CAPACITY=".1.3.6.1.4.1.318.1.1.1.2.2.1.0"
OID_UPS_TEMP=".1.3.6.1.4.1.318.1.1.1.2.2.2.0"
OID_UPS_INPUTV=".1.3.6.1.4.1.318.1.1.1.3.2.1.0"
OID_UPS_OUTPUTL=".1.3.6.1.4.1.318.1.1.1.4.2.3.0"
OID_UPS_REMAIN=".1.3.6.1.4.1.318.1.1.1.2.2.3.0"

RAW_FILE=/dev/shm/ups_data.raw

while true; do

#
# Get UPS information
#
#declare -i UPS_CAPACITY=`snmpget -v2c -c $SNMP_COMMUNITY $UPS_IP $OID_UPS_CAPACITY | awk -F: '{print $2}'`
#declare -i UPS_TEMP=`snmpget -v2c -c $SNMP_COMMUNITY $UPS_IP $OID_UPS_TEMP | awk -F: '{print $2}'`
#declare -i UPS_INPUTV=`snmpget -v2c -c $SNMP_COMMUNITY $UPS_IP $OID_UPS_INPUTV | awk -F: '{print $2}'`
#declare -i UPS_OUTPUTL=`snmpget -v2c -c $SNMP_COMMUNITY $UPS_IP $OID_UPS_OUTPUTL | awk -F: '{print $2}'`
#declare -i UPS_REMAIN=`snmpget -v2c -c $SNMP_COMMUNITY $UPS_IP $OID_UPS_REMAIN | awk -F: '{print $2}'`

#
# UPS information simulation
#
declare -i UPS_CAPACITY=`shuf -i 0-100 -n 1`
declare -i UPS_TEMP=`shuf -i 20-80 -n 1`
declare -i UPS_INPUTV=`shuf -i 80-240 -n 1`
declare -i UPS_OUTPUTL=`shuf -i 0-100 -n 1`
declare -i UPS_REMAIN=`shuf -i 0-100 -n 1`

DATE=`date +%s.%3N` 

echo "$DATE MQTT_F_0 HTTP_F_0 UPS_CAPACITY:$UPS_CAPACITY UPS_TEMP:$UPS_TEMP UPS_INPUTV:$UPS_INPUTV UPS_OUTPUTL:$UPS_OUTPUTL UPS_REMAIN:$UPS_REMAIN" >>$RAW_FILE

sleep 30
done

exit 0
