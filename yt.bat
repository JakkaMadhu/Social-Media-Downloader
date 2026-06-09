@echo off
rem =====================================================================
rem Script Name: yt.bat
rem Description: Fast, Colorful, Everyday-Friendly YouTube Downloader
rem Usage:       yt.bat <URL/Flag> [Custom_Output_Name]
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

if /I "%_arg1%"=="--help" goto :help
if /I "%_arg1%"=="-help" goto :help
if /I "%_arg1%"=="-h" goto :help
if /I "%_arg1%"=="/?" goto :help
if /I "%_arg1%"=="/h" goto :help

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
if /I "%_arg1%"=="--update" goto :run_update
if /I "%_arg1%"=="-update" goto :run_update
if /I "%_arg1%"=="/update" goto :run_update
goto :skip_update

:run_update
echo !CLR_INFO![Update] Checking for updates... Please wait...!CLR_RESET!
set "_update_log=%temp%\yt_upd_%random%.log"
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
        set "FFMPEG_FLAGS=--ffmpeg-location "%~dp0ffmpeg.exe""
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
set "_youtube_url="
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

    if not defined _youtube_url (
        set "_youtube_url=!_current_arg!"
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
if defined _youtube_url set "_youtube_url=!_youtube_url:_AMP_=&!"
if defined _custom_name set "_custom_name=!_custom_name:_AMP_=&!"

:: Verify URL was provided
if not defined _youtube_url (
    set /p "_youtube_url=Please paste the YouTube link: "
    if "!_youtube_url!"=="" (
        echo.
        echo !CLR_ERROR![Notice] You forgot to paste the YouTube link.!CLR_RESET!
        echo Usage example: yt https://www.youtube.com/watch?v=...
        endlocal
        exit /b 1
    )
)
set "_youtube_url=!_youtube_url:"=!"

:: 4. Core Download Configuration Profiles
:: Determine playlist status
set "_is_playlist=0"
echo "!_youtube_url!" | findstr /I "list=" >nul
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
set "_common_flags=--no-config --file-access-retries 10 -q --progress --no-warnings !FFMPEG_FLAGS!"

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
echo !CLR_INFO![Connection] Contacting YouTube... Please wait...!CLR_RESET!
echo.

:: Run yt-dlp, redirecting stderr to a temp file so we can catch authentication/age restriction errors
set "_err_log=%temp%\yt_err_%random%.log"
"!YTDLP_PATH!" !_quality_flags! !_playlist_flags! -o "!_output_name!" "!_youtube_url!" 2> "%_err_log%"
set "_download_exit_code=!errorlevel!"

if !_download_exit_code! neq 0 (
    if exist "%_err_log%" (
        rem Inspect the error for common age-restricted / private video indicators
        findstr /I /C:"confirm your age" /C:"private video" /C:"sign in" /C:"login" "%_err_log%" >nul
        if !errorlevel! equ 0 (
            echo.
            echo !CLR_ERROR![Error] This video is restricted or private.!CLR_RESET!
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
echo Please check the spelling or run "yt --help" for options.
endlocal
exit /b 1

:help
echo !CLR_INFO!==================================================!CLR_RESET!
echo !CLR_INFO!             YouTube Smart Downloader             !CLR_RESET!
echo !CLR_INFO!==================================================!CLR_RESET!
echo.
echo Basic Video Download:
echo   yt ^<Paste Link Here^>
echo.
echo Download Video with a Specific Name:
echo   yt ^<Paste Link^> "My Favorite Video"
echo.
echo Download as a Music Track (Audio Only):
echo   yt -audio ^<Paste Link^>
echo.
echo Subtitle Options:
echo   yt -nosub ^<Paste Link^>        Download video without subtitles.
echo.
echo Playlist Options:
echo   yt -items 1-5 ^<Paste Link^>    Download specific range of playlist items.
echo.
echo Update the Downloader Tool:
echo   yt --update
echo.
echo --------------------------------------------------------------------
echo Extra Smart Features:
echo   - It automatically downloads and embeds English subtitles [and auto-captions] by default.
echo   - If you paste a Playlist link, it creates a folder named 
echo     after the playlist and numbers all videos (01, 02, 03...).
echo ====================================================================
endlocal
exit /b 0