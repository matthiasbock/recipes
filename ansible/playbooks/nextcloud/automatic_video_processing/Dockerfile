FROM alpine:3.14

RUN apk add --no-cache ffmpeg inotify-tools bash

COPY process_video.sh /usr/local/bin/process_video.sh
RUN chmod +x /usr/local/bin/process_video.sh

CMD [
    "bash", "-c",
    "while [ true ]; do
        inotifywait -r -m /watch -e close_write -e moved_to -t 1800 |
        while read PATH ACTION FILE; do
            if [ -f \"$FILE\" ] && [[ \"$FILE\" =~ .*\.(mp4|MP4|avi|AVI|mkv|MKV|mov|MOV)$ ]]; then
                /usr/local/bin/process_video.sh \"$PATH/$FILE\";
            fi;
        done;
        find /watch -type f \\( -iname '*.mov' -o -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' \\) -exec /usr/local/bin/process_video.sh \\\"{}\\\" \\;
        sleep 60;
    done
    "
]
