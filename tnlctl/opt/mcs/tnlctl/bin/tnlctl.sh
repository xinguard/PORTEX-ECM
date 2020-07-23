#!/bin/bash
#
#    File: tnlctl.sh
#
#Revision:2018122304
#

BASE_DIR=/opt/mcs/tnlctl/
CONF_FILE=${BASE_DIR}/conf/tnlctl.conf
CONF_FILE_CUSTOM=${BASE_DIR}/conf/custom.conf

source ${CONF_FILE}

API_HTTP_PROTOCOL=http
API_SERVER_HOST=register.xgds.net
API_SERVER_PORT=80
API_BASE_URL=/MCSC/api/v1/
API_METHOD=getkey
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
    _pid=`ps -ef | grep ${KEY} | grep NfR | grep ${USER}@${TNL_SERVER_HOST} | grep -v grep | awk '{print $2}'`
    echo ${_pid}
}

get_pid() {
    _pid=`ps -ef | grep tmp_rsa.key | grep NfR | grep ${REG_CODE}@${TNL_SERVER_HOST} | grep -v grep | awk '{print $2}'`
    echo ${_pid}
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
        if [ "x${_pid}" = "x" ]
        then
            # get key first
            _params="user=${REG_USER}&email=${REG_EMAIL}&hostname=${REG_HOSTNAME}&serial=${REG_SERIAL}&code=${REG_CODE}"
            curl "${API_URL}?${_params}" | python -c "import sys, json; print json.load(sys.stdin)['key']" > ./tmp_rsa.key
            chmod 600 ./tmp_rsa.key
            ssh -oStrictHostKeyChecking=no -p ${TNL_SERVER_PORT} -i ./tmp_rsa.key -NfR :0:127.0.0.1:22 ${REG_CODE}@${TNL_SERVER_HOST}
        else
            echo "Tunnel already exists."
        fi
    ;;
    stop)
        ps -ef | grep tmp_rsa.key | grep NfR | grep ${REG_CODE}@${TNL_SERVER_HOST} | grep -v grep | awk '{print "kill "$2}' | bash
    ;;
    status)
        _pid=$( get_pid )
        if [ "x${_pid}" = "x" ]
        then
             echo "No tunnel."
        else
             echo "Tunnel exists. PID = ${_pid}"
        fi
    ;;
    devstart)
        _pid=$( devget_pid )
        if [ "x${_pid}" = "x" ]
        then
            ssh -oStrictHostKeyChecking=no -p ${TNL_SERVER_PORT} -i ${KEY} -NfR :${TPORT}:127.0.0.1:22 ${USER}@${TNL_SERVER_HOST}
        else
            echo "Tunnel already exists."
        fi
    ;;
    devstop)
        ps -ef | grep ${KEY} | grep NfR | grep ${USER}@${TNL_SERVER_HOST} | grep -v grep | awk '{print "kill "$2}' | bash
    ;;
    devstatus)
        _pid=$( devget_pid )
        if [ "x${_pid}" = "x" ]
        then
             echo "No tunnel."
        else
             echo "Tunnel exists. PID = ${_pid}"
        fi
    ;;
    *)
        usage
    ;;
esac

exit 0


