#!/usr/bin/env bash
set -u

declare -r cmd="$1"
shift 1
"$cmd" "$@" &

# end
