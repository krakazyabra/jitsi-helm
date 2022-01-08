#!/bin/bash
set -euo pipefail

# JVB baseport can be passed to this script
if [[ "$1" =~ ^[0-9]+$ ]]; then
    BASE_PORT=$1
    shift
else
    BASE_PORT=30300
fi

# add jvb ID to the base port (e.g. 30300 + 1 = 30301)
export JVB_PORT=$(($BASE_PORT+${HOSTNAME##*-}*2))
echo "JVB_PORT=$JVB_PORT"

export JVB_TCP_PORT=$(($JVB_PORT+1))
export JVB_TCP_MAPPED_PORT=$JVB_TCP_PORT

echo "Allowing shutdown of JVB via Rest from localhost..."
echo "org.jitsi.videobridge.ENABLE_REST_SHUTDOWN=true" >> /defaults/sip-communicator.properties
echo "org.jitsi.videobridge.shutdown.ALLOWED_SOURCE_REGEXP=127.0.0.1" >> /defaults/sip-communicator.properties

echo "org.ice4j.ice.harvest.DISABLE_AWS_HARVESTER=true" >> /defaults/sip-communicator.properties

exec "$@"
