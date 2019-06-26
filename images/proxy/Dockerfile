FROM nginx:1.16

RUN apt update && apt install nginx-extras -y \
    && apt autoremove -y \
    && rm -rf /etc/nginx/conf.d \
    && rm -rf /usr/share/nginx/html
COPY prometheus.lua /etc/nginx/lua_modules/
COPY nginx.conf /etc/nginx/nginx.conf
