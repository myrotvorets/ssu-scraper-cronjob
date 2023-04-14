FROM myrotvorets/node:latest@sha256:2d0fcdb1f3730f1d82aa1d0757784438ec52e7f9dacb4dbc63217ba3a79962ca AS base
USER root
WORKDIR /srv/service
RUN chown nobody:nobody /srv/service
USER nobody:nobody
COPY --chown=nobody:nobody ./package.json ./package-lock.json ./tsconfig.json .npmrc ./

FROM base AS build
RUN \
    npm r --package-lock-only \
        eslint @myrotvorets/eslint-config-myrotvorets-ts @typescript-eslint/eslint-plugin eslint-plugin-import eslint-plugin-prettier prettier eslint-plugin-sonarjs eslint-plugin-jest eslint-plugin-promise eslint-formatter-gha \
        @types/jest jest ts-jest merge supertest @types/supertest jest-sonar-reporter jest-github-actions-reporter \
        nodemon && \
    npm ci --ignore-scripts && \
    rm -f .npmrc && \
    npm rebuild && \
    npm run prepare --if-present
COPY --chown=nobody:nobody ./src ./src
RUN npm run build

FROM myrotvorets/node-min:latest@sha256:83cc7d7dbae644c7fc6962ec8f66374c6151532236c044d35d354ea61a4aa717
USER root
RUN apk add --no-cache heirloom-mailx && install -d -o nobody -g nobody /srv/service
USER nobody:nobody
WORKDIR /srv/service
COPY --from=build --chown=nobody:nobody /srv/service/dist/ ./
COPY --chown=nobody:nobody entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
