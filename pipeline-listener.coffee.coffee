FROM alpine

# Install dependencies
RUN apk update && apk upgrade \
  && apk add redis \
  && apk add --update npm \
  && apk add python3 \
  && apk add --update py-pip \
  && npm install -g coffeescript \
  && npm install -g yo generator-hubot \
  && apk --purge -v del py-pip \
  && rm -rf /var/cache/apk/*

# Create hubot user
RUN adduser -h /hubot -s /bin/bash -S hubot
USER  hubot
WORKDIR /hubot

# Install hubot
RUN yo hubot --owner="ger" --name="gerbot" --description="Roll, roll, rollercoaster" --defaults
COPY package.json package.json
RUN npm install --save
ADD hubot/external-scripts.json /hubot/

# Overwriting start script https://github.com/noqcks/alpine-hubot/issues/2
ADD bin/hubot bin/ 

EXPOSE 80

# And go
ENTRYPOINT ["/bin/sh", "-c", "bin/hubot --adapter slack"]
https://github.com/noqcks/alpine-hubot
