FROM cloudposse/jenkins-swarm-slave

USER root

RUN apt-get install -y unzip
RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-get update
RUN apt-get install -y openjdk-8-jdk

# Installs Android SDK
ENV ANDROID_SDK_FILENAME sdk-tools-linux-3859397.zip
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/${ANDROID_SDK_FILENAME}
ENV ANDROID_API_LEVELS android-25
ENV ANDROID_BUILD_TOOLS_VERSION 25.0.3
ENV ANDROID_HOME /opt/android-sdk-linux
ENV SWARM_CLIENT_VERSION 3.3
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin

RUN mkdir -p /opt/jenkins && mkdir -p /opt/android-sdk-linux && cd /opt/android-sdk-linux && \
  wget -q ${ANDROID_SDK_URL} && \
  unzip -a -q ${ANDROID_SDK_FILENAME} && \
  rm ${ANDROID_SDK_FILENAME}

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
RUN yes | sdkmanager --licenses
RUN sdkmanager "tools" "platform-tools"
RUN sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"
RUN sdkmanager "platforms;${ANDROID_API_LEVELS}"

RUN wget -q https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_CLIENT_VERSION}/swarm-client-${SWARM_CLIENT_VERSION}.jar -P /home/jenkins/

ADD ./images/android-jenkins-swarm-agent/custom-jenkins-slave.sh /opt/custom-jenkins-slave.sh

ENTRYPOINT /opt/custom-jenkins-slave.sh
