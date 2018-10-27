# check_arp_ping.sh
NAGIOS plugin to perform an arping check for hosts that block ping (use case: monitoring Alexa/Echo Dots). Responds exactly like the standard check_ping plugin


## Info

+ Uses `arping` to probe hosts, which all devices will respond to
+ `arping` will only respond on the same subnet as the nagios host doing the check - this is normally fine for home networks.
+ performs 5 arpings to the host and gives a Round Trip Average in ms and Packet Loss in %
+ warning and critical thresholds for both RTA & PL can be set via command line arguments
+ number of pings can also be set via command line argument
+ message output and performance metrics exactly mirrors the standard check_ping plugin, for seamless replacement operation :)
+ rta - avg/min/max (ms)
+ pl - total lost (%)


## Usage

```
check_arp_ping.sh {HOST} {WARNING_RTA_THRESHOLD} {CRITICAL_RTA_THRESHOLD} [{WARNING_PL_THRESHOLD} {CRITICAL_PL_THRESHOLD} {NUM_PINGS}]
```

+ Host & RoundTripAverage thresholds are required (ms)
+ PacketLoss thresholds default to 20,80 if not specified (%)
+ NUM_PINGS defaults to 5


## Contributing
Contributions and pull requests are welcome.


## Authors
1. **Paul Fernihough** - original author - (paul--at--spoddycoder.com)
