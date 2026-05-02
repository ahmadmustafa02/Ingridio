# Stage 1 — Flutter web release build
FROM ghcr.io/cirruslabs/flutter:3.41.0 AS build 
WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# Ensure the .env file exists so the build doesn't crash, 
# but the --dart-define will override its content in the app logic.
RUN mkdir -p assets && printf 'GEMINI_API_KEY=\n' > assets/.env

# The ARG must be here to receive the --build-arg from Cloud Build
ARG GEMINI_API_KEY
RUN flutter build web --release \
    --dart-define=GEMINI_API_KEY="${GEMINI_API_KEY}"

# Stage 2 — static hosting
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 8080
RUN sed -i 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]