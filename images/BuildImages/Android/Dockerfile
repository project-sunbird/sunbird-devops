FROM circleci/android:api-25-alpha
USER root
WORKDIR work
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt install nodejs -y \
    # npm packages are not globally accessible in container
    && npm config set prefix /usr/local \
    # node-sass is not installing as it's executing external scripts
    && npm install -g ionic cordova node-sass --unsafe-perm \
    && apt-get clean && rm -rf /var/lib/apt/lists/ \
    && chown -R circleci:circleci /home/circleci
