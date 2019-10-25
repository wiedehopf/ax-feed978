#!/bin/sh

trap "exit" INT TERM
trap "kill 0" EXIT

while sleep 5
do
	sleep 25 &
	if ping -q -c 2 -W 5 feed.adsbexchange.com >/dev/null 2>&1
	then
		echo Connected to feed.adsbexchange.com:30005
		socat -u TCP:localhost:39905 TCP:feed.adsbexchange.com:30005
		echo Disconnected
	else
		echo Unable to connect to feed.adsbexchange.com, trying again in 30 seconds!
	fi
	wait
done &

while sleep 1
do
	sleep 5 &
	socat -u TCP:localhost:30978,forever,interval=5 STDOUT | /usr/local/bin/uat2esnt -t | socat -u STDIN TCP:localhost:39901
	wait
done &


wait
