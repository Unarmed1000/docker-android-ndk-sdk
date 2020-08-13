# inspired by https://github.com/brisma/docker-android-sdk/blob/master/Dockerfile
FROM ubuntu:20.04

# set noninteractive installation
ENV DEBIAN_FRONTEND noninteractive
ENV TZ=America/New_York

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
        openjdk-8-jdk \
 && rm -rf /var/lib/apt/lists/*

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
 
# Create the user that we will run this as
ENV HOME /home/builder
RUN useradd -c "builder" -d ${HOME} -m builder
USER builder
WORKDIR ${HOME}

# Get the latest version from https://developer.android.com/studio/index.html
#ENV ANDROID_SDK_VERSION="4333796"
ENV ANDROID_SDK_VERSION="6609375"
ENV ANDROID_HOME ${HOME}/android-sdk

# Android SDK tools ($HOME/android-sdk)
#  wget -nv -O android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip \ 
#  wget -nv -O android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
# https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip
# https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip
RUN mkdir ${ANDROID_HOME} \
 && wget -nv -O android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip \
 && mkdir ${ANDROID_HOME}/cmdline-tools \
 && unzip -q android-sdk.zip -d ${ANDROID_HOME}/cmdline-tools \
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
 && (yes | cmdline-tools/tools/bin/sdkmanager --licenses) \
 && echo "Install android-27" \
 && cmdline-tools/tools/bin/sdkmanager "platforms;android-27" \
 && echo "Install android-28" \
 && cmdline-tools/tools/bin/sdkmanager "platforms;android-28" \
 && echo "Install android-29" \
 && cmdline-tools/tools/bin/sdkmanager "platforms;android-29" \
 && echo "Install android-30" \
 && cmdline-tools/tools/bin/sdkmanager "platforms;android-30" \
 && echo "Install build-tools-25.0.3" \
 && cmdline-tools/tools/bin/sdkmanager "build-tools;25.0.3" \ 
 && echo "Install build-tools-26.0.2" \
 && cmdline-tools/tools/bin/sdkmanager "build-tools;26.0.2" \ 
 && echo "Install build-tools-27.0.3" \
 && cmdline-tools/tools/bin/sdkmanager "build-tools;27.0.3" \ 
 && echo "Install build-tools-28.0.3" \
 && cmdline-tools/tools/bin/sdkmanager "build-tools;28.0.3" \ 
 && echo "Install build-tools-28.0.3" \
 && cmdline-tools/tools/bin/sdkmanager "build-tools;28.0.3" \ 
 && echo "Install build-tools-29.0.2" \
 && cmdline-tools/tools/bin/sdkmanager "build-tools;29.0.2" \ 
 && echo "Install build-tools-30.0.2" \
 && cmdline-tools/tools/bin/sdkmanager "build-tools;30.0.2" \ 
 && echo "Install cmake 3.10.2" \
 && cmdline-tools/tools/bin/sdkmanager "cmake;3.10.2.4988404" \
 && echo "Install ndk 21.3.6528147" \
 && cmdline-tools/tools/bin/sdkmanager "ndk;21.3.6528147" \
 && echo "Install platform-tools" \
 && cmdline-tools/tools/bin/sdkmanager "platform-tools" \
 && echo "Accepting licenses" \
 && (yes | cmdline-tools/tools/bin/sdkmanager --licenses) \
 && echo "Updating" \
 && cmdline-tools/tools/bin/sdkmanager --update \
 && echo "Accepting licenses" \
 && (yes | cmdline-tools/tools/bin/sdkmanager --licenses) \
 && echo Android sdk ready

WORKDIR $HOME

# Support Gradle
ENV TERM dumb
ENV JAVA_OPTS "-Xms512m -Xmx1536m"
ENV GRADLE_OPTS "-XX:+UseG1GC -XX:MaxGCPauseMillis=1000"

