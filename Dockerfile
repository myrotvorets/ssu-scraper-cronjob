FROM myrotvorets/node:latest@sha256:d0f2d05319e3a19fc2546e3a5ae2fe35f4615420d6ea960fb6fef93ca42dbbd5 AS base
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

FROM myrotvorets/node-min:latest@sha256:3513d3aa1c630b0894806de4dc51004cba04ea6315704b04327761e13545f1e4
USER root
RUN apk add --no-cache heirloom-mailx && install -d -o nobody -g nobody /srv/service
USER nobody:nobody
WORKDIR /srv/service
COPY --from=build --chown=nobody:nobody /srv/service/dist/ ./
COPY --chown=nobody:nobody entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
