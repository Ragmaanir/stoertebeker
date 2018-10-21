# How to get rid of xvfb?
# https://github.com/electron/electron/blob/master/docs/tutorial/testing-on-headless-ci.md
# https://github.com/SeleniumHQ/docker-selenium/issues/520#issuecomment-315733085

FROM ubuntu:16.04
WORKDIR /root

ENV PATH="/root/bin:${PATH}"

RUN apt-get update
RUN apt-get -y install wget vim git gcc libgtk-3-0 libxss1 libnss3 libasound2 xvfb

RUN mkdir applications
RUN mkdir bin

# ----- NODEJS -----
ENV NODE_VERSION=v8.12.0
RUN wget https://nodejs.org/download/release/$NODE_VERSION/node-$NODE_VERSION-linux-x64.tar.gz
RUN tar -xvf node-$NODE_VERSION-linux-x64.tar.gz
RUN mv ./node-$NODE_VERSION-linux-x64 ./applications/node
RUN ln -s /root/applications/node/bin/node /root/bin/node && chmod +x /root/bin/node
RUN ln -s /root/applications/node/bin/npm /root/bin/npm && chmod +x /root/bin/npm

# ----- CRYSTAL -----
RUN apt-get -y install libxml2-dev libssl-dev libreadline-dev libgmp-dev libyaml-dev libpcre3-dev libevent-dev

RUN wget https://github.com/crystal-lang/crystal/releases/download/0.26.1/crystal-0.26.1-1-linux-x86_64.tar.gz
RUN tar -xvf crystal-0.26.1-1-linux-x86_64.tar.gz
RUN mv crystal-0.26.1-1 applications/crystal
RUN ln -s /root/applications/crystal/bin/crystal ./bin/crystal
RUN ln -s /root/applications/crystal/bin/shards ./bin/shards
RUN chmod +x ./bin/crystal
RUN chmod +x ./bin/shards

# ----- NODEJS -----
ADD ./browser/package.json /root/self/browser/package.json
ADD ./browser/package-lock.json /root/self/browser/package-lock.json

RUN cd /root/self/browser && \
    npm install --unsafe-perm=true --allow-root

RUN npm i -g typescript
RUN cd /root/bin && \
    ln -s /root/applications/node/bin/tsc tsc && \
    ln -s /root/applications/node/bin/tsserver tsserver

ADD ./shard.yml /root/self
ADD ./shard.lock /root/self

RUN cd self && shards install

ADD ./bin /root/self/bin
ADD ./spec /root/self/spec
ADD ./test /root/self/test
ADD ./browser /root/self/browser
ADD ./src /root/self/src

RUN mkdir self/temp
