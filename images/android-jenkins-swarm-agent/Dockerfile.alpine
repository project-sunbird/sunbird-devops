FROM vfarcic/jenkins-swarm-agent

# Installs Android SDK
ENV ANDROID_SDK_FILENAME sdk-tools-linux-3859397.zip
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/${ANDROID_SDK_FILENAME}
ENV ANDROID_API_LEVELS android-25
ENV ANDROID_BUILD_TOOLS_VERSION 25.0.3
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin

RUN apk update && \
  apk add bash unzip openjdk7

RUN mkdir -p /opt/jenkins && mkdir -p /opt/android-sdk-linux && cd /opt/android-sdk-linux && \
  wget -q ${ANDROID_SDK_URL} && \
  unzip -a -q ${ANDROID_SDK_FILENAME} && \
  rm ${ANDROID_SDK_FILENAME}

RUN yes | sdkmanager --licenses && \
  sdkmanager "tools" "platform-tools" && \
  sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" && \
  sdkmanager "platforms;${ANDROID_API_LEVELS}" && \
  rm /var/cache/apk/*
