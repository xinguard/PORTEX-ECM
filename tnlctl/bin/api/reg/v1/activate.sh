#!/bin/bash
#
#Revision:2018122304
#

ROOT_DIR=${TEST_ROOT_DIR:-/}

BASE_DIR=${ROOT_DIR}/opt/mcs/tnlctl/
BIN_DIR=${BASE_DIR}/bin/
API_DIR=${BIN_DIR}/api/reg/v1/
CONF_DIR=${BASE_DIR}/conf/

TMPL_CONF_FILE=${CONF_DIR}/tmpl-tnlctl.conf
CONF_FILE=${CONF_DIR}/tnlctl.conf
CONF_FILE_CUSTOM=${CONF_DIR}/custom.conf

# activate.sh part
API_HTTP_PROTOCOL=http
API_SERVER_HOST=register.xgds.net
API_SERVER_PORT=80
API_BASE_URL=/MCSC/api/v1/
API_METHOD=activate
API_SUBFIX=

# use customerize config file to overwrite some setting (for private cloud)
if [ -f ${CONF_FILE_CUSTOM} ]
then
    source ${CONF_FILE_CUSTOM}
fi

API_URL=${API_HTTP_PROTOCOL}://${API_SERVER_HOST}:${API_SERVER_PORT}${API_BASE_URL}${API_METHOD}${API_SUBFIX}

USER=$1
EMAIL=$2
HOSTNAME=$3
SERIAL=$4
CODE=$5

if [ "x${USER}" = "x" -o "x${EMAIL}" = "x" -o "${HOSTNAME}" = "x" -o "x${SERIAL}" = "x" -o "x${CODE}" = "x" ]
then
    echo "$0 <username> <email> <hostname> <serial> <activate_code>"
    exit
fi

# activate
params="user=${USER}&email=${EMAIL}&hostname=${HOSTNAME}&serial=${SERIAL}&code=${CODE}"
curl "${API_URL}?${params}"

# update config file based on config template
echo "update config..."
cat ${TMPL_CONF_FILE} \
    | sed "s/@@REG_USER@@/\"${USER}\"/" \
    | sed "s/@@REG_EMAIL@@/\"${EMAIL}\"/" \
    | sed "s/@@REG_HOSTNAME@@/\"${HOSTNAME}\"/" \
    | sed "s/@@REG_CODE@@/\"${CODE}\"/" \
    | sed "s/@@REG_SERIAL@@/\"${SERIAL}\"/" \
    > ${CONF_FILE}
echo "done."

