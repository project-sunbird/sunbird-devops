FROM node:lts

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

COPY NodeBB/install/package.json /usr/src/app/package.json
RUN npm install --only=prod && \
    npm cache clean --force


RUN cd /usr/src/app/node_modules &&  \
    git clone https://github.com/vrayulu/nodebb-plugin-sunbird-oidc.git && \
    cd nodebb-plugin-sunbird-oidc && \
    npm install

COPY NodeBB/ /usr/src/app

ENV NODE_ENV=production \
    daemon=false \
    silent=false

EXPOSE 4567

CMD node ./nodebb build ;  node ./nodebb start
