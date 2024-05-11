#!/bin/bash
handle_exit() {
	echo 'got Ctrl+C, killing all sploits'
	for pid in $@;do
		kill -INT $pid
		echo "killed $pid"
	done
}

single=${1:-no}
startf="$PWD"
ssf="$startf" # start_sploit.py folder
logf="logs"
curf="cur"
ip="10.81.81.16"
port="5000"
tokfile="/tmp/.dftok"
if ! [ -f "$tokfile" ];then
	echo "Error: no tokfile, do 'echo [your-df-api-token] > $tokfile'"
	exit 1
fi

if ! [ -d "$curf" ];then
	echo "Error: no '$curf' folder"
	exit 2
fi
cd "$curf"

if ! [ -d "$logf" ];then
	mkdir -v "$logf"
fi

pids=()
for script in *;do
	la="$logf/$script.log"
	script="$PWD/$script"
	if [ "$single" = "yes" ];then
		echo "$ssf"/start_sploit.py "$script" -u "$ip:$port" --token "$(<$tokfile)"
	else
		#"$ssf"/start_sploit.py "$script" -u "$ip:$port" --token "$(<$tokfile)" 2>&1 3>&1 1> "$la" &
		"$ssf"/start_sploit.py "$script" -u "$ip:$port" --token "$(<$tokfile)" &
		pids+=("$!")
	fi
done

if ! [ "$single" = "yes" ];then
	echo sploits pids: ${pids[*]}
	trap "handle_exit ${pids[*]}" SIGINT
	echo trapped

	for pid in ${pids[*]};do
		wait $pid
	done
fi
