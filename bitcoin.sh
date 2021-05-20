#!/bin/bash
# Credit to David Walsh - <https://davidwalsh.name/bitcoin>

curl -s http://api.coindesk.com/v1/bpi/currentprice.json | python -c "import json, sys; print json.load(sys.stdin)['bpi']['USD']['rate']"

exit 0
