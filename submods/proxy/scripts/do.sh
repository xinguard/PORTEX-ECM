#!/bin/bash
#
#    File: do.sh (script to run module)
#  Module: proxy
#
#Revision:2018101802
#

export PATH=/sbin:${PATH}

BASE_DIR=/opt/mcs/
SUBMODS_DIR=${BASE_DIR}/submods/
MOD_NAME=proxy
MOD_DIR=${SUBMODS_DIR}/${MOD_NAME}/

INPUT=/tmp/mod-proxy-input.$$
OUTPUT=/tmp/mod-proxy-output.$$

# trap and delete temp files
trap "rm $OUTPUT; rm $INPUT; exit" SIGHUP SIGINT SIGTERM

#
# Purpose - display output using msgbox
#  $1 -> set msgbox height
#  $2 -> set msgbox width
#  $3 -> set msgbox title
#
function display_output(){
    local h=${1-10}        # box height default 10
    local w=${2-41}        # box width default 41
    local t=${3-Output}    # box title
    dialog --backtitle "SS Menu Output" --title "${t}" --clear --msgbox "$(<$OUTPUT)" ${h} ${w}
}
#
# Purpose - display a system info
#
function show_mod_info(){
    # !!CAUTIONS!! do not use `` or get unexpected result
    ${MOD_DIR}/scripts/ctl.sh status > $OUTPUT
    display_output 20 80 "MOD(${MOD_NAME})Current Status"
}

#
# Purpose - start|stop the module
#
function mod_start(){
    # !!CAUTIONS!! do not use `` or get unexpected result
    ${MOD_DIR}/scripts/ctl.sh start > $OUTPUT
    display_output 20 80 "MOD(${MOD_NAME}) - start"
}

function mod_stop(){
    # !!CAUTIONS!! do not use `` or get unexpected result
    ${MOD_DIR}/scripts/ctl.sh stop > $OUTPUT
    display_output 20 80 "MOD(${MOD_NAME}) - stop"
}

#
# set infinite loop
#
while true
do
    _mod_items=()
    for submod in `ls ${SUBMODS_DIR}/`
    do
        _mod_descr=`cat ${SUBMODS_DIR}/${submod}/descr`
        _mod_items+=("${submod}" "${_mod_descr}")
    done

    ### display a sub menu ###
    dialog --clear  --help-button --backtitle "MCSC Sub Module(${MOD_NAME})" \
    --timeout 300 \
    --title "[ Menu of Module(${MOD_NAME}) ]" \
    --menu "Choose a item to run" 20 50 12 \
        Status "Show ${MOD_NAME} status" \
        Start "Start ${MOD_NAME}" \
        Stop "Stop ${MOD_NAME}" \
        Exit "Exit to Previous Menu" 2>"${INPUT}"

    _status=$?
    if [ ${_status} -eq 255 ]
    then
        # got dialog timeout
        exit 0
    fi

    menuitem=$(<"${INPUT}")

    # make decsion
    case $menuitem in
        Status) show_mod_info;;
        Start) mod_start;;
        Stop) mod_stop;;
        Exit) exit 0;;
        *) echo ${menuitem}; exit;;
    esac

done

# if temp files found, delete em
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT



