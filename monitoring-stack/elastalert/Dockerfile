FROM python:3.6-alpine3.10

# Set in .env file
ARG SENDGRID_API_KEY
ARG ELASTALERT_VERSION

# Could be set somewhere I suppose, but why...
ENV ELASTALERT_HOME /opt/elastalert

# Add nodeuser
RUN addgroup -g 1000 node && adduser -u 1000 -G node -s /bin/sh -D node

WORKDIR /opt

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories && \
  # This needs to go here because there's some package conflict somewhere in the nodejs packages vs the ones needed to install the python app...
  apk add --no-cache nodejs-current=13.1.0-r0 npm --repository="http://dl-cdn.alpinelinux.org/alpine/edge/community" && \
  # packages for python app
  apk add --update --no-cache ca-certificates openssl-dev openssl libffi-dev gcc musl-dev && \
  # packages for node app
  apk add --update --no-cache git curl tzdata make libmagic && \
  # my packages cuz yeah
  apk add --update --no-cache vim && \
  wget -O elastalert.zip "https://github.com/Yelp/elastalert/archive/${ELASTALERT_VERSION}.zip" && \
  unzip elastalert.zip && \
  rm elastalert.zip && \
  mv e* "${ELASTALERT_HOME}"

WORKDIR ${ELASTALERT_HOME}

RUN sed -i 's/jira>=1.0.10/jira>=1.0.10,<1.0.15/g' setup.py && \
  python setup.py install && \
  pip install -r requirements.txt

# Create SMTP auth config using our Sendgrid API key
RUN printf "user: \"apikey\"\npassword: \"${SENDGRID_API_KEY}\"\n" > "${ELASTALERT_HOME}/smtp_auth.yaml"

WORKDIR /opt/elastalert-server

# "Clone" into existing directory 
RUN git init && \
  git remote add origin https://github.com/bitsensor/elastalert.git && \
  git fetch && \
  git checkout origin/master -ft && \
  npm install --production --quiet && \
  mkdir -p /opt/elastalert/rules/ /opt/elastalert/server_data/tests/ && chown -R node:node /opt

EXPOSE 3030 3333

USER node

ENTRYPOINT ["npm", "start"]
