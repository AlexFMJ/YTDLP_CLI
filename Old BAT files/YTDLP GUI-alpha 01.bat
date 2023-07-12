@ECHO off
cd C:\Users\Alex\Downloads\Apps\Youtubedlp\
set DLocation=DefaultLocation.txt
FOR /f "tokens=*" %%A in (%DLocation%) do (set DefaultLocation=%%A)
:MainMenu
set DLPType=
set subfolder=
ECHO Simple Download or Change Settings?
ECHO.
ECHO Current download location: %DefaultLocation%\%subfolder%
ECHO Type: Video  - Quality: Raw (webm)
ECHO.
CHOICE /c AI /n /M "(I)nput URL or (A)dvanced options?"
IF ERRORLEVEL 2 GOTO YTDLPCMD-Simple
IF ERRORLEVEL 1 GOTO Directory

::Folder Setup
:Directory
FOR /f "tokens=*" %%A in (%DLocation%) do (set DefaultLocation=%%A)
ECHO.
ECHO ADVANCED OPTIONS
ECHO.
ECHO Current download location: %DefaultLocation%\%subfolder%
ECHO.
Echo Would you like to use the current download location?
CHOICE /c YN /n /m "(Y)es or (N)o?"
IF ERRORLEVEL 2 GOTO SetDirectory
IF ERRORLEVEL 1 GOTO VidOrAudio

:SetDirectory
ECHO.
ECHO Current download location: %DefaultLocation%\%subfolder%
ECHO.
ECHO To keep the current location hit ENTER 
ECHO.
SET /p NewLocation=Copy and Paste the ENTIRE directory of the new Download location WITHOUT THE TAILING BACKSLASH:
IF "%NewLocation%" == "" set NewLocation=%DefaultLocation%
ECHO %NewLocation%> %DLocation%

:Subfolders
FOR /f "tokens=*" %%A in (%DLocation%) do (set DefaultLocation=%%A)
ECHO.
ECHO Current download location: %DefaultLocation%\%subfolder%
ECHO.
ECHO Would you like to create or change subfolders?
CHOICE /C SD /n /M "Create new (S)ubfolder or keep (D)efault download location)?"
IF ERRORLEVEL 2 GOTO VidOrAudio
IF ERRORLEVEL 1 Set /p subfolder=Give this new folder a name:

:FolderSanityCheck
ECHO.
ECHO Current download location: %DefaultLocation%\%subfolder%
CHOICE /c YN /n /m "Does this look correct? (Y)es or (N)o?"
IF ERRORLEVEL 2 GOTO Directory
IF ERRORLEVEL 1 GOTO VidOrAudio


::File Type Picking Here
:VidOrAudio
ECHO.
ECHO Current download location: %DefaultLocation%\%subfolder%
ECHO.
CHOICE /C VA /n /M "Video and audio (V) or Audio Only (A)?"
IF ERRORLEVEL 2 SET archive=archive_aud.txt & GOTO AudioOnly
IF ERRORLEVEL 1 SET archive=archive_vid.txt & GOTO Subcheck

:Subcheck
ECHO.
CHOICE /c YN /M "Download video subtitles if available?"
IF ERRORLEVEL 1 (SET subs=--write-sub --sub-lang en) ELSE (GOTO VFormat)

:VFormat
ECHO.
CHOICE /C MR /n /M "What video format? MP4 (M) or Raw (R) [Lossless Quality]"
IF ERRORLEVEL 2 GOTO YTDLPCMD-VID
IF ERRORLEVEL 1 GOTO QualitySelect

:QualitySelect
set DLPType=YTDLPCMD-VID
ECHO.
ECHO "What is the highest resolution you want?
CHOICE /c 123 /n /m "Maximum (1), 720p (2), or Custom (3).
IF ERRORLEVEL 3 GOTO CustomQuality
IF ERRORLEVEL 2 set videoQ=--format "bv*[height<=720] [ext=mp4]+bestaudio[ext=m4a]" & GOTO YTDLPCMD-VID
IF ERRORLEVEL 1 set videoQ=--merge-output-format mp4 --format bestvideo[ext=mp4]+bestaudio[ext=m4a] & GOTO YTDLPCMD-VID

:URLLoop
ECHO.
ECHO The video will download to the folder: %DefaultLocation%\%subfolder%
ECHO.
SET URL=
set /p URL=Enter URL here:
ECHO.
IF NOT "%URL%"=="" (BREAK) ELSE (GOTO URLLoopEND)
IF NOT "%URL%"=="%URL: =%" (ECHO Invalid Link, make sure there are no spaces. Enter each link separately & GOTO URLLoop) ELSE (BREAK)
IF NOT "%URL%"=="%URL:http=%" (BREAK) ELSE (ECHO Invalid Link, make sure it contains "http" or "https" & GOTO URLLoop)
set URLList=%URL%,%URLList%
echo current URL(s)%URLList%
IF NOT [%URL%]==[] (GOTO URLLoop) ELSE (BREAK)
:URLLoopEND
SET URL=
ECHO Full list of URL(s):%URLList%
GOTO %DLPType%

:CustomQuality
set DLPType=YTDLPCMD-CUSTOM
ECHO.
ECHO Hint: 1080, 720, 480, 360, 240, 144
set /p HPIX=Maximum Pixel width in whole numbers:
set /a numtest=HPIX
ECHO.
echo %HPIX%|findstr /r /c:"^[0-9][0-9]*$" >nul
if errorlevel 1 (echo Not a number. Please remove any letters. & goto CustomQuality) else (echo Set to %HPIX%p)

:AudioOnly
set DLPType=YTDLPCMD-AUD
ECHO.
ECHO Audio Only Download
CHOICE /C MWR /n /M "What audio format? MP3 (M), WAV (W), or Raw (R)"
IF ERRORLEVEL 3 set audio="-f "bestaudio/best"" & GOTO YTDLPCMD-AUD
IF ERRORLEVEL 2 set audio=-x --audio-format wav --audio-quality 0 & GOTO YTDLPCMD-AUD
IF ERRORLEVEL 1 set audio=-x --audio-format mp3 --audio-quality 0 & GOTO 


::YT-DLP Outputs below this point
:YTDLPCMD-VID
ECHO.
yt-dlp --download-archive %archive% %videoQ% %subs% %URLList% -P "%DefaultLocation%\\%subfolder%"
ECHO.
CHOICE /c ABX /n /m "(A)dd another link with these settings, Go (B)ack to the start, or E(x)it"
IF ERRORLEVEL 3 GOTO END
IF ERRORLEVEL 2 GOTO MainMenu
IF ERRORLEVEL 1 GOTO YTDLPCMD-VID

:YTDLPCMD-Simple
FOR /f "tokens=*" %%A in (%DLocation%) do (set DefaultLocation=%%A)
ECHO.
ECHO Video will download at the highest quality (likely .webm) to the folder: %DefaultLocation%\%subfolder%
set /p URL=Enter Video URL:
yt-dlp --download-archive archive_vid.txt %videoQ% %URLList% -P "%DefaultLocation%\\%subfolder%"
::this shit with the double backslash courtesy of python, that bitch
ECHO.
CHOICE /c ABX /n /m "(A)dd another link with these settings, Go (B)ack to the start, or E(x)it"
IF ERRORLEVEL 3 GOTO END
IF ERRORLEVEL 2 GOTO MainMenu
IF ERRORLEVEL 1 GOTO YTDLPCMD-Simple

:YTDLPCMD-CUSTOM
ECHO.
ECHO The video will download to the folder: %DefaultLocation%\%subfolder%
set /p URL=Enter Video URL:
yt-dlp --download-archive %archive% --format "bv*[height<=%HPIX%] [ext=mp4]+bestaudio[ext=m4a]" %subs% %URLList% -P "%DefaultLocation%\\%subfolder%"
ECHO.
CHOICE /c ABX /n /m "(A)dd another link with these settings, Go (B)ack to the start, or E(x)it"
IF ERRORLEVEL 3 GOTO END
IF ERRORLEVEL 2 GOTO MainMenu
IF ERRORLEVEL 1 GOTO YTDLPCMD-CUSTOM

:YTDLPCMD-AUD
ECHO.
ECHO The audio will download to the folder: %DefaultLocation%\%subfolder%
set /p URL=Enter Video URL:
yt-dlp --download-archive %archive% %audio% %URLList% -P "%DefaultLocation%\\%subfolder%"
ECHO.
CHOICE /c ABX /n /m "(A)dd another link with these settings, Go (B)ack to the start, or E(x)it"
IF ERRORLEVEL 3 GOTO END
IF ERRORLEVEL 2 GOTO MainMenu
IF ERRORLEVEL 1 GOTO YTDLPCMD-AUD