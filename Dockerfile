FROM nginx:1.27-alpine

RUN rm /etc/nginx/conf.d/default.conf

# Copy static assets into the default nginx public directory
COPY index.html /usr/share/nginx/html/index.html
COPY styles.css /usr/share/nginx/html/styles.css
COPY script.js /usr/share/nginx/html/script.js

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8090
CMD ["nginx", "-g", "daemon off;"]
