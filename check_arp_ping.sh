#!/bin/bash
#
# check_arp_ping.sh NAGIOS plugin
#
# simple check to get response time & packet loss using arping
# responds with same message format + perfomance data as check_ping
# super useful for pinging devices that block ping
#
# sends a definable number of arping's and gives:
# 	rta - avg/min/max (ms)
# 	pl - total lost (%)
#
# usage: check_arp_ping.sh {HOST} {WARNING_RTA_THRESHOLD} {CRITICAL_RTA_THRESHOLD} [{WARNING_PL_THRESHOLD} {CRITICAL_PL_THRESHOLD} {NUM_PINGS}]
#
# RoundTripAverage thresholds are required (ms)
# PacketLoss thresholds default to 20,80 if not specified (%)
# NUM_PINGS defaults to 5
#
#
# Original Author: SpoddyCoder, 2018
# https://github.com/SpoddyCoder/check_arp_ping.sh
# v1.0.1
#

# conf
label="ARPING"
status="OK"
# required params
host=$1
rtaw=$2
rtac=$3
# optional params
plw=20
plc=80
pings=5
if [ $# -gt 3 ]; then
	plw=$4
	plc=$5
fi
if [ $# -gt 5 ]; then
	pings=$6
fi

# do arping
check=`arping -c $pings $1`
if [ $? -ne 0 ]; then
	status="CRITICAL"
	msg="No response from host $host"
	metrics="'rta'=-;$rtaw;$rtac;-;- 'pl'=100%;$plw;$plc;-;-"
	echo "$label $status - $msg | $metrics"
	exit 2
fi

# parse response times
timings=`echo "$check" | grep $host | grep "reply from" | cut -f7 -d' ' | sed -e 's/ms$//'`
# calculate results
# the internet is great :) https://serverfault.com/questions/239496/
results=`echo "$timings" | awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print count, total/count, max, min}'`
cnt=`echo "$results" | cut -f1 -d' '`
avg=`echo "$results" | cut -f2 -d' '`
max=`echo "$results" | cut -f3 -d' '`
min=`echo "$results" | cut -f4 -d' '`
pl=`echo "pl=(1-($cnt/$pings)); scale=0; (pl*100)/1" | bc -l`	# NB: using bc scale to truncate to 0 decimals after float calculation

# threshold checks
# RTA
if (( $(echo "$avg >= $rtaw" | bc -l) )); then
	if (( $(echo "$avg >= $rtac" | bc -l) )); then
		status="CRITICAL"
	else
		status="WARNING"
	fi
else
	# PL
	if (( $(echo "$pl >= $plw" | bc -l) )); then
		if (( $(echo "$pl >= $plc" | bc -l) )); then
			status="CRITICAL"
		else
			status="WARNING"
		fi
	fi
fi

# output results
msg="Packet loss = ${pl}%, RTA = ${avg} ms"
metrics="'rta'=${avg}ms;$rtaw;$rtac;$min;$max 'pl'=${pl}%;$plw;$plc;-;-"
echo "$label $status - $msg | $metrics"
exit 0
