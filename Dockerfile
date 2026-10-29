FROM node:24.14.0 AS builder 
WORKDIR /app
ENV CI=true
RUN npm install -g pnpm@10
COPY . .  
RUN pnpm run bootstrap
RUN pnpm install --frozen-lockfile
RUN pnpm --filter=nocodb exec rspack --config rspack.timely.config.js
RUN pnpm --filter=nc-gui exec nuxt generate
RUN cp -r packages/nc-gui/.output/public packages/nocodb/docker/nc-gui
RUN pnpm --filter=nocodb --prod deploy ./node_modules-v1 --legacy  --frozen-lockfile 

FROM node:24.14.0-slim AS runtime
WORKDIR /app
COPY --from=builder /app/packages/nocodb/docker ./packages/nocodb/docker
COPY --from=builder /app/node_modules-v1/node_modules  ./node_modules
EXPOSE 8080
CMD ["node", "packages/nocodb/docker/main.js"]

