Convert and compress any folder with many video files with help of ffpmeg tool.

Used Nvidia codec NVENC for faster gpu conversion.

1) The size of both the input and compressed files is checked before and after compression.
2) If the compressed file is larger than the input file, the changes are reverted by removing the compressed file and renaming the input file with "_compressed" in the filename.
3) The video bitrate (-b:v) is set to 2000k (2 Mbps).
4) The del command is used to remove existing output files before compressing.
5) The buffer size (-bufsize) is set to 4000k (4 Mbps), which is typically twice the maximum bitrate.
