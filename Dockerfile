FROM node:14-alpine AS development
ARG NPM_AUTH_TOKEN
WORKDIR /usr/src/app
ENV NODE_ENV development
ENV NPM_CONFIG_CACHE /usr/src/app/cache/npm
ENV XDG_CONFIG_HOME /usr/src/app/cache/
COPY . .
RUN npm install && npm run build

FROM node:14-alpine AS build
ARG NPM_AUTH_TOKEN
WORKDIR /usr/src/app
ENV NODE_ENV production
ENV NPM_CONFIG_CACHE /usr/src/app/cache/npm
ENV XDG_CONFIG_HOME /usr/src/app/cache/
COPY ["package.json", "package-lock.json*", "./"]
COPY . .
RUN npm install --production && npm run build


FROM node:14-alpine AS production
WORKDIR /usr/src/app
RUN chown 1000:1000 $(pwd)
ENV NODE_ENV production
USER node
COPY --chown=node:node ["package.json", "package-lock.json", "./"]
COPY --chown=node:node --from=build /usr/src/app/node_modules /usr/src/app/node_modules
COPY --chown=node:node --from=build /usr/src/app/dist /usr/src/app/dist
EXPOSE 3000
CMD npm run start:prod
