# inspired by https://github.com/brisma/docker-android-sdk/blob/master/Dockerfile
FROM ubuntu:26.04

ARG ANDROID_CMAKE_VERSION=3.22.1
ARG ANDROID_PLATFORM_VERSION=35
ARG ANDROID_BUILD_TOOLS_VERSION=35.0.0
ARG PYTHON_VERSION=3.14
ARG LLVM_VERSION=23

# set noninteractive installation
ENV DEBIAN_FRONTEND noninteractive
ENV TZ=America/Phoenix

# ubuntu 26.04 ships python 3.14 as the system python3 (python-is-python3 provides /usr/bin/python).
RUN apt-get update \
 && apt-get -y install --no-install-recommends \
        build-essential \
        ca-certificates \
        clang \
        cmake \
        curl \
        git \
        ninja-build \
        openjdk-21-jdk \
        python-is-python3 \
        python3 \
        python3-dev \
        python3-venv \
        tzdata \
        unzip \
        wget \
        which \
 && python3 --version | grep -q "Python ${PYTHON_VERSION}\." \
 && rm -rf /var/lib/apt/lists/*

# Install clang-format/clang-tidy from apt.llvm.org (ubuntu 26.04 only ships up to llvm 22).
# clang-format/clang-tidy in /usr/local/bin point to the versioned binaries.
RUN install -d -m 0755 /etc/apt/keyrings \
 && curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key -o /etc/apt/keyrings/apt.llvm.org.asc \
 && printf '%s\n' \
        "Types: deb" \
        "URIs: http://apt.llvm.org/resolute/" \
        "Suites: llvm-toolchain-resolute-${LLVM_VERSION}" \
        "Components: main" \
        "Signed-By: /etc/apt/keyrings/apt.llvm.org.asc" \
        > /etc/apt/sources.list.d/apt.llvm.org.sources \
 && apt-get update \
 && apt-get -y install --no-install-recommends \
        clang-format-${LLVM_VERSION} \
        clang-tidy-${LLVM_VERSION} \
 && ln -sf /usr/bin/clang-format-${LLVM_VERSION} /usr/local/bin/clang-format \
 && ln -sf /usr/bin/clang-tidy-${LLVM_VERSION} /usr/local/bin/clang-tidy \
 && clang-format --version | grep -q "version ${LLVM_VERSION}\." \
 && clang-tidy --version | grep -q "version ${LLVM_VERSION}\." \
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
ENV ANDROID_NDK_VERSION="30.0.16248370"
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

# Add path access to the android commands (sdkmanager, avdmanager, adb, ...)
ENV PATH=${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin:${ANDROID_SDK_ROOT}/platform-tools:$PATH

# Install the android sdk packages we need
WORKDIR ${ANDROID_SDK_ROOT}
RUN mkdir -p ${HOME}/.android \
 && touch ${HOME}/.android/repositories.cfg \
 && mkdir -p ${GRADLE_HOME} \
 && echo systemProp.java.net.useSystemProxies=true >${GRADLE_HOME}/gradle.properties \
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