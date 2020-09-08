FROM alpine:3.12 AS base
RUN apk add --no-cache nodejs
WORKDIR /srv/service

FROM base AS base-build
RUN apk add --no-cache npm && mkdir /.npm && chown nobody:nogroup /.npm /srv/service
ENV NPM_CONFIG_FUND=0 NPM_CONFIG_AUDIT=0 SUPPRESS_SUPPORT=1 NO_UPDATE_NOTIFIER=true
USER nobody:nogroup

FROM base-build AS deps
COPY ./package.json ./package-lock.json ./
RUN npm ci --only=prod

FROM base-build AS build-deps
COPY ./package.json ./package-lock.json ./
RUN npm ci

FROM build-deps AS build
COPY . .
RUN npm run build

FROM base
USER nobody:nogroup
ENTRYPOINT ["/usr/bin/node", "index.js"]
COPY --from=build /srv/service/dist/ ./
COPY --from=deps /srv/service/node_modules ./node_modules
