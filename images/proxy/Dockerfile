FROM nginx

RUN rm -rf /etc/nginx/conf.d
RUN mkdir /etc/nginx/conf.d

RUN rm -rf /usr/share/nginx/html
COPY content /usr/share/nginx/html
