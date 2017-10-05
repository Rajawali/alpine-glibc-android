FROM frolvlad/alpine-glibc:alpine-3.5

#################################
# Install openjdk 8
#################################
ENV LANG C.UTF-8
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u121
ENV JAVA_ALPINE_VERSION 8.121.13-r0

RUN set -x \
	&& apk add --no-cache \
		openjdk8="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]
#################################

ARG ANDROID_TARGET_SDK=26
ARG ANDROID_BUILD_TOOLS=26.0.2
ARG ANDROID_SDK_TOOLS=3859397

ENV ANDROID_HOME=${PWD}/android-sdk-linux
ENV PATH=${PATH}:${ANDROID_HOME}/platform-tools
ENV PATH=${PATH}:${ANDROID_HOME}/tools
ENV PATH=${PATH}:${ANDROID_HOME}/tools/bin

RUN apk add --no-cache ca-certificates wget \
 && update-ca-certificates \
 && wget -q -O android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS}.zip \
 && mkdir ${ANDROID_HOME} \
 && unzip -qo android-sdk.zip -d ${ANDROID_HOME} \
 && chmod +x ${ANDROID_HOME}/tools/android \
 && rm android-sdk.zip \
 && mkdir -p ~/.gradle \
 && echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties \
 && mkdir ~/.android \
 && touch ~/.android/repositories.cfg \
 && yes | sdkmanager --licenses > /dev/null \
 && sdkmanager --update > /dev/null \
 && sdkmanager "platforms;android-${ANDROID_TARGET_SDK}" "build-tools;${ANDROID_BUILD_TOOLS}" platform-tools > /dev/null

# Install NDK
RUN wget -q -O android-ndk.zip https://dl.google.com/android/repository/android-ndk-r13b-linux-x86_64.zip \
 && unzip -qo android-ndk.zip

ENV ANDROID_NDK=${PWD}/android-ndk-r13b
ENV PATH=${PATH}:${ANDROID_NDK}

# Install libstdc++6, gpg, and cmake
RUN apk add --no-cache libstdc++ gnupg \
 && wget -q -O install-cmake.sh https://github.com/Commit451/android-cmake-installer/releases/download/1.1.0/install-cmake.sh \
 && chmod +x install-cmake.sh \
 && ./install-cmake.sh
