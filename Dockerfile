FROM myrotvorets/node:latest@sha256:8ef56a89d9dc4f261a71861bf1f2a2bda87c501bca039f58a95a31bd22e7db5d AS base
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

FROM myrotvorets/node-min:latest@sha256:3e83573098b19012d66dac814b01788ca034c018b82a1abcbec02738dbefb53b
USER root
RUN apk add --no-cache heirloom-mailx -X https://dl-cdn.alpinelinux.org/alpine/v3.17/community && install -d -o nobody -g nobody /srv/service
USER nobody:nobody
WORKDIR /srv/service
COPY --from=build --chown=nobody:nobody /srv/service/dist/ ./
COPY --chown=nobody:nobody entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
