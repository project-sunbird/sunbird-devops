FROM ubuntu:16.04

# Switch to root
USER root

# Work Directory
WORKDIR project/installations/

# Update everything
RUN apt-get update

# Install Dependencies
RUN apt-get install -y build-essential=12.1ubuntu2 \
					   zlib1g-dev=1:1.2.8.dfsg-2ubuntu4.1 \
					   locales=2.23-0ubuntu9 \
					   curl \
					   git \
					   openjdk-8-jre \
					   ssh
					   
# Install Ruby & Gems
RUN apt-get install -y ruby-full=1:2.3.0+1
RUN mkdir -p /usr/share/ruby
COPY Gemfile /project/installations/
COPY Gemfile.lock /project/installations/
RUN gem install bundler --no-ri --no-rdoc
RUN bundle install --system
RUN gem clean

# Install AWS-CLI
RUN apt-get install -y python python-pip groff
RUN pip install --upgrade pip
RUN pip install awscli

# Install NPM
# RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && apt-get install -y nodejs

# Environment Setup
ENV TZ=Asia/Calcutta
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8
