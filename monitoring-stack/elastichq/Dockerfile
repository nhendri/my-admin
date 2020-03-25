# Set in .env file
ARG ELASTICHQ_VERSION

# Just using the official image, found at https://hub.docker.com/r/elastichq/elasticsearch-hq
FROM elastichq/elasticsearch-hq:${ELASTICHQ_VERSION}

# Additional config goes here - not putting the .conf file into the image, though; rather, it's a runtime mount (see docker-compose.yml config) 
