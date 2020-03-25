# Set in .env file
ARG NGINX_CONTAINER_VERSION

# Just using the official image, found at https://hub.docker.com/_/nginx
FROM nginx:${NGINX_CONTAINER_VERSION}

# Additional config goes here - not putting the .conf file into the image, though; rather, it's a runtime mount (see docker-compose.yml config)
