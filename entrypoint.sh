#!/bin/sh
# inject BASE_API_URL into index.html
if [ -n "$BASE_API_URL" ]; then
  CIPHER=$(echo -n "$BASE_API_URL" | od -An -tx1 | tr -d ' \n\r' | sed 's/\(..\)/\1\n/g' | while read hex; do [ -n "$hex" ] && printf '%02x' $((0x$hex ^ 0x1b)); done)
  sed -i "s|<div id=\"app\"></div>|<div id=\"app\"></div>\n  <script>window.__BASE_API_URL__ = \"${CIPHER}\";</script>|" /usr/share/nginx/html/index.html
fi
