#!/bin/bash

PLAYLIST="output.m3u8"
WORKDIR="."
TEMP_PLAYLIST="temp_${PLAYLIST}"

# Backup original playlist
cp "$WORKDIR/$PLAYLIST" "$WORKDIR/${PLAYLIST}.bak"

declare -A FILE_MAP

# 1. Rename .ts files randomly
for TS_FILE in "$WORKDIR"/*.ts; do
  BASENAME=$(basename "$TS_FILE")
  RANDOM_NAME=$(openssl rand -hex 8).ts
  mv "$TS_FILE" "$WORKDIR/$RANDOM_NAME"
  FILE_MAP["$BASENAME"]="$RANDOM_NAME"
  echo "Renamed $BASENAME -> $RANDOM_NAME"
done

# 2. Rebuild playlist preserving #EXTINF and replacing filenames
{
  while read -r line; do
    if [[ "$line" =~ \.ts$ ]]; then
      OLD_NAME=$(basename "$line")
      echo "${FILE_MAP[$OLD_NAME]}"
    else
      echo "$line"
    fi
  done < "$WORKDIR/$PLAYLIST"
} > "$WORKDIR/$TEMP_PLAYLIST"

# 3. Replace old playlist
mv "$WORKDIR/$TEMP_PLAYLIST" "$WORKDIR/$PLAYLIST"

echo "✅ Playlist updated, filenames randomized, and structure preserved!"

