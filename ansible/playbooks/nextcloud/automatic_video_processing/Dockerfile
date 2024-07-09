FROM alpine:3.14

RUN apk add --no-cache ffmpeg inotify-tools bash

COPY process_video.sh /usr/local/bin/process_video.sh
RUN chmod +x /usr/local/bin/process_video.sh

CMD ["{{ CONTAINER_CMD }}"]
