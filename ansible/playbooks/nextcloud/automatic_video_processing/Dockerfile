FROM alpine:3.14

RUN apk add --no-cache ffmpeg inotify-tools bash

COPY "{{ PROCESS_VIDEO | basename }}" "{{ PROCESS_VIDEO }}"
RUN chmod +x "{{ PROCESS_VIDEO }}"

COPY "{{ CONTAINER_CMD | basename }}" "{{ CONTAINER_CMD }}"
RUN chmod +x "{{ CONTAINER_CMD }}"

CMD ["{{ CONTAINER_CMD }}"]
