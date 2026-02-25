nice -n 10 ffmpeg -threads 1 -i input.mkv \
  -map 0:v:0 -map 0:a:0 \
  -c:v libx264 \
  -preset slow \
  -crf 20 \
  -profile:v high \
  -level 4.1 \
  -pix_fmt yuv420p \
  -movflags +faststart \
  -c:a aac \
  -b:a 192k \
  output.mp4

