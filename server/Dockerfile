# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:stable AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    libsqlite3-0 \
 && rm -rf /var/lib/apt/lists/*

# Resolve app dependencies.
WORKDIR /app

COPY pubspec.* ./

COPY packages/ ./packages/

RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline 
RUN dart build cli -o output

# Build minimal serving image from AOT-compiled `bin/main`
FROM debian:13-slim

# Copy application
COPY --from=build /app/output/bundle/ /app/

# Copy sqlite runtime libs (glibc)
COPY --from=build /usr/lib/*-linux-gnu/libsqlite3.so* /usr/lib/libsqlite3.so

# Optional: CA certs if you do HTTPS
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Start server.
EXPOSE 8080
CMD ["/app/bin/vanestack", "start"]
