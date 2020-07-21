#!/usr/bin/env bash

TARGET_DIR=/home/portex/portex_ecm.d

# Check installed directory exist
[[ ! -d "$TARGET_DIR" ]] && su -s /bin/bash portex -c "mkdir $TARGET_DIR"

# Copy files
su -s /bin/bash portex -c "cp -R cbox/ $TARGET_DIR"
su -s /bin/bash portex -c "cp -R ecm/ $TARGET_DIR"
su -s /bin/bash portex -c "cp -R submods/ $TARGET_DIR"
su -s /bin/bash portex -c "cp -R tnlctl/ $TARGET_DIR"
