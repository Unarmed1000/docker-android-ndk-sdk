# inspired by https://github.com/brisma/docker-android-sdk/blob/master/Dockerfile
FROM ubuntu:16.04

RUN apt-get update \
 && apt-get -y install --no-install-recommends \
        build-essential \
        curl \
        git \
        python3 \
        software-properties-common \
        unzip \
        wget \
 && apt-add-repository -y ppa:openjdk-r/ppa \
 && apt-get update \
 && apt-get install -y \
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
ENV ANDROID_SDK_VERSION="3859397"
ENV ANDROID_HOME ${HOME}/android-sdk

# Android SDK tools ($HOME/android-sdk)
#  wget -nv -O android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip \ 
RUN mkdir ${ANDROID_HOME} \
 && wget -nv -O android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
 && unzip -q android-sdk.zip -d ${ANDROID_HOME} \
 && rm android-sdk.zip

 # Add path access to the android commands
ENV PATH=${ANDROID_HOME}/tools:${ANDROID_HOME}/bin:$PATH

# Get the latest version from https://developer.android.com/ndk/downloads/index.html
ENV ANDROID_NDK_VERSION="15c"
 
# Beware the script currently relies on the content of the downloaded NDK
# to contain a directory named android-ndk-${ANDROID_NDK_VERSION}
# so dont mess too much with the home location
ENV ANDROID_NDK ${HOME}/android-ndk-r${ANDROID_NDK_VERSION}
ENV ANDROID_NDK_HOME ${ANDROID_NDK}
 
# Android NDK ($HOME/android-ndk-r16b)
# wget -nv -O android-ndk.zip https://dl.google.com/android/repository/android-ndk-r16b-linux-x86_64.zip
RUN wget -nv -O android-ndk.zip https://dl.google.com/android/repository/android-ndk-r${ANDROID_NDK_VERSION}-linux-x86_64.zip \
 && unzip -q android-ndk.zip \
 && rm android-ndk.zip


# Install the android sdk packages we need
WORKDIR ${ANDROID_HOME}
RUN mkdir ${HOME}/.android \
 && touch ${HOME}/.android/repositories.cfg \
 && echo "Install android-24" \
 && tools/bin/sdkmanager "platforms;android-24" \
 && echo "Install build-tools-25.0.3" \
 && tools/bin/sdkmanager "build-tools;25.0.3" \ 
 && echo "Accepting licenses" \
 && (yes | tools/bin/sdkmanager --licenses) \
 && echo "Updating" \
 && tools/bin/sdkmanager --update \
 && echo Android sdk ready

WORKDIR $HOME

# Support Gradle
ENV TERM dumb
ENV JAVA_OPTS "-Xms512m -Xmx1536m"
ENV GRADLE_OPTS "-XX:+UseG1GC -XX:MaxGCPauseMillis=1000"
