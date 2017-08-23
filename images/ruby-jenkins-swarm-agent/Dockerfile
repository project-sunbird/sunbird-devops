FROM vfarcic/jenkins-swarm-agent
MAINTAINER Shashank Teotia <shashankteotia@gmail.com>

ENV LANGUAGE=en_US
ENV LANG=en_US.UTF-8
ENV JEKYLL_VERSION=3.5
ENV JEKYLL_ENV=development
ENV TZ=America/Chicago
ENV LC_ALL=en_US

RUN apk update
RUN apk add zlib-dev build-base libxml2-dev \
  libxslt-dev readline-dev libffi-dev ruby-dev \
  yaml-dev zlib-dev libffi-dev less

RUN apk add zlib libxml2 ruby-io-console \
  readline libxslt ruby yaml libffi ruby-irb \
  ruby-json ruby-rake ruby-rdoc git openssl \
  nodejs tzdata

RUN yes | gem install --force --no-ri --no-rdoc jekyll -v 3.5

RUN mkdir -p /usr/share/ruby
RUN gem install bundler --no-ri --no-rdoc
RUN gem clean

RUN mkdir -p /srv/jekyll 
# && chown -R jekyll:jekyll /srv/jekyll
# RUN echo 'jekyll ALL=NOPASSWD:ALL' >> /etc/sudoers
# RUN cleanup

# WORKDIR /srv/jekyll
# CMD ["jekyll", "--help"]
# VOLUME  /srv/jekyll
# EXPOSE 35729 4000

