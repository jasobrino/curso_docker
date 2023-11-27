
FROM node:19-alpine3.15 as dev
WORKDIR /app
COPY package.json ./
RUN yarn install
CMD [ "yarn","start:dev" ]

FROM node:19-alpine3.15 as dev-deps
WORKDIR /app
COPY package.json package.json
#RUN echo 'Acquire::http::Proxy  "http://proxyweb.catastro.minhac.es:80/";' >> /etc/apt/apt.conf.d/01proxy
#RUN echo 'Acquire::https::Proxy "http://proxyweb.catastro.minhac.es:80/";' >> /etc/apt/apt.conf.d/01proxy
RUN yarn install --frozen-lockfile


FROM node:19-alpine3.15 as builder
WORKDIR /apps
COPY --from=dev-deps /app/node_modules ./node_modules
COPY . .
# RUN yarn test
RUN yarn build

FROM node:19-alpine3.15 as prod-deps
WORKDIR /app
COPY package.json package.json
RUN yarn install --prod --frozen-lockfile


FROM node:19-alpine3.15 as prod
EXPOSE 3001
WORKDIR /app
ENV APP_VERSION=${APP_VERSION}
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

CMD [ "node","dist/main.js"]









