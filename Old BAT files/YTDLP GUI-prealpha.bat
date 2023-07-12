@ECHO off
cd C:\Users\Alex\Downloads\Apps\Youtubedlp\
ECHO Basic or Advanced Mode?
CHOICE /c AI /n /M "(I)nput URL or (A)dvanced options?"
IF ERRORLEVEL 2 GOTO YTDLPCMD-Simple
IF ERRORLEVEL 1 ECHO.

:Subfolders
ECHO Would you like to create or change subfolders?
CHOICE /C SD /n /M "Create new (S)ubfolder or keep (D)efault download location)?"
IF ERRORLEVEL 2 GOTO VidOrAudio
IF ERRORLEVEL 1 Set /p subfolder=Give this new folder a name:

:VidOrAudio
ECHO.
CHOICE /C VA /n /M "Video and audio (V) or Audio Only (A)?"
IF ERRORLEVEL 2 SET archive=archive_aud.txt & GOTO AudioOnly
IF ERRORLEVEL 1 SET archive=archive_vid.txt & GOTO VidWAud

:VidWAud
ECHO.
ECHO Video and Audio Download
CHOICE /c YN /M "Download video subtitles if available?"
IF ERRORLEVEL 1 (SET subs=--write-sub --sub-lang en) ELSE (GOTO VFormat)

:VFormat
ECHO.
CHOICE /C MR /n /M "What video format? MP4 (M) or Raw (R) [Lossless Quality]"
IF ERRORLEVEL 2 GOTO YTDLPCMD-VID
IF ERRORLEVEL 1 GOTO QualitySelect

:QualitySelect
ECHO.
ECHO "What is the highest resolution you want?
CHOICE /c 123 /n /m "Maximum (1), 720p (2), or Custom (3).
IF ERRORLEVEL 3 GOTO CustomQuality
IF ERRORLEVEL 2 set videoQ=--format "bv*[height<=720] [ext=mp4]+bestaudio[ext=m4a]" & GOTO YTDLPCMD-VID
IF ERRORLEVEL 1 set videoQ=--merge-output-format mp4 --format bestvideo[ext=mp4]+bestaudio[ext=m4a] & GOTO YTDLPCMD-VID

:CustomQuality
ECHO.
ECHO Hint: 1080, 720, 480, 360, 240, 144
set /p HPIX=Maximum Pixel width in whole numbers:
goto YTDLPCMD-CUSTOM

:AudioOnly
ECHO.
ECHO Audio Only Download
CHOICE /C MWR /n /M "What audio format? MP3 (M), WAV (W), or Raw (R)"
IF ERRORLEVEL 3 set audio="-f "bestaudio/best"" & GOTO YTDLPCMD-AUD
IF ERRORLEVEL 2 set audio=-x --audio-format wav --audio-quality 0 & GOTO YTDLPCMD-AUD
IF ERRORLEVEL 1 set audio=-x --audio-format mp3 --audio-quality 0 & GOTO YTDLPCMD-AUD

:YTDLPCMD-VID
ECHO.
set /p URL=Enter Video URL:
yt-dlp --download-archive %archive% %videoQ% %subs% %URL% -P "F:\Videos\Internet Archives\01 Unprocessed Downloads\ %subfolder%"
ECHO.
CHOICE /c YN /m "Add another link with these settings? (Y)es or (N)o?"
IF ERRORLEVEL 2 GOTO END
IF ERRORLEVEL 1 GOTO YTDLPCMD-AUD

:YTDLPCMD-Simple
ECHO.
ECHO Video will download at the highest quality (likely .webm) to the default folder.
set /p URL=Enter Video URL:
yt-dlp --download-archive %archive% %videoQ% %URL% -P "F:\Videos\Internet Archives\01 Unprocessed Downloads\ %subfolder%"
ECHO.
CHOICE /c YN /m "Add another link with these settings? (Y)es or (N)o?"
IF ERRORLEVEL 2 GOTO END
IF ERRORLEVEL 1 GOTO YTDLPCMD-AUD

:YTDLPCMD-CUSTOM
ECHO.
set /p URL=Enter Video URL:
yt-dlp --download-archive %archive% --format "bv*[height<=%HPIX%] [ext=mp4]+bestaudio[ext=m4a]" %subs% %URL% -P "F:\Videos\Internet Archives\01 Unprocessed Downloads\ %subfolder%"
ECHO.
CHOICE /c YN /m "Add another link with these settings? (Y)es or (N)o?"
IF ERRORLEVEL 2 GOTO END
IF ERRORLEVEL 1 GOTO YTDLPCMD-AUD

:YTDLPCMD-AUD
ECHO.
set /p URL=Enter Video URL:
yt-dlp --download-archive %archive% %audio% %URL% -P "F:\Videos\Internet Archives\01 Unprocessed Downloads\ %subfolder%"
ECHO.
CHOICE /c YN /m "Add another link with these settings? (Y)es or (N)o?"
IF ERRORLEVEL 2 GOTO END
IF ERRORLEVEL 1 GOTO YTDLPCMD-AUD