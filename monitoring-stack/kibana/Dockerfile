# Set in .env file
ARG ELK_VERSION
ARG ELASTALERT_PLUGIN_VERSION

# Base Image Comes from https://www.docker.elastic.co/
FROM docker.elastic.co/kibana/kibana:${ELK_VERSION}

## Any custom build config goes here

## Elastalert Plugin
RUN /usr/share/kibana/bin/kibana-plugin install https://github.com/bitsensor/elastalert-kibana-plugin/releases/download/1.1.0/elastalert-kibana-plugin-1.1.0-7.4.2.zip && \
  # https://github.com/elastic/kibana/issues/19678#issuecomment-454377767 - keeping note of this right here for existing build issue with this plugin and workaround
  rm -rf /usr/share/kibana/optimize/bundles
