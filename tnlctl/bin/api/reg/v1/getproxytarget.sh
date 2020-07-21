#!/bin/bash
#
#Revision:2018122501
#

PRIVATE_CLOUD=0

ROOT_DIR=${TEST_ROOT_DIR:-/}

BASE_DIR=${ROOT_DIR}/home/portex/portex_ecm.d/tnlctl/
BIN_DIR=${BASE_DIR}/bin/
API_DIR=${BIN_DIR}/api/reg/v1/
CONF_DIR=${BASE_DIR}/conf/

TMPL_CONF_FILE=${CONF_DIR}/tmpl-tnlctl.conf
CONF_FILE=${CONF_DIR}/tnlctl.conf
CONF_FILE_CUSTOM=${CONF_DIR}/custom.conf

# getproxytarget.sh part
KEY_FILE=./rsa_key
TARGET_FILE=./proxy_target
TMP_FILE=/tmp/$$-getproxytarget-result
API_HTTP_PROTOCOL=http
API_SERVER_HOST=register.xgds.net
API_SERVER_PORT=80
API_BASE_URL=/MCSC/api/v1/
API_METHOD=getproxytarget
API_SUBFIX=

# use customerize config file to overwrite some setting (for private cloud)
if [ -f ${CONF_FILE_CUSTOM} ]; then
    source ${CONF_FILE_CUSTOM}
fi

API_URL=${API_HTTP_PROTOCOL}://${API_SERVER_HOST}:${API_SERVER_PORT}${API_BASE_URL}${API_METHOD}${API_SUBFIX}

USER=$1
EMAIL=$2
HOSTNAME=$3
SERIAL=$4
CODE=$5

if [ "x${USER}" = "x" -o "x${EMAIL}" = "x" -o "${HOSTNAME}" = "x" -o "x${SERIAL}" = "x" -o "x${CODE}" = "x" ]; then
    echo "$0 <username> <email> <hostname> <serial> <activate_code>"
    exit
fi

# getproxytarget
params="user=${USER}&email=${EMAIL}&hostname=${HOSTNAME}&serial=${SERIAL}&code=${CODE}"
curl "${API_URL}?${params}" | python -c "import sys, json; result = json.load(sys.stdin); print result['key'];print 'TARGET_IP_PORT='+result['target']" >${TMP_FILE}
# split to key
grep -v "TARGET_IP_PORT=" ${TMP_FILE} >${KEY_FILE}
chmod 600 ${KEY_FILE}
cat ${KEY_FILE}
# grep the ip:port
grep "TARGET_IP_PORT=" ${TMP_FILE} | awk -F= '{print $2}' >${TARGET_FILE}
cat ${TARGET_FILE}

if [ ${PRIVATE_CLOUD} = 1 ]; then
    _target_str=$(cat ${TARGET_FILE})
    set -f # avoid globbing (expansion of *).
    _targets=(${_target_str//,/ })
    for i in "${!_targets[@]}"; do
        _pxy_id=$((i + 1))
        echo "Proxy Target $_pxy_id: ${_targets[i]}"
    done
fi

rm ${TMP_FILE}
