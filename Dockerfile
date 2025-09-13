# inspired by https://github.com/brisma/docker-android-sdk/blob/master/Dockerfile
FROM ubuntu:24.04

ARG ANDROID_CMAKE_VERSION=3.22.1
ARG ANDROID_PLATFORM_VERSION=35
ARG ANDROID_BUILD_TOOLS_VERSION=35.0.0

# set noninteractive installation
ENV DEBIAN_FRONTEND noninteractive
ENV TZ=America/Phoenix

RUN apt-get update \
 && apt-get -y install --no-install-recommends \
        build-essential \
        clang \
        cmake \
        curl \
        git \
        ninja-build \
        openjdk-21-jre-headless \
        python3 \
        software-properties-common \
        tzdata \
        unzip \
        wget \
 && rm -rf /var/lib/apt/lists/*

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

USER ubuntu
ENV HOME=/home/ubuntu
WORKDIR ${HOME}

ENV GRADLE_HOME=${HOME}/.gradle

# Get the latest version from https://developer.android.com/studio/index.html
#ENV ANDROID_SDK_VERSION="4333796"
#ENV ANDROID_SDK_VERSION="6609375"
#ENV ANDROID_SDK_VERSION="8512546"
ENV ANDROID_SDK_VERSION="11076708"
ENV ANDROID_NDK_VERSION="27.3.13750724"
ENV ANDROID_HOME ${HOME}/android-sdk
ENV ANDROID_SDK_ROOT ${HOME}/android-sdk

# Android SDK tools ($HOME/android-sdk)
#  wget -nv -O android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
# https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip
# https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip
RUN mkdir ${ANDROID_SDK_ROOT} \
 && wget -nv -O android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip \
 && mkdir ${ANDROID_SDK_ROOT}/cmdline-tools \
 && unzip -q android-sdk.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
 && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/tools \
 && rm android-sdk.zip

 # Add path access to the android commands
ENV PATH=${ANDROID_SDK_ROOT}/tools:${ANDROID_SDK_ROOT}/bin:$PATH

# Install the android sdk packages we need
WORKDIR ${ANDROID_SDK_ROOT}
RUN mkdir -p ${HOME}/.android \
 && touch ${HOME}/.android/repositories.cfg \
 && mkdir -p ${GRADLE_HOME} \
 && echo systemProp.java.net.useSystemProxies=true >gradle.properties \
 && echo "Accepting licenses" \
 && (yes | cmdline-tools/tools/bin/sdkmanager --licenses) \
 && echo "Install android-${ANDROID_PLATFORM_VERSION}" \
 && cmdline-tools/tools/bin/sdkmanager "platforms;android-${ANDROID_PLATFORM_VERSION}" \
 && echo "Install build-tools-${ANDROID_BUILD_TOOLS_VERSION}" \
 && cmdline-tools/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
 && echo "Install cmake ${ANDROID_CMAKE_VERSION}" \
 && cmdline-tools/tools/bin/sdkmanager "cmake;${ANDROID_CMAKE_VERSION}" \
 && echo "Install ndk ${ANDROID_NDK_VERSION}" \
 && cmdline-tools/tools/bin/sdkmanager "ndk;${ANDROID_NDK_VERSION}" \
 && echo "Install platform-tools" \
 && cmdline-tools/tools/bin/sdkmanager "platform-tools" \
 && echo "Accepting licenses" \
 && (yes | cmdline-tools/tools/bin/sdkmanager --licenses) \
 && echo "Updating" \
 && cmdline-tools/tools/bin/sdkmanager --update \
 && echo "Accepting licenses" \
 && (yes | cmdline-tools/tools/bin/sdkmanager --licenses) \
 && echo Android sdk ready

WORKDIR ${HOME}

# Support Gradle
ENV TERM dumb
ENV JAVA_OPTS "-Xms512m -Xmx2048m"
ENV GRADLE_OPTS "-XX:+UseG1GC -XX:MaxGCPauseMillis=1000"

ENV ANDROID_NDK ${ANDROID_SDK_ROOT}/ndk/${ANDROID_NDK_VERSION}