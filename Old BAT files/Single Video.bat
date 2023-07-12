@echo off
cd C:\Users\Alex\Downloads\Apps\Youtubedlp\

yt-dlp --download-archive archive_vid.txt --merge-output-format mp4 --format bestvideo[ext=mp4]+bestaudio[ext=m4a] --write-sub --sub-lang en https://www.youtube.com/watch?v=PowRM-ROCwo -P "C:\Users\Alex\Downloads\Apps\YoutubeDLP\Downloads\Misc"
PAUSE