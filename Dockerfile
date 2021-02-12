FROM alpine:3.13 AS base
RUN apk add --no-cache nodejs && install -d -o nobody -g nobody /srv/service
WORKDIR /srv/service

FROM base AS base-build
RUN apk add --no-cache npm && mkdir /.npm && chown nobody:nobody /.npm /srv/service
ENV NPM_CONFIG_FUND=0 NPM_CONFIG_AUDIT=0 SUPPRESS_SUPPORT=1 NO_UPDATE_NOTIFIER=true
USER nobody:nobody

FROM base-build AS build
COPY ./package.json ./package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM base
USER nobody:nobody
ENTRYPOINT ["/usr/bin/node", "index.js"]
COPY --from=build --chown=nobody:nobody /srv/service/dist/ ./
