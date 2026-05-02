# Use Nginx to serve the static files
FROM nginx:alpine

# Copy the build/web folder produced by scripts/build_web.ps1 or scripts/build_web.sh
# (flutter build web --release). Flutter 3.29+ uses CanvasKit/Skwasm only; the legacy
# HTML/DOM renderer is no longer available—see web/flutter_bootstrap.js and
# https://docs.flutter.dev/platform-integration/web/renderers
COPY build/web /usr/share/nginx/html

# Expose port 8080 for Cloud Run
EXPOSE 8080

# Configure Nginx to listen on 8080
RUN sed -i 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]