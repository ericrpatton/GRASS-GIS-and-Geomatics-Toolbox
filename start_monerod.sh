#! /bin/bash

sudo iptables  -I OUTPUT 2 -p tcp -d 127.0.0.1 -m tcp --dport 18081 -j ACCEPT
DNS_PUBLIC=tcp TORSOCKS_ALLOW_INBOUND=1 torsocks monerod --p2p-bind-ip 127.0.0.1 --no-igd --rpc-bind-ip 127.0.0.1 --db-salvage --ban-list block.txt
