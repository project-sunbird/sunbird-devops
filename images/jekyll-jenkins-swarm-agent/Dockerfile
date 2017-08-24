FROM vfarcic/jenkins-swarm-agent
MAINTAINER Shashank Teotia <shashankteotia@gmail.com>

ENV LANGUAGE=en_US
ENV LANG=en_US.UTF-8
ENV JEKYLL_VERSION=2.5.3
ENV JEKYLL_ENV=production
ENV TZ=Asia/Calcutta
ENV LC_ALL=en_US

RUN apk update
RUN apk add zlib-dev build-base libxml2-dev \
  libxslt-dev readline-dev libffi-dev ruby-dev \
  yaml-dev zlib-dev libffi-dev less

RUN apk add zlib libxml2 ruby-io-console \
  readline libxslt ruby yaml libffi ruby-irb \
  ruby-json ruby-rake ruby-rdoc git openssl \
  nodejs tzdata python nodejs-npm
  
RUN npm install npm@latest -g

RUN yes | gem install --force --no-ri --no-rdoc jekyll -v ${JEKYLL_VERSION}

RUN mkdir -p /usr/share/ruby
RUN gem install bundler --no-ri --no-rdoc
RUN gem clean
RUN cleanup

# WORKDIR /srv/jekyll
# CMD ["jekyll", "--help"]
# VOLUME  /srv/jekyll
# EXPOSE 35729 4000

