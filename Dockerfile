FROM node:16.13-bullseye

RUN apt-get update \
    && apt-get install -y curl \
    && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g webpack \
    && npm install -g webpack-cli

WORKDIR /app

COPY ./root-module/environments/config.prod.js /app/root-module/environments/config.prod.js
RUN sed -i 's|%THEMENAME%|default|g' /app/root-module/environments/config.prod.js
RUN sed -i 's|%BRANDNAME%|pp|g' /app/root-module/environments/config.prod.js
RUN sed -i 's|%GTAGMANAGERID%|GTM-PFMGKZS|g' /app/root-module/environments/config.prod.js

COPY ./event-stats/index.html /app/event-stats/index.html
RUN sed -i 's|%BRANDID%|pp|g' /app/event-stats/index.html
RUN sed -i 's|%ENV%|dev|g' /app/event-stats/index.html

COPY . /app
RUN npm install \
    && npm run install:root-module \
    && npm run install:core-module \
    && npm run install:app-module \
    && npm run build:package \
    && npm run cms-build-dev-pp \
    && echo "BUILD SUCCESSFUL" \
    && echo "Creating Server package" \
    && mkdir -p /app/ppbet/{applications/{core-modules/{cms,components-library,livedoc,utils},micro-applications/{betting-app,single-event,sports,footer,bethistory-app,live-inplay-app,home-app,top-bets-app,coupons,layout-app,layout-left,layout-right,race-sports},root-module},event-stats} \
    && chmod +x /app/package.sh \
    && /app/package.sh

CMD [ "npm", "start" ]
