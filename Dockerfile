# syntax=docker/dockerfile:1

FROM oven/bun:1 AS builder

ENV NEXT_TELEMETRY_DISABLED=1

WORKDIR /app

COPY package.json bun.lock ./

RUN bun install --frozen-lockfile

COPY . .

RUN bun run build

FROM nginx:alpine AS runner

RUN sed -i 's/worker_processes.*/worker_processes 1;/' /etc/nginx/nginx.conf

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /app/out /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
