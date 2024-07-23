#!/bin/bash

input_file="$1"
output_file="${input_file%.*}_streamable.mp4"

ffmpeg -i "$input_file" -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 128k \
  -movflags +faststart "$output_file"

echo "Converted $input_file to $output_file"
