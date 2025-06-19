#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

INPUT=${1:?Please provide the input file as the first argument}
UUID=$(uuidgen)

# Optional: create output folders cleanly
rm -rf v0 v1 v2
mkdir -p v0 v1 v2

ffmpeg -i "$INPUT" \
  -filter_complex "[0:v]split=3[v1][v2][v3]; \
                   [v1]scale=w=1920:h=1080[v1out]; \
                   [v2]scale=w=1280:h=720[v2out]; \
                   [v3]scale=w=854:h=480[v3out]" \
  -map [v1out] -c:v:0 libx264 -b:v:0 5000k -maxrate:v:0 5350k -bufsize:v:0 7500k -preset veryfast -g 48 -sc_threshold 0 \
  -map [v2out] -c:v:1 libx264 -b:v:1 2800k -maxrate:v:1 2996k -bufsize:v:1 4200k -preset veryfast -g 48 -sc_threshold 0 \
  -map [v3out] -c:v:2 libx264 -b:v:2 1400k -maxrate:v:2 1498k -bufsize:v:2 2100k -preset veryfast -g 48 -sc_threshold 0 \
  -map a:0 -c:a:0 aac -b:a:0 128k \
  -map a:0 -c:a:1 aac -b:a:1 128k \
  -map a:0 -c:a:2 aac -b:a:2 128k \
  -f hls -hls_time 6 -hls_playlist_type vod \
  -hls_segment_filename "v%v/${UUID}_seg_%d.ts" \
  -master_pl_name master_${UUID}.m3u8 \
  -var_stream_map "v:0,a:0 v:1,a:1 v:2,a:2" \
  v%v/prog_index_${UUID}.m3u8
