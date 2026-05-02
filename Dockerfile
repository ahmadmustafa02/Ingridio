# Multi-stage: compile Flutter web in the image (build/web is not in Git).
# Stage 1 — Flutter web release build
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
# pubspec lists assets/.env; it is gitignored locally so Cloud Build has no file unless we add one.
RUN printf 'GEMINI_API_KEY=\n' > assets/.env
RUN flutter build web --release

# Stage 2 — static hosting
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 8080

RUN sed -i 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
