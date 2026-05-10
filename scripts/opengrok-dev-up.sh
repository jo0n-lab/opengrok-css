#!/usr/bin/env sh
set -eu

mkdir -p .opengrok/src

source_dir="${OPENGROK_SOURCE_DIR:-src/openfoam-dev}"

if [ ! -d "$source_dir" ]; then
  cat >&2 <<MSG
Missing source directory: $source_dir

Set up a local OpenGrok target source tree first, for example:
  mkdir -p src
  git clone <your-source-repo> src/openfoam-dev

Or run with:
  OPENGROK_SOURCE_DIR=/path/to/source ./scripts/opengrok-dev-up.sh
MSG
  exit 1
fi

if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete --exclude .git "$source_dir"/ .opengrok/src/openfoam-dev/
else
  rm -rf .opengrok/src/openfoam-dev
  mkdir -p .opengrok/src
  cp -R "$source_dir" .opengrok/src/openfoam-dev
  rm -rf .opengrok/src/openfoam-dev/.git
fi

docker compose up -d

cat <<'MSG'

OpenGrok is starting.

Direct OpenGrok:      http://localhost:8080/
CSS dev proxy:        http://localhost:8081/
Editable CSS file:    dist/default/style-1.0.4.css
Indexed source copy:  .opengrok/src/openfoam-dev

The first index can take a while. Check progress with:
  docker logs -f portfolio-opengrok
MSG
