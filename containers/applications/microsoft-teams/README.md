
# Microsoft Teams

Browser:
Funktioniert nicht unter Linux... warum nicht?
Audio geht, rein und raus
Video nicht
wird aufgenommen aber weder sehe ich sein Bild noch er meins
ich sehe mein Bild!


~~~
pactl load-module module-native-protocol-unix socket=/tmp/pulseaudio.socket
podman run -it \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=unix$DISPLAY \
  -v /tmp/pulseaudio.socket:/tmp/pulseaudio.socket \
  -e PULSE_SERVER=unix:/tmp/pulseaudio.socket \
  -e PULSE_COOKIE=/tmp/pulseaudio.cookie \
  -v /dev/video0:/dev/video0 \
  -v /dev/video1:/dev/video1 \
  -v /dev/dri/card0:/dev/dri/card0 \
  --network host \
  --name msteams \
  --hostname msteams \
  docker.io/matthiasbock/microsoft-teams:latest
  #-v /home/user/Downloads/teams_1.4.00.4855_amd64.deb:/tmp/teams.deb \
  #docker.io/matthiasbock/debian-base:stable-amd64
~~~

## Dependencies missing upstream

* libsecret-1-0
