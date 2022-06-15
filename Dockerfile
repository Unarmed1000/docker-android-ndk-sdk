# inspired by https://github.com/brisma/docker-android-sdk/blob/master/Dockerfile
FROM ubuntu:20.04

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
        python3 \
        software-properties-common \
        tzdata \
        unzip \
        wget \
        openjdk-11-jre-headless \
 && rm -rf /var/lib/apt/lists/*

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/
 
# Create the user that we will run this as
ENV LOCAL_SDK /sdks
WORKDIR ${LOCAL_SDK}

# Get the latest version from https://developer.android.com/studio/index.html
#ENV ANDROID_SDK_VERSION="4333796"
#ENV ANDROID_SDK_VERSION="6609375"
ENV ANDROID_SDK_VERSION="8512546"
ENV ANDROID_HOME ${LOCAL_SDK}/android-sdk

# Android SDK tools ($LOCAL_SDK/android-sdk)
#  wget -nv -O android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip \ 
#  wget -nv -O android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
# https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip
# https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip
RUN mkdir ${ANDROID_HOME} \
 && wget -nv -O android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip \
 && mkdir ${ANDROID_HOME}/cmdline-tools \
 && unzip -q android-sdk.zip -d ${ANDROID_HOME} \
 && rm android-sdk.zip

 # Add path access to the android commands
ENV PATH=${ANDROID_HOME}/tools:${ANDROID_HOME}/bin:$PATH


# Install the android sdk packages we need
WORKDIR ${ANDROID_HOME}
RUN mkdir -p ${HOME}/.android \
 && touch ${HOME}/.android/repositories.cfg \
 && mkdir -p ${HOME}/.gradle \
 && echo systemProp.java.net.useSystemProxies=true >gradle.properties \
 && echo "Accepting licenses" \
 && (yes | cmdline-tools/bin/sdkmanager --licenses) \
 && echo "Install android-27" \
 && cmdline-tools/bin/sdkmanager "platforms;android-27" \
 && echo "Install android-28" \
 && cmdline-tools/bin/sdkmanager "platforms;android-28" \
 && echo "Install android-29" \
 && cmdline-tools/bin/sdkmanager "platforms;android-29" \
 && echo "Install android-30" \
 && cmdline-tools/bin/sdkmanager "platforms;android-30" \
 && echo "Install android-31" \
 && cmdline-tools/bin/sdkmanager "platforms;android-31" \
 && echo "Install android-32" \
 && cmdline-tools/bin/sdkmanager "platforms;android-32" \
 && echo "Install build-tools-25.0.3" \
 && cmdline-tools/bin/sdkmanager "build-tools;25.0.3" \ 
 && echo "Install build-tools-26.0.2" \
 && cmdline-tools/bin/sdkmanager "build-tools;26.0.2" \ 
 && echo "Install build-tools-27.0.3" \
 && cmdline-tools/bin/sdkmanager "build-tools;27.0.3" \ 
 && echo "Install build-tools-28.0.3" \
 && cmdline-tools/bin/sdkmanager "build-tools;28.0.3" \ 
 && echo "Install build-tools-28.0.3" \
 && cmdline-tools/bin/sdkmanager "build-tools;28.0.3" \ 
 && echo "Install build-tools-29.0.2" \
 && cmdline-tools/bin/sdkmanager "build-tools;29.0.2" \ 
 && echo "Install build-tools-30.0.2" \
 && cmdline-tools/bin/sdkmanager "build-tools;30.0.2" \ 
 && echo "Install build-tools-32.0.0" \
 && cmdline-tools/bin/sdkmanager "build-tools;32.0.0" \ 
 && echo "Install build-tools-33.0.0" \
 && cmdline-tools/bin/sdkmanager "build-tools;33.0.0" \ 
 && echo "Install cmake 3.18.1" \
 && cmdline-tools/bin/sdkmanager "cmake;3.18.1" \
 && echo "Install ndk 23.2.8568313" \
 && cmdline-tools/bin/sdkmanager "ndk;23.2.8568313" \
 && echo "Install platform-tools" \
 && cmdline-tools/bin/sdkmanager "platform-tools" \
 && echo "Accepting licenses" \
 && (yes | cmdline-tools/bin/sdkmanager --licenses) \
 && echo "Updating" \
 && cmdline-tools/bin/sdkmanager --update \
 && echo "Accepting licenses" \
 && (yes | cmdline-tools/bin/sdkmanager --licenses) \
 && echo Android sdk ready

WORKDIR $LOCAL_SDK

# Support Gradle
ENV TERM dumb
ENV JAVA_OPTS "-Xms512m -Xmx1536m"
ENV GRADLE_OPTS "-XX:+UseG1GC -XX:MaxGCPauseMillis=1000"

ENV ANDROID_NDK ${ANDROID_HOME}/ndk/23.2.8568313
