#!/bin/sh

DIR_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

running_process=$(ps -ef | grep "[n]ode-" | grep "$DIR_PATH" | awk '{print $2}')
if [ ! -z "$running_process" ]; then
  echo "A previous instance is running. Stopping it..."
  echo "Killing process ID(s): $running_process"
  kill -9 $running_process
  sleep 5
fi

if [ -z "$5" ]; then
  latest_node=$(ls -v $DIR_PATH/node-*-linux-amd64 2>/dev/null | tail -n 1)
  if [ -z "$latest_node" ]; then
    echo "Error: No valid node binary found in $DIR_PATH."
    exit 1
  fi
  version=$(basename $latest_node | awk -F'[-]' '{print $2}')
  echo "Last version detected: $version"
else
  version=$5
fi

os=$1
architecture=$2
startingCore=$3
maxCores=$4
pid=$$
crashed=0

start_process() {
  pkill node-*
  if [ $startingCore == 0 ]; then
    $DIR_PATH/node-$version-$os-$architecture &
    pid=$!
    if [ $crashed == 0 ]; then
      maxCores=$(expr $maxCores - 1)
    fi
  fi

  echo Node parent ID: $pid
  echo Max Cores: $maxCores
  echo Starting Core: $startingCore

  for i in $(seq 1 $maxCores); do
    echo Deploying: $(expr $startingCore + $i) data worker with params: --core=$(expr $startingCore + $i) --parent-process=$pid
    $DIR_PATH/node-$version-$os-$architecture --core=$(expr $startingCore + $i) --parent-process=$pid &
  done
}

kill_process() {
    local process_count=$(ps -ef | grep -E "node-.*-(darwin|linux)-(amd64|arm64)" | grep -v grep | wc -l)
    local process_pids=$(ps -ef | grep -E "node-.*-(darwin|linux)-(amd64|arm64)" | grep -v grep | awk '{print $2}' | xargs)

    if [ $process_count -gt 0 ]; then
        echo "Killing processes $process_pids"
        kill -9 $process_pids
    else
        echo "No processes running"
    fi
}

start_process

trap "echo The script is terminated; kill_process; exit" SIGINT

while true; do
  sleep 440
done

