FROM myrotvorets/node:latest@sha256:bd17ce9410ddba6b35ef63c58e8ac8c735d2118b941dc00aa85341a9f81ccde6 AS base
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

FROM myrotvorets/node-min:latest@sha256:7f685352eb1e1dd47184d6e221879dc957103a5eca8d92cf29cd680f91467e20
USER root
RUN apk add --no-cache heirloom-mailx -X https://dl-cdn.alpinelinux.org/alpine/v3.17/community && install -d -o nobody -g nobody /srv/service
USER nobody:nobody
WORKDIR /srv/service
COPY --from=build --chown=nobody:nobody /srv/service/dist/ ./
COPY --chown=nobody:nobody entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
