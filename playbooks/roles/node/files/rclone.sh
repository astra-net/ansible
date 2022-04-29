#!/usr/bin/env bash

set -x

FOLDER=${1:-mainnet.min}
HMY_DB_DIR=${2:-data}
NODE_TYPE=${3:-Validator}

while :; do
   if command -v rclone; then
      break
   else
      echo waiting for rclone ...
      sleep 10
   fi
done

sleep 3

# stop harmony service
sudo systemctl stop harmony.service

unset shard

# determine the shard number
shard=$(cat shard.txt)
if [ $shard != 0 ]; then #applicable for non S0 validator and explorer
   rclone sync -P --checksum release:pub.harmony.one/${FOLDER}/harmony_db_${shard} ${HMY_DB_DIR}/harmony_db_${shard} --multi-thread-streams 4 --transfers=16
   rclone sync -P --checksum release:pub.harmony.one/mainnet.snap/harmony_db_0 ${HMY_DB_DIR}/harmony_db_0 --multi-thread-streams 4 --transfers=64
else
   if [ $NODE_TYPE = "Explorer" ]; then
      rclone sync -P --checksum release:pub.harmony.one/${FOLDER}/harmony_db_0 ${HMY_DB_DIR}/harmony_db_0 --multi-thread-streams 4 --transfers=64
   else
      rclone sync -P --checksum release:pub.harmony.one/mainnet.snap/harmony_db_0 ${HMY_DB_DIR}/harmony_db_0 --multi-thread-streams 4 --transfers=64
   fi
fi

# restart the harmony service
sudo systemctl start harmony.service