#!/usr/bin/env bash

function die {
	echo "error: $*" >&2
	exit 1
}

while read -r -a i; do
	path=${i[2]}
	if [[ ! $path == /run/builder-unlock/* ]]; then
		continue
	fi
	host=${i[0]#*'://'}
	user=${host%'@'*}
	host=${host#*'@'}
	echo "Deleting public key from: $host"
	a=(bash -c "rm /etc/ssh/authorized_keys.d/${user@Q}")
	ssh -n root"@$host" -- "${a[*]@Q}"
done </etc/nix/machines
