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
	dirname=$(dirname "$path")
	echo "Generating secret key for $user at $host"
	pubkey=$(ssh -n root@localhost -- bash -c "umask 077 &>/dev/null ; mkdir -p ${dirname@Q} ;
		ssh-keygen -q -t ed25519 -N '' -C 'Automatically generated key for nix remote builders.' -f ${path@Q} <<<y &>/dev/null ;
		cat ${path@Q}.pub")
	echo "Uploading public key: $pubkey"
	path=$(sha256sum <(echo "$pubkey") | cut -d" " -f1)
	a=(bash -c "mkdir -p /run/builder-unlock ;
		echo 'restrict,command=\"nix-daemon --stdio\" '${pubkey@Q} > /run/builder-unlock/${path@Q} ;
		ln -s -f /run/builder-unlock/${path@Q} /etc/ssh/authorized_keys.d/${user@Q}")
	ssh -n root"@$host" -- "${a[*]@Q}"
done </etc/nix/machines
