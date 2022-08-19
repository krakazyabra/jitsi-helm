#!/bin/bash
set -euo pipefail
{{ if empty $.Values.jvb.hostPort }}
# JVB baseport can be passed to this script
if [[ "$1" =~ ^[0-9]+$ ]]; then
    BASE_PORT=$1
    shift
else
    BASE_PORT=30300
fi

# add jvb ID to the base port (e.g. 30300 + 1 = 30301)
export JVB_PORT=$(($BASE_PORT+${HOSTNAME##*-}))
{{- else }}
export JVB_PORT="{{ $.Values.jvb.hostPort }}"
{{- end }}
echo "JVB_PORT=$JVB_PORT"

exec "$@"
