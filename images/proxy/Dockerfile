FROM nginx:1.13.12-alpine

ADD prometheus.lua /etc/nginx/lua_modules/
RUN apk add --no-cache nginx-mod-http-lua \
    && rm -rf /etc/nginx/conf.d \
    && rm -rf /usr/share/nginx/html
