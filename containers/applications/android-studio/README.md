# Android Studio

Android Studio is an IDE for Android developers.

## Dockerfile

~~~sh
docker build -t android-studio .
xhost +local:docker
docker run -it --rm \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --device /dev/bus/usb \
    android-studio
~~~

Optional options:

* --cap-drop=ALL
* --cap-add=SYS_PTRACE
* --cap-add=DAC_OVERRIDE
* --security-opt seccomp=unconfined

## Dependencies

android-studio/intellij runtime dependencies:
zenity libxext-dev libxrender-dev libxtst-dev libfreetype6-dev openjdk-11-{jre,jdk}

maybe the jre shipped with Android Studio is sufficient?

Specify where to display the graphical window:
podman ... -e DISPLAY=:0.0 ...

emulator needs: libx11-dev

bin/studio.sh

JAVA_HOME must be set:
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

## ~/.bashrc

~~~
export JAVA_HOME=$(readlink -f $(which java) | sed "s:/jre/bin/java::")

#export JAVA_INCLUDE_PATH=$JAVA_ROOT/include
#export JAVA_INCLUDE_PATH2=$JAVA_ROOT/include/linux

export JAVA_HOME=$JAVA_ROOT
#export JAVA_JVM_LIBRARY=$JAVA_HOME/lib/amd64/server/libjvm.so
#export JAVA_AWT_LIBRARY=$JAVA_HOME/lib/amd64/libjawt.so

#export JNI_INCLUDE_DIRS=$JAVA_HOME/lib/amd64
#$JAVA_INCLUDE_PATH:$JAVA_INCLUDE_PATH2:

export PATH=${PATH}:${JAVA_HOME}/bin
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${JAVA_HOME}/lib/amd64:${JAVA_HOME}/jre/lib/amd64"
~~~

## TODOs

* Forward browser calls: invokation of chromium in the container should open chromium on the host

## Links

* Homepage: https://developer.android.com/studio
* Direct link (22.11.2024): https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.2.1.11/android-studio-2024.2.1.11-linux.tar.gz (sha256sum 81f2fa5da72ab6f6afacca4a5327de5191e133ad02706e3ee440dc8658b8cdc3)

