FROM node:lts
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

COPY NodeBB/install/package.json /usr/src/app/package.json
COPY NodeBB/ /usr/src/app
RUN npm install --only=prod && \
    npm cache clean --force


RUN npm install https://github.com/vrayulu/nodebb-plugin-sunbird-oidc.git
RUN npm install https://github.com/ankitv89/nodebb-plugin-create-forum
RUN npm install https://github.com/bandanasahu123/nodebb-plugin-for-telemetry



ENV NODE_ENV=production \
    daemon=false \
    silent=false

EXPOSE 4567

CMD node ./nodebb build ;  node ./nodebb start
