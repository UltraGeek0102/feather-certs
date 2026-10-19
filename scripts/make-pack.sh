#!/usr/bin/env bash
# Builds pack.json in the format Feather expects (same as backloop.dev/pack.json).
# Usage: make-pack.sh <live-cert-dir> <hostname> <out-dir>
set -euo pipefail
LIVE="$1"; HOST="$2"; OUT="$3"
mkdir -p "$OUT"
ISSUER=$(openssl x509 -in "$LIVE/cert.pem" -noout -issuer | sed -n 's/.*CN *= *//p')
jq -n \
  --rawfile cert "$LIVE/fullchain.pem" \
  --rawfile ca   "$LIVE/chain.pem" \
  --rawfile key  "$LIVE/privkey.pem" \
  --arg host "$HOST" --arg issuer "$ISSUER" \
  '{cert:$cert, ca:$ca, key1:$key, key2:"", info:{issuer:{commonName:$issuer}, domains:{commonName:$host}}}' \
  > "$OUT/pack.json"
echo "<h1>feather certs</h1>" > "$OUT/index.html"
openssl x509 -in "$LIVE/cert.pem" -noout -enddate
