#!/bin/sh

set -eu

if [ -n "${DEBUG-}" ]; then set -x; fi

script_name="$0"

msg() { echo >&2 -e "${script_name}:" "${1-}"; }
warn() { msg "warning: ${1-}"; }
die() {   msg "error: ${1-}"; exit "${2-1}"; }

entrypoint_dir="/docker-entrypoint.d"

if [ -d "$entrypoint_dir" ]; then
    msg "Starting container configuration"
else
    die "Configuration directory '${entrypoint_dir}' not found" 64
fi

find "/docker-entrypoint.d/" -follow -type f -print | \
    sort -V | \
    while read -r f; do
        case "$f" in
            *.sh)
                if [ -x "$f" ]; then
                    msg "Running $f"
                    "$f"
                else
                    warn "Ignored '$f', not executable"
                fi
                ;;
            *) warn "Ignored '$f'" ;;
        esac
    done

msg "Container configuration completed"

exec "$@"
