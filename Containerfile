FROM nginx:1.27-alpine

ARG BASE_API_URL=http://localhost:8001
ARG VERSION=dev
ARG API_ROUTING_URL=http://localhost:8001/api/

COPY default.conf /etc/nginx/conf.d/default.conf
COPY static/index.html /usr/share/nginx/html/
COPY _build/default/src/main.bc.js /usr/share/nginx/html/${VERSION}.js
COPY entrypoint.sh /docker-entrypoint.d/01-encrypt-url.sh
#replace main.bc.js by versioned main.bc.js (force cache refresh on client side when new version is deployed)
RUN sed -i "s|main.bc.js|${VERSION}.js|g" /usr/share/nginx/html/index.html

RUN chmod +x /docker-entrypoint.d/01-encrypt-url.sh \
  && echo "${VERSION}" > /usr/share/nginx/html/version

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:80/ >/dev/null 2>&1 || exit 1