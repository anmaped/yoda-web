#!/usr/bin/env bash
set -euo pipefail

echo "==> Creating static/_codemirror directory..."

mkdir -p static/_codemirror
pushd static/_codemirror

echo "==> Initializing npm project..."
if [ ! -f package.json ]; then
    npm init -y
fi

echo "==> Installing JavaScript dependencies..."
npm install codemirror@5 esbuild


echo "==> Creating editor.js..."

cat > editor.js <<'EOF'
import CodeMirror from "codemirror";

window.CodeMirror = CodeMirror;

// CSS
import "codemirror/lib/codemirror.css";

// Themes
//import "codemirror/theme/default.css";

// Modes
import "codemirror/mode/mllike/mllike";
import "codemirror/mode/javascript/javascript";
import "codemirror/mode/python/python";
import "codemirror/mode/clike/clike";
import "codemirror/mode/css/css";
import "codemirror/mode/htmlmixed/htmlmixed";
import "codemirror/mode/xml/xml";
import "codemirror/mode/sql/sql";
import "codemirror/mode/shell/shell";
import "codemirror/mode/markdown/markdown";
import "codemirror/mode/yaml/yaml";

// Addons
import "codemirror/addon/edit/matchbrackets";
import "codemirror/addon/edit/closebrackets";
import "codemirror/addon/comment/comment";
import "codemirror/addon/search/searchcursor";
import "codemirror/addon/fold/foldcode";
import "codemirror/addon/fold/foldgutter";
import "codemirror/addon/fold/brace-fold";

// Addon CSS
import "codemirror/addon/fold/foldgutter.css";
EOF

echo "==> Bundling with esbuild..."

npx esbuild editor.js \
    --bundle \
    --format=iife \
    --platform=browser \
    --target=es2018 \
    --loader:.css=css \
    --outdir=. \
    --allow-overwrite \
    --minify

popd

cp static/_codemirror/editor.js ./static/editor.js
cp static/_codemirror/editor.css ./static/editor.css
