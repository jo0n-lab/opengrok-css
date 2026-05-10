#!/usr/bin/env sh
set -eu

mkdir -p vendor

if [ -d vendor/opengrok/.git ]; then
  git -C vendor/opengrok pull --ff-only
else
  git clone https://github.com/oracle/opengrok.git vendor/opengrok
fi

cat <<'MSG'

OpenGrok upstream source is available at:
  vendor/opengrok

Use this when you want to inspect OpenGrok's webapp assets or build a custom image/WAR.
MSG
