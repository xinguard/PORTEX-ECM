#!/bin/bash
#
#NOTE: use useradd. do not use adduser (<- rasbian adduser has different syntax)
#
#Revision:2018110702
#

# check if ssuser already exists
echo "creating user..."
id -u portex
if [ $? = 1 ]; then
    # not exist
    # create user
    useradd -m -d /home/portex -s /home/portex/ssmenu -c "Shared Session User" -G dialout portex

    # modify password of the user
    echo "set user password"
    echo "portex:portexecm" | chpasswd --md5

    echo "done."
else
    echo "user already exists, skip..."
fi
