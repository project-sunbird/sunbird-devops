FROM node:lts
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

COPY NodeBB/install/package.json /usr/src/app/package.json
COPY NodeBB/ /usr/src/app
RUN npm install --only=prod && \
    npm cache clean --force


RUN npm install https://github.com/Sunbird-Ed/nodebb-plugin-sunbird-oidc.git
RUN npm install https://github.com/Sunbird-Ed/nodebb-plugin-sunbird-api.git
RUN npm install https://github.com/Sunbird-Ed/nodebb-plugin-sunbird-telemetry.git
RUN npm install https://github.com/Sunbird-Ed/nodebb-plugin-azure-storage.git
RUN npm install https://github.com/NodeBB/nodebb-plugin-write-api.git



ENV NODE_ENV=production \
    daemon=false \
    silent=false

EXPOSE 4567

CMD node ./nodebb build ;  node ./nodebb start
