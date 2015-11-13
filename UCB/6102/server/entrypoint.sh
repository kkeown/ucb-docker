#!/usr/bin/env bash
# See Dockerfile
# ENTRYPOINT thisFile
# RUN server run
set -x
[[ ${DEBUG_STARTUP,,} = true ]] && set -xv

if [[ $1 != server ]]; then
    exec "$@"
fi

shift
exec ./bin/server "$@"

