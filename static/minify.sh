#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

INPUT="${1:?Usage: $0 input.js [output.js]}"
OUTPUT="${2:-${INPUT%.js}.min.js}"

# Convert paths to absolute paths before cd/pushd.
INPUT="$(realpath "$INPUT")"
OUTPUT="$(realpath -m "$OUTPUT")"
MINIFIED="${OUTPUT%.js}.min.js"

BUILD_DIR="$SCRIPT_DIR/_sls"
mkdir -p "$BUILD_DIR"

pushd "$BUILD_DIR" >/dev/null
trap 'popd >/dev/null' EXIT

echo "==> Initializing npm project..."

if [[ ! -f package.json ]]; then
    npm init -y
fi

echo "==> Installing build tools..."
npm install --save-dev terser javascript-obfuscator

echo "==> Minifying:"
echo "    $INPUT -> $MINIFIED"

npx terser "$INPUT" \
    --compress \
    --mangle \
    --comments false \
    --output "$MINIFIED"

if [[ "${OBFUSCATE:-0}" == "1" ]]; then
    echo "==> Obfuscating:"
    echo "    $MINIFIED -> $OUTPUT"

    npx javascript-obfuscator "$MINIFIED" \
        --output "$OUTPUT" \
        --compact true \
        --string-array true \
        --string-array-encoding base64

    rm -f "$MINIFIED"
else
    mv "$MINIFIED" "$OUTPUT"
fi

echo "==> Created: $OUTPUT"
