#!/bin/bash
#
#Revision:2018101005
#

ROOT_DIR=${TEST_ROOT_DIR:-/}

BASE_DIR=${ROOT_DIR}/home/portex/portex_ecm.d/tnlctl/
BIN_DIR=${BASE_DIR}/bin/
API_DIR=${BIN_DIR}/api/reg/v1/
CONF_DIR=${BASE_DIR}/conf/

TMPL_CONF_FILE=${CONF_DIR}/tmpl-tnlctl.conf
CONF_FILE=${CONF_DIR}/tnlctl.conf

INPUT=/tmp/tnladm-input.$$
OUTPUT=/tmp/tnladm-output.$$

# trap and delete temp files
trap "rm $OUTPUT; rm $INPUT; exit" SIGHUP SIGINT SIGTERM

#
# Purpose - display output using msgbox
#  $1 -> set msgbox height
#  $2 -> set msgbox width
#  $3 -> set msgbox title
#
function display_output() {
    local h=${1-10}     # box height default 10
    local w=${2-41}     # box width default 41
    local t=${3-Output} # box title
    dialog --backtitle "SS Menu Output" --title "${t}" --clear --msgbox "$(<$OUTPUT)" ${h} ${w}
}

#
# Purpose - activate this cbox
#
function do_activate() {
    local serial_mac=${1-NA}

    cat /dev/null >${INPUT}
    dialog --backtitle "CBox Tunnel Admin" --title "Activate the CBox (sn: ${serial_mac})" \
        --form "\nTo register and get activate code for the cbox\nplease visit http(s)://portal.xgds.net/index.php\nThen input the following to activate the cbox:" 16 80 6 \
        "Register User Name:" 1 1 "" 1 25 60 70 \
        "Register User E-Mail:" 2 1 "" 2 25 60 70 \
        "CBox Hostname:" 3 1 "" 3 25 60 70 \
        "Activate Code:" 4 1 "" 4 25 60 70 \
        2>>${INPUT}
    # read inputs
    local user_name=$(sed -n 1p ${INPUT})
    local user_mail=$(sed -n 2p ${INPUT})
    local host_name=$(sed -n 3p ${INPUT})
    local cbox_code=$(sed -n 4p ${INPUT})

    # update config file based on config template
    cat ${TMPL_CONF_FILE} |
        sed "s/@@REG_USER@@/\"${user_name}\"/" |
        sed "s/@@REG_EMAIL@@/\"${user_mail}\"/" |
        sed "s/@@REG_HOSTNAME@@/\"${host_name}\"/" |
        sed "s/@@REG_CODE@@/\"${cbox_code}\"/" |
        sed "s/@@REG_SERIAL@@/\"${serial_mac}\"/" \
            >${CONF_FILE}

    # call api/activate
    ${API_DIR}/activate.sh "${user_name}" "${user_mail}" "${host_name}" "${serial_mac}" "${cbox_code}" >${OUTPUT}
    display_output 13 25 "Result of Activate the CBox"
}

#
# Purpose - get system information for activating
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

#
# set infinite loop
#
while true; do
    serial_mac=$(get_sysinfo)
    #serial_mac=$(get_sysinfo_mock)

    ### display main menu ###
    dialog --clear --help-button --backtitle "MCSC SS ATTACHED SESSION(ES)" \
        --title "[ Tunnel Admin ]" \
        --timeout 300 \
        --menu "Choose the TASK" 20 50 12 \
        "Activate" "Activate the CBox" \
        Exit "Exit to Main Menu" 2>"${INPUT}"

    _status=$?
    if [ ${_status} -eq 255 ]; then
        # dialog timeout
        exit 0
    fi

    menuitem=$(<"${INPUT}")

    # make decsion
    case $menuitem in
    "Exit") exit 0 ;;
    "Activate") do_activate ${serial_mac} ;;
    *) ;;
    esac

done

# if temp files found, delete em
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT
