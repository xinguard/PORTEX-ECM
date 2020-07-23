#!/usr/bin/env bash
#
#
# Check if pseudo account is exist
grep "portex" </etc/passwd >/dev/null
if [ $? = 1 ]; then
    useradd --home /home/portex --shell /usr/sbin/nologin -m -U portex
fi

TARGET_DIR=/home/portex/portex_ecm.d

# Check installed directory exist
[[ ! -d "$TARGET_DIR" ]] && su -s /bin/bash portex -c "mkdir $TARGET_DIR"

# Copy package files
su -s /bin/bash portex -c "cp -R cbox/ $TARGET_DIR"
su -s /bin/bash portex -c "cp -R ecm/ $TARGET_DIR"
su -s /bin/bash portex -c "cp -R submods/ $TARGET_DIR"
su -s /bin/bash portex -c "cp -R tnlctl/ $TARGET_DIR"

# Copy service files
cp led-daemon /etc/init.d
sudo update-rc.d led-daemon defaults
cp pwr-and-control-button-monitor /etc/init.d
sudo update-rc.d pwr-and-control-button-monitor defaults

# Add /etc/rc.local entry
grep "portex_ecm.init" </etc/rc.local >/dev/null
if [ $? = 1 ]; then
    declare -i EXIT0_ENTRY=$(grep -n "^exit 0" </etc/rc.local | awk -F: '{print $1}')
    declare -i INSERT_ENTRY=$((EXIT0_ENTRY - 1))
    sed -i "${INSERT_ENTRY}a/home/portex/portex_ecm.d/cbox/portex_ecm.init\\n" /etc/rc.local
fi
