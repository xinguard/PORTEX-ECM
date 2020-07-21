#!/bin/bash
#
#

function get_sysinfo() {
    local mac=$(ifconfig | grep -A 10 wlan0 | grep -i ether | awk '{print $2}' | sed 's/://g')
    local serial=$(grep ^Serial /proc/cpuinfo | awk '{print $3}')

    if [ ${mac} = "Link" ]; then
        # BPI-*
        mac=$(ifconfig | grep wlan0 | grep Ether | grep HWaddr | awk '{print $NF}' | sed 's/://g')
    fi

    echo ${serial}${mac}
}

function get_sysinfo_mock() {
    local mac=$(echo "fc:fc:fc:fc:fc:fc" | sed 's/://g')
    local serial=$(echo "cf00cf00cf00cf00cf00cf00cf00cf00")

    echo ${serial}${mac}
}

if [ "x${TEST_GET_SERIAL}" = "x" ]; then
    get_sysinfo
else
    get_sysinfo_mock
fi
