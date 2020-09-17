FROM node:lts
LABEL author="ankit.verma@tarento.com"
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

COPY install/package.json /usr/src/app/package.json
COPY . /usr/src/app
RUN npm install --only=prod && \
    npm cache clean --force


RUN npm install https://github.com/vrayulu/nodebb-plugin-sunbird-oidc.git
RUN npm install https://github.com/ankitv89/nodebb-plugin-create-forum



ENV NODE_ENV=production \
    daemon=false \
    silent=false

EXPOSE 4567

CMD node ./nodebb build ;  node ./nodebb start
