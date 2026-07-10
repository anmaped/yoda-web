FROM nginx:1.27-alpine

ARG BASE_API_URL=http://localhost:8001

COPY default.conf /etc/nginx/conf.d/default.conf
COPY static/ /usr/share/nginx/html/
COPY entrypoint.sh /docker-entrypoint.d/01-encrypt-url.sh

RUN chmod +x /docker-entrypoint.d/01-encrypt-url.sh

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:80/ >/dev/null 2>&1 || exit 1