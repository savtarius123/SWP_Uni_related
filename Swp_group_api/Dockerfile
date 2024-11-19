# Use the official Dart image as the base image
FROM dart:stable

# Expose the ports for the Dart server (8080), MailHog (8025), and SMTP (1025)
EXPOSE 8080 8025 1025

# Set the working directory inside the container
WORKDIR /app

# Install dependencies: Nginx, SQLite
RUN apt-get update && \
    apt-get install -y wget sqlite3 libsqlite3-dev nginx

# Remove the default Nginx configuration
RUN rm /etc/nginx/sites-enabled/default

# Copy custom Nginx configuration into the container
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy all project content to the working directory
COPY . .

# Install Dart dependencies
RUN dart pub get

# Build the Dart project
RUN dart pub run build_runner build --delete-conflicting-outputs

# Install MailPit
RUN curl -O https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh && \
    chmod +x install.sh && \
    ./install.sh

# Start MailPit, Dart server, and Nginx
CMD /usr/local/bin/mailpit --smtp-auth-allow-insecure --smtp-auth-file smtp_auth.txt & \
    dart bin/backend.dart & \
    nginx -g 'daemon off;'