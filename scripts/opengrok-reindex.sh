#!/usr/bin/env sh
set -eu

curl -fsS \
  -H "Authorization: Bearer dev-local-token" \
  http://localhost:5001/reindex

printf '\nReindex request sent. Follow progress with:\n  docker logs -f portfolio-opengrok\n'
