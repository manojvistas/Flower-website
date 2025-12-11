# Dockerfile
FROM nginx:alpine
# replace default site config with our nginx.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
# copy all site files into nginx webroot
COPY . /usr/share/nginx/html
EXPOSE 8090
# nginx:alpine already has an appropriate CMD

