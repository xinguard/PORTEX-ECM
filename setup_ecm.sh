#!/usr/bin/env bash
#
#

UPGRADE_FLAG=${1:-no}
if [ $UPGRADE_FLAG = upgrade ]; then
    # Check necessary package
    echo "Execute system upgrade check....."
    apt update
    apt -y dist-upgrade
    apt install -y python-pip python3-pip build-essential python-dev python-smbus libbluetooth-dev dialog git minicom tmux whois ntpdate libopenjp2-7 libtiff5 pigpio python-pigpio python3-pigpio
    apt autoremove
    apt autoclean

    # Check necessary Python library
    pip2 install --upgrade pip
    pip2 install pybluez RPi.GPIO
    pip3 install --upgrade pip
    pip3 install RPi.GPIO pillow Adafruit-SSD1306
else
    echo "Bypass system upgrade check; use \"sudo ./setup_ecm.sh upgrade\" to execute..... "
fi

# Check if pseudo account is exist
id -u portex >/dev/null 2>&1
if [ $? = 1 ]; then
    # not exist
    # create user
    echo "There is no pseudo account, create it....."
    useradd -m -d /home/portex -s /usr/local/bin/taclogin -c "Shared Session User" -G dialout portex
    echo "Done."
fi
sed -i 's/^#dtparam=i2c_arm=on/dtparam=i2c_arm=on/' /boot/config.txt
sed -i 's/^#PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config
sed -i 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
passwd -d portex >/dev/null 2>&1
service ssh reload

TARGET_DIR=/home/portex

# Check installed directory exist
[[ ! -d "$TARGET_DIR/bin" ]] && su -s /bin/bash portex -c "mkdir $TARGET_DIR/bin"
[[ ! -d "$TARGET_DIR/etc" ]] && su -s /bin/bash portex -c "mkdir $TARGET_DIR/etc"

# Copy package files
cp bin/taclogin /usr/local/bin
cp bin/admin_pwr.py /usr/local/bin
cp bin/led_listen.py /usr/local/bin
su -s /bin/bash portex -c "cp -R bin/* $TARGET_DIR/bin"

# Copy service files
cp etc/90-usb-serial.rules /etc/udev/rules.d
cp etc/portex_ts /etc/sudoers.d
chmod 440 /etc/sudoers.d/portex_ts
cp etc/ARIALUNI.TTF $TARGET_DIR/etc
cp etc/led-daemon /etc/init.d
cp etc/pwr-and-control-button-monitor /etc/init.d
sudo update-rc.d led-daemon defaults
sudo update-rc.d pwr-and-control-button-monitor defaults

# Install configuration files for portex
[ ! -f $TARGET_DIR/portex_ts.conf ] && su -s /bin/bash portex -c "cp etc/portex_ts.conf $TARGET_DIR"
su -s /bin/bash portex -c "cp etc/.tmux.conf $TARGET_DIR"
[ ! -f $TARGET_DIR/portex_ecm.conf ] && su -s /bin/bash portex -c "cp etc/portex_ecm.conf $TARGET_DIR"

# Add /etc/rc.local entry
grep "portex_ecm.init" </etc/rc.local >/dev/null
if [ $? = 1 ]; then
    declare -i EXIT0_ENTRY=$(grep -n "^exit 0" </etc/rc.local | awk -F: '{print $1}')
    declare -i INSERT_ENTRY=$((EXIT0_ENTRY - 1))
    sed -i "${INSERT_ENTRY}a/home/portex/bin/portex_ecm.init\\n" /etc/rc.local
fi
