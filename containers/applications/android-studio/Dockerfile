FROM debian:stable-slim

# Download Android Studio
ARG ANDROID_STUDIO_VERSION=2024.2.1.11
ARG ANDROID_STUDIO_URL="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${ANDROID_STUDIO_VERSION}/android-studio-${ANDROID_STUDIO_VERSION}-linux.tar.gz"
ARG ANDROID_STUDIO_SHA256="81f2fa5da72ab6f6afacca4a5327de5191e133ad02706e3ee440dc8658b8cdc3"

# ENV http_proxy=${http_proxy:-}
# ENV https_proxy=${https_proxy:-}
# ENV no_proxy=${no_proxy:-}

# Configure a package repository
RUN echo "deb [trusted=yes] http://debian.charite.de/debian stable main" > /etc/apt/sources.list && \
    apt-get update

# Install required packages
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    wget sha256sum tar gzip bzip2 unzip \
    libxext-dev libxrender-dev libxtst-dev libfreetype6-dev \
    openjdk-11-jdk zenity libx11-dev

# Download Android Studio archive, verify its checksum and unpack it
RUN wget -O android-studio.tar.gz "${ANDROID_STUDIO_URL}" && \
    echo "${ANDROID_STUDIO_SHA256} android-studio.tar.gz" | \
    sha256sum -c && \
    tar -xzvf android-studio.tar.gz

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:/opt/android-studio/bin

# Expose adb port (may be useful for USB debugging)
EXPOSE 5037

# Define working directory
WORKDIR /opt/android-studio

# Define default command
CMD ["/opt/android-studio/bin/studio.sh"]
