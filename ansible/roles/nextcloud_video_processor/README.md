
# NextCloud video processor container

This role implements the installation of a Docker container,
which monitors a target directory and iteratively checks for video files.
If video files encoded in non-streamable formats are found,
ffmpeg is used to create a streamable copy of such files.
The idea is to ensure, NextCloud users from different platforms
can seamlessly share videos with one another.

## Monitoring

`inotifywait` is used to monitor the target folder and its subfolders
for newly uploaded files, i.e. *file closed* events.

## Conversion

~~~sh
ffmpeg \
    -i "$INPUT_FILENAME" \
    -c:v libx264 -preset medium -crf 23 \
    -c:a aac -b:a 128k \
    -movflags +faststart "$OUTPUT_FILENAME"
~~~

## Health status

The container's health status is determined by the presence of unsupported video file formats:

* *healthy*: all videos are streamable or a streamable copy has been created
* *degraded*: for at least one non-streamable video no streamable copy is present

The health status is also published to Docker as well as via a **Prometheus** file.
