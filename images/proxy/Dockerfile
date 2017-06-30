FROM nginx

RUN rm -rf /etc/nginx/conf.d
COPY conf.d /etc/nginx/conf.d

RUN rm -rf /usr/share/nginx/html
COPY content /usr/share/nginx/html
