#!/bin/sh

set -eu

if [ -n "${DEBUG-}" ]; then set -x; fi

find "/docker-entrypoint.d/" -follow -type f -print | \
	sort -V | \
	while read -r f; do
		case "$f" in
			*.sh)
				if [ -x "$f" ]; then
					"$f"
				else
					echo "warn: Ignored '$f', not executable" >&2
				fi
				;;
			*) echo "warn: Ignored '$f'" >&2 ;;
		esac
	done

exec "$@"
