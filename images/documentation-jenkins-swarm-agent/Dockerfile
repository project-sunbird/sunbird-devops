FROM ubuntu:16.04

ARG "version=0.1.0-dev"
ARG "build_date=unknown"
ARG "commit_hash=unknown"
ARG "vcs_url=unknown"
ARG "vcs_branch=unknown"

LABEL org.label-schema.name="jenkins-swarm-agent" \
    org.label-schema.description="Jenkins agent based on the Swarm plugin"

ENV SWARM_CLIENT_VERSION 3.3
ENV DOCKER_COMPOSE_VERSION 1.11.2

# Switch to root
USER root
# Update everything
RUN apt -y update && apt -y upgrade
#Install Build Essentials
RUN apt install -y build-essential
RUN apt install -y zlib1g-dev
RUN apt install -y git
RUN apt install -y locales
RUN apt install -y openjdk-8-jre
RUN apt install -y python
RUN apt install -y python-pip
RUN apt install -y openssh-client
RUN apt install -y wget

#Install NPM
RUN apt install -y curl
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && apt install -y nodejs

# Install ruby and ruby-bundler
RUN apt install -y ruby-full
RUN gem install bundle
RUN gem install liquid-rails
RUN gem install documentation
RUN gem install branch_io
RUN gem install rubygems-update
RUN gem update --system

RUN locale-gen en_US.UTF-8
RUN export LANG=en_US.UTF-8
RUN export LANGUAGE=en_US:en
RUN export LC_ALL=en_US.UTF-8

RUN useradd -g root jenkins
#RUN adduser --help
#RUN adduser -ingroup root --disabled-password jenkins \
RUN wget -q https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_CLIENT_VERSION}/swarm-client-${SWARM_CLIENT_VERSION}.jar -P /home/jenkins/ \
 && pip install docker-compose

COPY ./images/documentation-jenkins-swarm-agent/run.sh /run.sh
RUN chmod +x /run.sh

CMD ["./run.sh"]
