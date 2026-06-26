@echo off
rem =====================================================================
rem Script Name: grab.bat
rem Description: Social Media Downloader - Fast, Colorful CLI Tool
rem Usage:       grab <URL/Flag> [Custom_Output_Name]
rem =====================================================================
setlocal enabledelayedexpansion

:: 1. Color and Environment Constants
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "CLR_RESET=!ESC![0m"
set "CLR_SUCCESS=!ESC![92m"
set "CLR_ERROR=!ESC![91m"
set "CLR_INFO=!ESC![96m"
set "CLR_WARN=!ESC![93m"
set "BANG=!"

set "_arg1=%~1"
set "_arg2=%~2"

for %%H in (--help -help -h /? /h) do if /I "%_arg1%"=="%%H" goto :help
for %%V in (--version -version -v) do if /I "%_arg1%"=="%%V" goto :version

:: 2. Robust Setup Checks
set "YTDLP_PATH="
where yt-dlp >nul 2>nul && set "YTDLP_PATH=yt-dlp"
if not defined YTDLP_PATH (
    if exist "%~dp0yt-dlp.exe" (
        set "YTDLP_PATH=%~dp0yt-dlp.exe"
    ) else (
        echo !CLR_ERROR![Error] The core downloader tool [yt-dlp.exe] is missing.!CLR_RESET!
        echo Please make sure yt-dlp.exe is in the same folder as this script.
        endlocal
        exit /b 1
    )
)

:: Update Feature Switch
for %%U in (--update -update /update -u) do if /I "%_arg1%"=="%%U" goto :run_update
goto :skip_update

:run_update
echo !CLR_INFO![Update] Checking for updates... Please wait...!CLR_RESET!
set "_update_log=%temp%\grab_upd_%random%.log"
"!YTDLP_PATH!" --no-config -U > "%_update_log%" 2>&1
set "_update_exit_code=!errorlevel!"

if !_update_exit_code! neq 0 (
    echo.
    echo !CLR_ERROR![Error] Could not check for updates.!CLR_RESET!
    echo Please check your internet connection and try again.
    echo.
    del "%_update_log%" 2>nul
    exit /b !_update_exit_code!
)

findstr /I /C:"is up to date" "%_update_log%" >nul
if !errorlevel! equ 0 (
    echo.
    echo !CLR_SUCCESS![Success] The downloader is already up to date.!CLR_RESET!
    echo.
    del "%_update_log%" 2>nul
    exit /b 0
)

findstr /I /C:"Updated to" /C:"Updating to" /C:"Updated" "%_update_log%" >nul
if !errorlevel! equ 0 (
    echo.
    echo !CLR_SUCCESS![Success] The downloader was successfully updated to the latest version.!CLR_RESET!
    echo.
    del "%_update_log%" 2>nul
    exit /b 0
)

:: Fallback in case output layout changed
type "%_update_log%"
del "%_update_log%" 2>nul
exit /b 0

:skip_update

set "FFMPEG_FLAGS="
where ffmpeg >nul 2>nul
if !errorlevel! neq 0 (
    if exist "%~dp0ffmpeg.exe" (
        set FFMPEG_FLAGS=--ffmpeg-location "%~dp0ffmpeg.exe"
    ) else (
        echo !CLR_ERROR![Error] The helper tool [ffmpeg.exe] is missing.!CLR_RESET!
        echo Without it, high-quality video and audio cannot be combined.
        echo Please make sure ffmpeg.exe is in the same folder as this script.
        endlocal
        exit /b 1
    )
)

:: 3. Process Modifiers and Arguments safely
set "_raw_args=%*"
if defined _raw_args set "_raw_args=!_raw_args:&=_AMP_!"

:: Remove quotes if the user quoted the entire command line
if "!_raw_args:~0,1!"=="""" (
    if "!_raw_args:~-1!"=="""" (
        set "_raw_args=!_raw_args:~1,-1!"
    )
)

set "_mode=video"
set "_media_url="
set "_custom_name="
set "_disable_subs=0"
set "_playlist_flags="

set "_args_to_process=!_raw_args!"


:parse_loop
if not "!_args_to_process!"=="" (
    for /F "tokens=1* delims= " %%A in ("!_args_to_process!") do (
        set "_current_arg=%%A"
        set "_args_to_process=%%B"
    )
    rem Strip quotes from CURRENT_ARG
    set "_current_arg=!_current_arg:"=!"
    
    if /I "!_current_arg!"=="-audio" (
        set "_mode=audio"
        goto :parse_loop
    )
    if /I "!_current_arg!"=="-nosub" (
        set "_disable_subs=1"
        goto :parse_loop
    )
    if /I "!_current_arg!"=="-nosubs" (
        set "_disable_subs=1"
        goto :parse_loop
    )

    if /I "!_current_arg!"=="-items" (
        for /F "tokens=1* delims= " %%A in ("!_args_to_process!") do (
            set "_playlist_range=%%A"
            set "_args_to_process=%%B"
        )
        set "_playlist_range=!_playlist_range:"=!"
        set "_playlist_flags=--playlist-items !_playlist_range!"
        goto :parse_loop
    )
    set "_first_char=!_current_arg:~0,1!"
    if "!_first_char!"=="-" goto :bad_option
    if "!_first_char!"=="/" goto :bad_option

    if not defined _media_url (
        set "_media_url=!_current_arg!"
    ) else (
        if not defined _custom_name (
            set "_custom_name=!_current_arg!"
        ) else (
            set "_custom_name=!_custom_name! !_current_arg!"
        )
    )
    goto :parse_loop
)

:: Restore ampersands in variables
if defined _media_url set "_media_url=!_media_url:_AMP_=&!"
if defined _custom_name set "_custom_name=!_custom_name:_AMP_=&!"

:: Verify URL was provided
if not defined _media_url (
    set /p "_media_url=Please paste the media link (YouTube, Instagram, FB, TikTok, etc.): "
    if "!_media_url!"=="" (
        echo.
        echo !CLR_ERROR![Notice] You forgot to paste the media link.!CLR_RESET!
        echo Usage example: grab https://instagram.com/p/...
        endlocal
        exit /b 1
    )
)
set "_media_url=!_media_url:"=!"
set "_media_url=!_media_url:'=!"

set "_valid_url=0"
if /I "!_media_url:~0,7!"=="http://" set "_valid_url=1"
if /I "!_media_url:~0,8!"=="https://" set "_valid_url=1"
if /I "!_media_url:~0,4!"=="www." set "_valid_url=1"

if "!_valid_url!"=="1" (
    echo !_media_url! | findstr /R /I "\.[a-z0-9]" >nul
    if !errorlevel! neq 0 set "_valid_url=0"
)

if "!_valid_url!"=="0" (
    echo.
    echo !CLR_ERROR![Error] Invalid URL: "!_media_url!"!CLR_RESET!
    echo Please enter a valid media link
    endlocal
    exit /b 1
)

:: 4. Core Download Configuration Profiles
:: Determine playlist status
set "_is_playlist=0"
echo "!_media_url!" | findstr /I "list=" >nul
if !errorlevel! equ 0 set "_is_playlist=1"

:: Build the output template path
if "!_is_playlist!"=="1" (
    echo !CLR_WARN![Playlist] Multiple videos detected! Creating a folder automatically...!CLR_RESET!
    set "_folder=%%(playlist_title)s"
    if not "!_custom_name!"=="" set "_folder=!_custom_name!"
    set "_output_name=!_folder!/%%(playlist_index)s - %%(title)s.%%(ext)s"
) else (
    set "_output_name=%%(title)s.%%(ext)s"
    if not "!_custom_name!"=="" set "_output_name=!_custom_name!.%%(ext)s"
)

:: Set core common yt-dlp flags to avoid duplication
set "_temp_dir=.grab_temp_%random%"
set "_common_flags=--no-config --file-access-retries 10 -q --progress --no-warnings !FFMPEG_FLAGS! -P temp:!_temp_dir!"

:: Set quality flags based on mode
if "%_mode%"=="audio" (
    echo !CLR_WARN![Mode] Downloading as MP3 Audio [Music]...!CLR_RESET!
    set "_quality_flags=!_common_flags! -x --audio-format mp3 --audio-quality 0 --embed-thumbnail"
) else (
    if "!_disable_subs!"=="1" (
        echo !CLR_SUCCESS![Mode] Downloading highest quality video without subtitles...!CLR_RESET!
        set "_sub_flags="
    ) else (
        echo !CLR_SUCCESS![Mode] Downloading highest quality video with subtitles...!CLR_RESET!
        set "_sub_flags=--write-auto-subs --sub-langs "en*" --embed-subs"
    )
    set "_quality_flags=!_common_flags! -f "bv+ba/b" --merge-output-format mkv !_sub_flags!"
)

:: Disable playlist downloading if not a playlist link
if "!_is_playlist!"=="0" (
    set "_quality_flags=!_quality_flags! --no-playlist"
)

:: 5. Execution Pipeline
echo !CLR_INFO![Connection] Contacting media platform... Please wait...!CLR_RESET!
echo.

:: Run yt-dlp, redirecting stderr to a temp file so we can catch authentication/age restriction errors
set "_err_log=%temp%\grab_err_%random%.log"
"!YTDLP_PATH!" !_quality_flags! !_playlist_flags! -o "!_output_name!" "!_media_url!" 2> "%_err_log%"
set "_download_exit_code=!errorlevel!"

:: Clean up temp download folder on exit
if exist "!_temp_dir!" rd /s /q "!_temp_dir!"

if !_download_exit_code! neq 0 (
    if exist "%_err_log%" (
        rem Inspect the error for specific categories
        findstr /I /C:"confirm your age" /C:"private video" /C:"sign in" /C:"login" "%_err_log%" >nul
        set "_is_restricted=!errorlevel!"
        findstr /I /C:"Unsupported URL" "%_err_log%" >nul
        set "_is_unsupported=!errorlevel!"
        findstr /I /C:"not found" /C:"404" /C:"does not exist" "%_err_log%" >nul
        set "_is_not_found=!errorlevel!"
        findstr /I /C:"empty media response" /C:"accessible in your browser" "%_err_log%" >nul
        set "_is_inaccessible=!errorlevel!"
        
        if !_is_restricted! equ 0 (
            echo.
            echo !CLR_ERROR![Error] This video is restricted or private.!CLR_RESET!
            echo.
        ) else if !_is_unsupported! equ 0 (
            echo.
            echo !CLR_ERROR![Error] Unsupported URL. The link does not point to a downloadable video or audio track.!CLR_RESET!
            echo.
        ) else if !_is_not_found! equ 0 (
            echo.
            echo !CLR_ERROR![Error] Media not found. The link is broken or the video has been deleted.!CLR_RESET!
            echo.
        ) else if !_is_inaccessible! equ 0 (
            echo.
            echo !CLR_ERROR![Error] The media is not accessible. The link may be broken, private, or restricted.!CLR_RESET!
            echo.
        ) else (
            type "%_err_log%"
            echo.
            echo !CLR_ERROR![Error] Download failed. Please check your internet connection or the video link.!CLR_RESET!
        )
        del "%_err_log%" 2>nul
    ) else (
        echo !CLR_ERROR![Error] Something went wrong. Please verify your internet is active and try again.!CLR_RESET!
    )
    endlocal
    exit /b !_download_exit_code!
)

:download_complete
if exist "%_err_log%" del "%_err_log%" 2>nul
echo.
echo !CLR_SUCCESS![Success] Done!BANG! Your download is ready.!CLR_RESET!
endlocal
exit /b 0

:bad_option
echo.
echo !CLR_ERROR![Error] Unrecognized option: !_current_arg!!CLR_RESET!
echo Please check the spelling or run "grab --help" for options.
endlocal
:version
echo Social Media Downloader v1.0.0
endlocal
exit /b 0

:help
echo !CLR_INFO!Social Media Downloader v1.0.0!CLR_RESET!
echo.
echo Usage: grab [OPTIONS] ^<URL^> [OUTPUT_NAME]
echo.
echo Arguments:
echo   ^<URL^>            The media link (YouTube, Instagram, Facebook, TikTok, etc.)
echo   [OUTPUT_NAME]    Optional custom filename for the downloaded file
echo.
echo Options:
echo   -audio           Extract and download highest quality audio as MP3
echo   -nosub           Skip downloading and embedding subtitles
echo   -items RANGE     Download specific playlist items (e.g. 1-5, 1,3,5)
echo   -v, --version    Show program version details
echo   -h, --help       Show this help message and exit
echo   -u, --update     Check and update the core downloader engine
echo.
echo Examples:
echo   grab "https://www.youtube.com/watch?v=..."
echo   grab -audio "https://instagram.com/reel/..."
echo   grab -items 1-5 "https://www.youtube.com/playlist?list=..." "My Playlist"
endlocal
exit /b 0
