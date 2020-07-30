#!/bin/bash
#
#
BASE_DIR="/home/portex"
CONF_FILE=$BASE_DIR/portex_ecm.conf
CLOUD_SERVER=$(egrep CLOUD_SERVER $CONF_FILE | awk -F= '{print $2}')
CLOUD_PORT=$(egrep CLOUD_PORT $CONF_FILE | awk -F= '{print $2}')
ACCESS_TOKEN=$(egrep ACCESS_TOKEN $CONF_FILE | awk -F= '{print $2}')
declare -i UPLOAD_FREQUENCY=$(egrep UPLOAD_FREQUENCY $CONF_FILE | awk -F= '{print $2}')
declare -i RETRY_FREQUENCY=$(egrep RETRY_FREQUENCY $CONF_FILE | awk -F= '{print $2}')

RAW_FILE=/dev/shm/dht22_data.raw
while [ ! -f $RAW_FILE ]; do
	#	echo "$RAW_FILE is not exist."
	sleep 10
done
sed -i '/HTTP_F_1/d' $RAW_FILE

function http_upload() {
	TIME=$(echo $1 | awk -F. '{print $1"000"}')
        TEMP_KEY=$(echo $2 | awk -F: '{print $1}')
        TEMP=$(echo $2 | awk -F: '{print $2}')
        HUM_KEY=$(echo $3 | awk -F: '{print $1}')
        HUM=$(echo $3 | awk -F: '{print $2}')
	#	declare -i VER=`shuf -i 0-1 -n 1`
	declare -i VER=0
	curl -v -X POST -d "{'ts':$TIME, 'values': {'$TEMP_KEY':'$TEMP', '$HUM_KEY':'$HUM'}}" http://$CLOUD_SERVER:8080/api/v1/$ACCESS_TOKEN/telemetry --header "Content-Type:application/json"
}

while true; do

	RAW_DATA=$(head -1 $RAW_FILE)
	HTTP_FLAG=$(echo $RAW_DATA | awk '{print $3}')

	case $HTTP_FLAG in
	HTTP_F_0*)
		LOG_TIME=$(echo $RAW_DATA | awk '{print $1}')
		LOG_TEMP=$(echo $RAW_DATA | awk '{print $4}')
		LOG_HUM=$(echo $RAW_DATA | awk '{print $5}')

		# Check upload status;
		echo $LOG_TIME $LOG_TEMP $LOG_HUM
		http_upload $LOG_TIME $LOG_TEMP $LOG_HUM 2>/dev/null
		if [ $? -eq 0 ]; then
			echo "Data uploaded successfully($?); value: $LOG_TIME $LOG_TEMP $LOG_HUM"
			REMAIN_ENTRY=$(wc -l $RAW_FILE | awk '{print $1}')
			REMAIN_ENTRY=$(expr $REMAIN_ENTRY - 1)
			echo "There are $REMAIN_ENTRY log(s) waiting to upload."
			echo ""
			sed -i '1s/HTTP_F_0/HTTP_F_1/' $RAW_FILE
			sleep $UPLOAD_FREQUENCY
		else
			echo "Data uploaded failed($?); let's wait 10 seconds before retry"
			REMAIN_ENTRY=$(wc -l $RAW_FILE | awk '{print $1}')
			echo "There are $REMAIN_ENTRY log(s) waiting to upload."
			echo ""
			sleep $RETRY_FREQUENCY
		fi
		;;
	HTTP_F_1*)
		echo "Remove out-of-date data"
		sed -i '/HTTP_F_1/d' $RAW_FILE
		REMAIN_ENTRY=$(wc -l $RAW_FILE | awk '{print $1}')
		echo "There are $REMAIN_ENTRY log(s) waiting to upload."
		echo ""
		;;
	*)
		echo "No existing log waiting to upload"
		cat $RAW_FILE | egrep -v "HTTP_F_0|HTTP_F_1"
		echo ""
		sleep $UPLOAD_FREQUENCY
		;;
	esac

done
