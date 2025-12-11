# Use the official lightweight nginx image
FROM nginx:alpine

# Remove default nginx config and put our custom one
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy site files to nginx webroot
COPY . /usr/share/nginx/html

# Ensure correct file permissions (optional)
RUN chmod -R 755 /usr/share/nginx/html

# Expose the same port as nginx.conf
EXPOSE 8095

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
