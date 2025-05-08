# wanzami-backend-upload-randomize-ts-files
bash file to file to help randomize ts files and update output.m3u8

# Command to convert video file to HLS
Install ffmpeg [sudo apt install ffmpeg]

# Run command to convert video file to hls
ffmpeg -i TRAFFICK-MOVIE-MASTER-HD.mp4 -c:v libx264 -c:a aac -strict -2 -f hls -hls_time 10 -hls_playlist_type vod output.m3u8

