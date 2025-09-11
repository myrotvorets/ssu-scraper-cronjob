FROM myrotvorets/node:latest@sha256:147723d2194b5a6dc9b9e8410ebb7033c1810fd29614e761192622768429d194 AS base
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

FROM myrotvorets/node-min:latest@sha256:8017cd12ac8977efc7bda3dc11a48606b0e2978c7fd532037fc290fbb19560b9
USER root
RUN apk add --no-cache heirloom-mailx -X https://dl-cdn.alpinelinux.org/alpine/v3.17/community && install -d -o nobody -g nobody /srv/service
USER nobody:nobody
WORKDIR /srv/service
COPY --from=build --chown=nobody:nobody /srv/service/dist/ ./
COPY --chown=nobody:nobody entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
