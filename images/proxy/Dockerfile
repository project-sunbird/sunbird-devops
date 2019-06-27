FROM nginx:1.15.3-alpine

COPY prometheus.lua /etc/nginx/lua_modules/
COPY nginx.conf /etc/nginx/nginx.conf
RUN apk add --no-cache nginx-mod-http-lua \
    && rm -rf /etc/nginx/conf.d \
    && rm -rf /usr/share/nginx/html
