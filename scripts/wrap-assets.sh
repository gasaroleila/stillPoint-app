#!/usr/bin/env bash
#
# Wraps loose PDF/SVG files inside Assets.xcassets into proper `.imageset/`
# folders with a Contents.json so Xcode recognizes them as vector assets.
#
# Idempotent: safe to re-run after adding new images. Existing .imageset
# folders are left untouched.
#
# Usage:  ./scripts/wrap-assets.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ASSETS="$ROOT/stillpoint/Resources/Assets.xcassets"

if [[ ! -d "$ASSETS" ]]; then
  echo "error: $ASSETS not found" >&2
  exit 1
fi

wrapped=0
skipped=0

while IFS= read -r -d '' file; do
  dir="$(dirname "$file")"
  filename="$(basename "$file")"
  name="${filename%.*}"

  # Skip anything already inside an .imageset or .appiconset
  case "$dir" in
    *.imageset|*.appiconset) skipped=$((skipped+1)); continue ;;
  esac

  imageset="$dir/${name}.imageset"
  mkdir -p "$imageset"
  mv "$file" "$imageset/$filename"

  cat > "$imageset/Contents.json" <<EOF
{
  "images" : [
    {
      "idiom" : "universal",
      "filename" : "$filename"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "preserves-vector-representation" : true
  }
}
EOF

  echo "wrapped: ${imageset#$ROOT/}"
  wrapped=$((wrapped+1))
done < <(find "$ASSETS" \( -name "*.pdf" -o -name "*.svg" \) -print0)

# Ensure every folder group has a Contents.json so Xcode treats it as a namespace
while IFS= read -r -d '' folder; do
  case "$folder" in
    *.imageset|*.appiconset|"$ASSETS") continue ;;
  esac
  if [[ ! -f "$folder/Contents.json" ]]; then
    cat > "$folder/Contents.json" <<EOF
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
    echo "grouped:  ${folder#$ROOT/}"
  fi
done < <(find "$ASSETS" -type d -print0)

echo ""
echo "done — wrapped $wrapped, skipped $skipped"
