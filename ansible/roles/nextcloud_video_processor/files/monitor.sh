#!/bin/bash

while [ true ]; do
    inotifywait -r -m /watch -e close_write -e moved_to -t 1800 |
    while read PATH ACTION FILE; do
        if [ -f \"$FILE\" ] && [[ \"$FILE\" =~ .*\.(mp4|MP4|avi|AVI|mkv|MKV|mov|MOV)$ ]]; then
            "{{ PROCESS_VIDEO }}" \"$PATH/$FILE\";
        fi;
    done

    find /watch -type f \\( -iname '*.mov' -o -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' \\) -exec "{{ PROCESS_VIDEO }}" \\\"{}\\\" \\;

    sleep 60
done
