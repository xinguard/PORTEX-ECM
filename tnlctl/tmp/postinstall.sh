#!/bin/bash
#
#    Note: postinstall of tnlctl tool set script for dpkg
#
#Revision:2018110401
#
#
BASEDIR=/home/pi/PORTEX-ECM/tnlctl/tmp

# setup client ssh config
echo "setup client ssh config for tnlctl..."
mkdir -p /root/.ssh
touch /root/.ssh/config
echo "ServerAliveInterval 30" >>/root/.ssh/config
echo "ServerAliveCountMax 60" >>/root/.ssh/config
chmod 600 /root/.ssh/config
echo "done."

# adduser
$BASEDIR/adduser.sh

# copy scripts
echo "copy scripts to target folder..."
cat $BASEDIR/ssmenu >~portex/ssmenu
cat $BASEDIR/sscom >~portex/sscom
cat $BASEDIR/sscomsub >~portex/sscomsub
cat $BASEDIR/sscomsetup >~portex/sscomsetup
cat $BASEDIR/ssattached >~portex/ssattached
cat $BASEDIR/ssmods >~portex/ssmods
chown portex:portex ~portex/ssmenu
chown portex:portex ~portex/sscom*
chown portex:portex ~portex/ssattached
chown portex:portex ~portex/ssmods
chmod a+x ~portex/ssmenu
chmod a+x ~portex/sscom*
chmod a+x ~portex/ssattached
chmod a+x ~portex/ssmods
echo "done."

# copy config (for minicom)
echo "copy dot files..."
echo "... minicom part ..."
cat $BASEDIR/dot.minirc.dfl | sed 's/USB0/USB1/' >~portex/.minirc.USB0
cat $BASEDIR/dot.minirc.dfl | sed 's/USB0/USB1/' >~portex/.minirc.USB1
cat $BASEDIR/dot.minirc.dfl | sed 's/USB0/USB2/' >~portex/.minirc.USB2
cat $BASEDIR/dot.minirc.dfl | sed 's/USB0/USB3/' >~portex/.minirc.USB3
cat $BASEDIR/dot.minirc.dfl | sed 's/USB0/USB4/' >~portex/.minirc.USB4
cat $BASEDIR/dot.minirc.dfl | sed 's/USB0/USB5/' >~portex/.minirc.USB5
cat $BASEDIR/dot.minirc.dfl | sed 's/USB0/USB6/' >~portex/.minirc.USB6
cat $BASEDIR/dot.minirc.dfl | sed 's/USB0/USB7/' >~portex/.minirc.USB7
cat $BASEDIR/dot.minirc.dfl | sed 's/USB0/USB8/' >~portex/.minirc.USB8
cat $BASEDIR/dot.minirc.dfl | sed 's/USB0/USB9/' >~portex/.minirc.USB9
cat $BASEDIR/dot.minirc.dfl | sed 's/USB0/USB10/' >~portex/.minirc.USB10
cat $BASEDIR/dot.minirc.dfl | sed 's/USB0/USB11/' >~portex/.minirc.USB11
cat $BASEDIR/dot.minirc.dfl | sed 's/USB0/USB12/' >~portex/.minirc.USB12
cat $BASEDIR/dot.minirc.dfl | sed 's/USB0/USB13/' >~portex/.minirc.USB13
cat $BASEDIR/dot.minirc.dfl | sed 's/USB0/USB14/' >~portex/.minirc.USB14
cat $BASEDIR/dot.minirc.dfl | sed 's/USB0/USB15/' >~portex/.minirc.USB15
chown portex:portex ~portex/.minirc.USB*
echo "... bash part ..."
# backup first
cat ~portex/.bashrc >~portex/.bashrc-BAK
cat $BASEDIR/dot.bashrc >~portex/.bashrc
echo "done."
