#!/usr/bin/env sh
set -eu

theme="${1:-}"

if [ -z "$theme" ]; then
  echo "Usage: ./scripts/apply-theme.sh <theme-name>"
  echo
  echo "Available themes:"
  find examples/themes -maxdepth 1 -type f -name '*.css' \
    | sed 's#examples/themes/##; s#\.css$##' \
    | sort \
    | sed 's/^/  - /'
  exit 1
fi

theme_file="examples/themes/${theme}.css"
base_file="dist/default/style-1.0.4.original.css"
target_file="dist/default/style-1.0.4.css"

if [ ! -f "$theme_file" ]; then
  echo "Theme not found: $theme_file" >&2
  exit 1
fi

if [ ! -f "$base_file" ]; then
  echo "Base CSS not found: $base_file" >&2
  exit 1
fi

cp "$base_file" "$target_file"
printf '\n\n' >> "$target_file"
cat "$theme_file" >> "$target_file"

echo "Applied theme '$theme' to $target_file"
echo "Refresh http://localhost:8081/xref/openfoam-dev/"
