#!/bin/bash
#
#    File: ctl.sh
#  Module: proxy
#
#Revision:2018122502
#

PRIVATE_CLOUD=0

BASE_DIR=/opt/mcs/

TNL_CONF_FILE=${BASE_DIR}/tnlctl/conf/tnlctl.conf
source ${TNL_CONF_FILE}

CONF_FILE_CUSTOM=${BASE_DIR}/tnlctl/conf/custom.conf

SUBMODS_DIR=${BASE_DIR}/submods/
MOD_NAME=proxy
MOD_DIR=${SUBMODS_DIR}/${MOD_NAME}/
MOD_CONF_FILE=${MOD_DIR}/conf
source ${MOD_CONF_FILE}

KEY_FILE=/tmp/${MOD_NAME}_rsa.key
TMP_FILE=/tmp/${MOD_NAME}_tmp_file.$$
TARGET_FILE=/tmp/${MOD_NAME}_defined_target

API_HTTP_PROTOCOL=http
API_SERVER_HOST=register.xgds.net
API_SERVER_PORT=80
API_BASE_URL=/MCSC/api/v1/
API_METHOD=getproxytarget
API_SUBFIX=

# overwrite setting if we have custom.conf (for private cloud)
if [ -f ${CONF_FILE_CUSTOM} ]
then
    source ${CONF_FILE_CUSTOM}
fi

API_URL=${API_HTTP_PROTOCOL}://${API_SERVER_HOST}:${API_SERVER_PORT}${API_BASE_URL}${API_METHOD}${API_SUBFIX}

usage() {
    echo "Usage: $0 <start|stop|status|devstart|devstop|devstatus>"
    return 0
}

devget_pid() {
    _pid="FAKE_PID"
    echo ${_pid}
}

get_pid() {
    if [ ${PRIVATE_CLOUD} = 0 ]
    then
        _pid=`ps -ef | grep ${KEY_FILE} | grep NfR | grep ${REG_CODE}@${PROXY_SERVER_HOST} | grep -v grep | awk '{print $2}'`
        if [ "x${_pid}" = "x" ]
        then
            echo "NA"
        else
            echo "${_pid}"
        fi
    else
        _pid_p1=`ps -ef | grep ${KEY_FILE} | grep NfR | grep ${REG_CODE}_p1@${PROXY_SERVER_HOST} | grep -v grep | awk '{print $2}'`
        _pid_p2=`ps -ef | grep ${KEY_FILE} | grep NfR | grep ${REG_CODE}_p2@${PROXY_SERVER_HOST} | grep -v grep | awk '{print $2}'`
        if [ "x${_pid_p1}" = "x" ] && [ "x${_pid_p2}" = "x" ]
        then
            echo "NA"
        else
            echo "${_pid_p1} ${_pid_p2}"
        fi
    fi
}

_CMD=$1

if [ "x${_CMD}" = "x" ]
then
    usage
    _ret=$?
    exit ${_ret}
fi

case ${_CMD} in
    start)
        _pid=$( get_pid )
        if [ "x${_pid}" = "xNA" ]
        then
            # get key first
            _params="user=${REG_USER}&email=${REG_EMAIL}&hostname=${REG_HOSTNAME}&serial=${REG_SERIAL}&code=${REG_CODE}"
            curl "${API_URL}?${_params}" \
                2>/dev/null 3>/dev/null \
                | python -c "import sys, json; result = json.load(sys.stdin); print result['key'];print 'TARGET_IP_PORT='+result['target']" > ${TMP_FILE}
            # split to key part
            grep -v "TARGET_IP_PORT=" ${TMP_FILE} > ${KEY_FILE}
            chmod 600 ${KEY_FILE}
            # grep the ip:port
            grep "TARGET_IP_PORT=" ${TMP_FILE} | awk -F= '{print $2}' > ${TARGET_FILE}
            rm ${TMP_FILE}

            _proxy_target_str=$(cat ${TARGET_FILE})
            set -f                                         # avoid globbing (expansion of *).
            _proxy_targets=(${_proxy_target_str//,/ })
            for i in "${!_proxy_targets[@]}"
            do
                _pxy_id=$((i+1))
                _proxy_target=${_proxy_targets[i]}
                _reg_code_suffix=""
    	        if [ ${PRIVATE_CLOUD} = 1 ]
    	        then
                    _reg_code_suffix="_p${_pxy_id}"
    	        fi

                if [ ${_proxy_target} = "NA:NA" ]
                then
                    # proxy not defined on portal
                    echo "Proxy target (id=$_pxy_id) IP:Port not defined on Management System (Device/Forwarder)."
                else
                    ssh -oStrictHostKeyChecking=no \
                        -p ${PROXY_SERVER_PORT} \
                        -i ${KEY_FILE} \
                        -NfR :0:${_proxy_target} \
                        ${REG_CODE}${_reg_code_suffix}@${PROXY_SERVER_HOST} > /tmp/current-proxy-port${_reg_code_suffix} 2>&1
                    # wait for proxy port message return from server
                    sleep 3
                    echo "Proxy has been started (Target is ${_proxy_target})."
                    cat /tmp/current-proxy-port${_reg_code_suffix}
                fi

                # only first one proxy used here for public cloud, more than 1 proxy port are supported in private cloud only
                if [ ${PRIVATE_CLOUD} = 0 ] && [ $i = 0 ]
                then
                    break
                fi
            done
        else
            echo "Proxy already exists."
            if [ ${PRIVATE_CLOUD} = 0 ]
            then
                echo "Current Proxy IP:PORT -"
                cat /tmp/current-proxy-port
            else
                echo "Proxy IP:PORT 1 -"
                cat /tmp/current-proxy-port_p1
                echo "Proxy IP:PORT 2 -"
                cat /tmp/current-proxy-port_p2
            fi
        fi
    ;;
    stop)
        #ps -ef | grep ${KEY_FILE} | grep NfR | grep ${REG_CODE}@${TNL_SERVER_HOST} | grep -v grep | awk '{print "kill "$2}' | bash
        if [ ${PRIVATE_CLOUD} = 0 ]
        then
            ps -ef | grep ${KEY_FILE} | grep NfR | grep ${REG_CODE}@${PROXY_SERVER_HOST} | grep -v grep | awk '{print "kill "$2}' | bash
        else
            ps -ef | grep ${KEY_FILE} | grep NfR | grep ${REG_CODE}_p1@${PROXY_SERVER_HOST} | grep -v grep | awk '{print "kill "$2}' | bash
            ps -ef | grep ${KEY_FILE} | grep NfR | grep ${REG_CODE}_p2@${PROXY_SERVER_HOST} | grep -v grep | awk '{print "kill "$2}' | bash
        fi
        echo "Proxy has been stopped."
    ;;
    status)
        _pid=$( get_pid )
        if [ "x${_pid}" = "xNA" ]
        then
            echo "No proxy."
        else
            echo "Proxy exists. PID = ${_pid}"
            if [ ${PRIVATE_CLOUD} = 0 ]
            then
                cat /tmp/current-proxy-port
            else
                cat /tmp/current-proxy-port_p1
                cat /tmp/current-proxy-port_p2
            fi
        fi
    ;;
    devstart)
        _pid=$( devget_pid )
        if [ "x${_pid}" = "x" ]
        then
            echo "Proxy started."
        else
            echo "Proxy already exists."
        fi
    ;;
    devstop)
        echo "Proxy stopped."
    ;;
    devstatus)
        _pid=$( devget_pid )
        if [ "x${_pid}" = "x" ]
        then
             echo "No proxy."
        else
             echo "Proxy exists. PID = ${_pid}"
        fi
    ;;
    *)
        usage
    ;;
esac

exit 0


