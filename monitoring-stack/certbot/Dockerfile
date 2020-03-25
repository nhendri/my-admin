# Set in .env file
ARG CERTBOT_VERSION

# Just using the official image, found at https://hub.docker.com/r/certbot/certbot/
FROM certbot/certbot:${CERTBOT_VERSION}

# Additional config goes here - I don't think we can do the inital cert getting in the image build config though, sadly. Has to 
#   be one of those borky init-steps-at-runtime things. See readme for more info..
