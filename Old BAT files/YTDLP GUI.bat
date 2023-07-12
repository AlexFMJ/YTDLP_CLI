@ECHO OFF
:Header
cd C:\Users\Alex\Downloads\Apps\Youtubedlp\
set DLocation=DefaultLocation.txt
::Subs will default to on and will only turn off if selected in advanced options
SET subs=--write-sub --sub-lang en
SET "SubsOn=If Available"
FOR /f "tokens=*" %%A in (%DLocation%) do (set DefaultLocation=%%A)
SET URLFile=currentURLS.txt

:MainMenu
break>%URLFile%
::resets URLList upon start
set DLPType=
set subfolder=
ECHO Simple Download or Change Settings?
ECHO.
ECHO Current download location: %DefaultLocation%\%subfolder%
ECHO Type: Video  -  Quality: Raw .webm
ECHO.
CHOICE /c AI /n /M "(I)nput URL or (A)dvanced options?"
IF ERRORLEVEL 2 SET DLPType=YTDLPCMD-Simple & set VidRes=Maximum & Set VidFormat=Raw  & GOTO URLLoop
IF ERRORLEVEL 1 GOTO Directory

::Folder Setup
:Directory
cls
FOR /f "tokens=*" %%A in (%DLocation%) do (set DefaultLocation=%%A)
ECHO ADVANCED OPTIONS
ECHO.
ECHO Current download location: %DefaultLocation%\%subfolder%
ECHO.
Echo Would you like to change the current download location?
CHOICE /c NY /n /m "(Y)es or (N)o?"
IF ERRORLEVEL 2 GOTO SetDirectory
IF ERRORLEVEL 1 GOTO VidOrAudio

:SetDirectory
ECHO.
ECHO Current download location: %DefaultLocation%\%subfolder%
ECHO.
ECHO Copy and Paste the ENTIRE directory of the new Download location WITHOUT THE TAILING BACKSLASH:
ECHO To skip changing the root folder and move on to the subfolder, hit ENTER
SET /p NewLocation=
ECHO.
IF "%NewLocation%"=="" set NewLocation=%DefaultLocation% 
::Valid Location check loop
:DirValLoop
IF NOT "%NewLocation:~1,1%"==":" (ECHO Make sure to paste the ENTIRE location, including drive letter & GOTO SetDirectory)
::The comma in the set function is necessary to keep the rest of the string intact while only removing the last letter
IF "%NewLocation:~-1%"=="\" (set NewLocation=%NewLocation:~,-1%)
IF "%NewLocation:~-1%"==" " (set NewLocation=%NewLocation:~,-1%)
::loop back if detected
IF "%NewLocation:~-1%"=="\" (GOTO DirValLoop)
IF "%NewLocation:~-1%"==" " (GOTO DirValLoop)
ECHO %NewLocation%> %DLocation%

:Subfolders
FOR /f "tokens=*" %%A in (%DLocation%) do (set DefaultLocation=%%A)
ECHO Current download location: %DefaultLocation%\%subfolder%
ECHO.
ECHO Would you like to create or change subfolders?
CHOICE /C SD /n /M "Create new (S)ubfolder or keep (D)efault download location)?"
IF ERRORLEVEL 2 GOTO FolderSanityCheck
IF ERRORLEVEL 1 ECHO. & Set /p subfolder=Give this new folder a name:
:SubValLoop
IF "%subfolder:~-1%"=="\" (set subfolder=%subfolder:~,-1%)
IF "%subfolder:~-1%"==" " (set subfolder=%subfolder:~,-1%)
::loop back if detected
IF "%subfolder:~-1%"=="\" (GOTO SubValLoop)
IF "%subfolder:~-1%"==" " (GOTO SubValLoop)
::End check

:FolderSanityCheck
ECHO.
ECHO Current download location: %DefaultLocation%\%subfolder%
CHOICE /c YN /n /m "Does this look correct? (Y)es or (N)o?"
IF ERRORLEVEL 2 Set "Subfolder=" & GOTO Directory
IF ERRORLEVEL 1 CLS & GOTO VidOrAudio

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
IF ERRORLEVEL 2 (SET "subs=" & SET "SubsOn=No" & GOTO VFormat SET)
IF ERRORLEVEL 1 (SET "SubsOn=If Available")

:VFormat
ECHO.
CHOICE /C MR /n /M "What video format? MP4 (M) or Raw (R) [Lossless Quality]"
IF ERRORLEVEL 2 SET VidRes=Maximum & SET VidFormat=Raw & SET DLPType=YTDLPCMD-Simple & GOTO URLLoop
IF ERRORLEVEL 1 SET VidFormat=MP4 & GOTO QualitySelect

:QualitySelect
set DLPType=YTDLPCMD-Custom
ECHO.
ECHO "What is the highest resolution you want?
CHOICE /c 123 /n /m "Maximum (1), 720p (2), or Custom (3).
IF ERRORLEVEL 3 GOTO CustomQuality
IF ERRORLEVEL 2 set VidRes=720p & set videoQ=--format "bv*[height<=720] [ext=mp4]+bestaudio[ext=m4a]" & GOTO URLLoop
IF ERRORLEVEL 1 set VidRes=Maximum & set videoQ=--merge-output-format mp4 --format bestvideo[ext=mp4]+bestaudio[ext=m4a] & GOTO URLLoop

:CustomQuality
set DLPType=YTDLPCMD-CUSTOM
ECHO.
ECHO Hint: 1080, 720, 480, 360, 240, 144
set /p HPIX=Maximum video pixel height in whole numbers:
ECHO.
echo %HPIX%|findstr /r /c:"^[0-9][0-9]*$" >nul
if errorlevel 1 (echo Not a number. Please remove any letters. & goto CustomQuality) else (Set VidRes=%HPIX%p)
GOTO URLLoop

:AudioOnly
set DLPType=YTDLPCMD-AUD
ECHO.
ECHO Audio Only Download
CHOICE /C MWR /n /M "What audio format? MP3 (M), WAV (W), or Raw (R)"
IF ERRORLEVEL 3 set audio="-f "bestaudio/best"" & set AUDFormat=Raw & GOTO URLLoop
IF ERRORLEVEL 2 set audio=-x --audio-format wav --audio-quality 0 & set AUDFormat=WAV & GOTO URLLoop
IF ERRORLEVEL 1 set audio=-x --audio-format mp3 --audio-quality 0 & set AUDFormat=MP3 & GOTO URLLoop

:URLLoop
IF %DLPType%==YTDLPCMD-AUD (set "FileDLInfo=File type: Audio  -  Format: %AUDformat%") ELSE (set "FileDLInfo=File type: Video  -  Resolution: %VidRes%  -  Format: %VidFormat%  -  Subtitles: %SubsOn%")
ECHO.
CLS
:URLLoopstart
setlocal enabledelayedexpansion
SET "pluralgrammar=are"
::SET /a URLQTYtemp=0
SET /a URLQTY+=0
::+=%URLQTYtemp%
IF %URLQTY% GEQ 1 (set urlspacer=, ) else (set "urlspacer=")
IF %URLQTY% GTR 1 (set "vidpluralfiles=These files")
IF %URLQTY%==0 (set "vidplural=s" & set "vidpluralfiles=Files")
IF %URLQTY%== 1 (set "vidplural=" & set "pluralgrammar=is" & set "vidpluralfiles=This file") ELSE (set "vidplural=s")
ECHO %FileDLInfo%
ECHO.
ECHO There %pluralgrammar% (%URLQTY%) URL%vidplural% currently.
::ECHO Link%vidplural%:%URLList%
ECHO.
ECHO %vidpluralfiles% will download to the folder: %DefaultLocation%\%subfolder%
ECHO.
set "URL="
ECHO Paste a URL Below or hit ENTER to continue when done adding links.
set /p "URL="
::Valid URL check
IF "!URL!"=="" (GOTO URLLoopEND)
::%var: =% means "var with (space) removed, you could put anything there like %var:howdy=% 
::so in this case, "IF %var% does NOT EQU %var with howdy removed%, do this..."
IF NOT "!URL!"=="!URL: =!" (CLS & ECHO Invalid Link, make sure there are no spaces. Enter each link separately & Echo. & GOTO URLLoopstart)
::starting from the 0 place, look at the first four characters compare to http
IF NOT !URL:~0^,4!==http (CLS & ECHO Invalid Link, make sure it contains "http" or "https" & Echo. & GOTO URLLoopstart)
::End check
set URLList=%URLList%%urlspacer%!URL!
SET /a URLQTY=0
ECHO !URL!>>%URLFile%
EndLocal
for %%d in (%URLList:""= %) DO set /a URLQTY+=1
ClS
GOTO URLLoopstart
:URLLoopEND
SET URL=
ECHO.
ECHO Full list of URL(s):%URLList%
Set /a URLQTY=0
GOTO %DLPType%

::YT-DLP Outputs below this point
:YTDLPCMD-Simple
FOR /f "tokens=*" %%A in (%DLocation%) do (set DefaultLocation=%%A)
ECHO.
yt-dlp --download-archive archive_vid.txt %videoQ% %subs% --batch-file %URLFile% -P "%DefaultLocation%\\%subfolder%"
::this shit with the double backslash courtesy of python, that bitch
ECHO.
CHOICE /c ABX /n /m "(A)dd another link with these settings, Go (B)ack to the start, or E(x)it and open Download location"
IF ERRORLEVEL 3 %SystemRoot%\explorer.exe "%DefaultLocation%\%subfolder%" & GOTO END
IF ERRORLEVEL 2 GOTO MainMenu
IF ERRORLEVEL 1 GOTO URLLoop

:YTDLPCMD-CUSTOM
yt-dlp --download-archive %archive% --format "bv*[height<=%HPIX%] [ext=mp4]+bestaudio[ext=m4a]" %subs% --batch-file %URLFile% -P "%DefaultLocation%\\%subfolder%"
ECHO.
CHOICE /c ABX /n /m "(A)dd another link with these settings, Go (B)ack to the start, or E(x)it and open Download location"
IF ERRORLEVEL 3 %SystemRoot%\explorer.exe "%DefaultLocation%\%subfolder%" & GOTO END
IF ERRORLEVEL 2 GOTO MainMenu
IF ERRORLEVEL 1 GOTO URLLoop

:YTDLPCMD-AUD
ECHO.
yt-dlp --download-archive %archive% %audio% --batch-file %URLFile% -P "%DefaultLocation%\\%subfolder%"
ECHO.
CHOICE /c ABX /n /m "(A)dd another link with these settings, Go (B)ack to the start, or E(x)it and open Download location"
IF ERRORLEVEL 3 %SystemRoot%\explorer.exe "%DefaultLocation%\%subfolder%" & GOTO END
IF ERRORLEVEL 2 GOTO MainMenu
IF ERRORLEVEL 1 GOTO URLLoop