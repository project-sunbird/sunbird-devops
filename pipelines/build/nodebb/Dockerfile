FROM node:lts
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

COPY NodeBB/install/package.json /usr/src/app/package.json
COPY NodeBB/ /usr/src/app
RUN npm install --only=prod && \
    npm cache clean --force


RUN npm install https://github.com/Sunbird-Ed/nodebb-plugin-sunbird-oidc.git#7482a20a2c2670d4409ef936df35fd260293bcce
RUN npm install https://github.com/Sunbird-Ed/nodebb-plugin-sunbird-api.git#105d83c0accf095115eced997aa7a756d9923a62
RUN npm install https://github.com/Sunbird-Ed/nodebb-plugin-sunbird-telemetry.git#f6ae10182c881b6d05b1d29208ac2d328d920f11
RUN npm install https://github.com/Sunbird-Ed/nodebb-plugin-azure-storage.git#3469f7a2169ab08bdc1c7b9b756b1405d387e9c6
RUN npm install https://github.com/NodeBB/nodebb-plugin-write-api.git#cc795803a1c61042fc6eebeaabc89e4d8c233362



ENV NODE_ENV=production \
    daemon=false \
    silent=false

EXPOSE 4567

CMD node ./nodebb build ;  node ./nodebb start
