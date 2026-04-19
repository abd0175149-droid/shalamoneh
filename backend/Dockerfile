# ═══════════════════════════════════════
# Shalmoneh Backend — Dockerfile (Multi-stage)
# ═══════════════════════════════════════

# Stage 1: Build
FROM dart:stable AS build
WORKDIR /app

# Copy pubspec first for better caching
COPY pubspec.* ./
RUN dart pub get

# Copy source and compile
COPY . .
RUN dart compile exe bin/server.dart -o bin/server

# Stage 2: Runtime (minimal image)
FROM ubuntu:24.04 AS runtime
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy compiled binary
COPY --from=build /app/bin/server /app/bin/server
COPY --from=build /app/.env /app/.env

# Admin panel static files
COPY --from=build /app/admin/ /app/admin/

EXPOSE 4050

ENV PORT=4050
ENV HOST=0.0.0.0

CMD ["/app/bin/server"]
