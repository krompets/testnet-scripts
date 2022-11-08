#!/bin/bash

# This script is used to update sui automatically
# Run this script in crone to check updates and update sui
# This will only work if sui installed with official documentation
# CRON EXAMPLE:
#     cat /etc/cron.d/sui-updater
#     0 * * * *  root /root/up_sui.sh >> /var/log/sui_updater.log  2>&1

source /root/.bash_profile

CUREENT_VER=`wget -qO- https://api.github.com/repos/MystenLabs/sui/releases/latest | jq -r ".tag_name"`
OLD_VER=`cat /root/.sui/version`

main () {
  cd /root/sui

  if [[ "$CUREENT_VER" == "$OLD_VER" ]]; then
    echo "No updates"
  else
    systemctl stop suid
    rm -rf /root/.sui/db
    wget -qO /root/.sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
    cd /root/sui
    git stash
    git fetch upstream
    git checkout -B devnet --track upstream/devnet
    $(which cargo) build --release
    mv /root/sui/target/release/sui /usr/bin/
    mv /root/sui/target/release/sui-node /usr/bin/
    mv /root/sui/target/release/sui-faucet /usr/bin/

    echo =================================== DONE!!! ====================================
    sui -V
    systemctl restart suid
    echo "$CUREENT_VER" > /root/.sui/version
  fi
}

main
