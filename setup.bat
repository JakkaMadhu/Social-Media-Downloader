@echo off
setlocal enabledelayedexpansion
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "CLR_SUCCESS=!ESC![92m"
set "CLR_INFO=!ESC![96m"
set "CLR_WARN=!ESC![93m"
set "CLR_ERROR=!ESC![91m"
set "CLR_RESET=!ESC![0m"

echo !CLR_INFO!==================================================!CLR_RESET!
echo !CLR_INFO!         YouTube Downloader Setup Wizard          !CLR_RESET!
echo !CLR_INFO!==================================================!CLR_RESET!
echo.

:: 1. Try installing via winget first (System-wide installation)
where winget >nul 2>nul
if %errorlevel% equ 0 (
    echo !CLR_INFO![1/2] Installing yt-dlp system-wide via winget...!CLR_RESET!
    winget install --id yt-dlp.yt-dlp --source winget
    
    echo.
    echo !CLR_INFO![2/2] Installing ffmpeg system-wide via winget...!CLR_RESET!
    winget install --id Gyan.FFmpeg --source winget
    
    echo.
    echo !CLR_SUCCESS![Success] Global installation complete! Please restart your terminal to use 'yt'.!CLR_RESET!
    pause
    exit /b 0
)

:: 2. Fallback: Download locally to the current folder using curl & powershell
echo !CLR_WARN![Notice] winget not found. Downloading files locally to this folder...!CLR_RESET!
echo.

:: Download yt-dlp.exe
if not exist "%~dp0yt-dlp.exe" (
    echo !CLR_INFO![1/2] Downloading yt-dlp.exe...!CLR_RESET!
    curl -L -o "%~dp0yt-dlp.exe" "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
    if %errorlevel% neq 0 (
        echo !CLR_ERROR![Error] Failed to download yt-dlp.exe!CLR_RESET!
        pause
        exit /b 1
    )
) else (
    echo [Info] yt-dlp.exe already exists. Skipping.
)

:: Download and extract ffmpeg
if not exist "%~dp0ffmpeg.exe" (
    echo !CLR_INFO![2/2] Downloading FFmpeg bundle (approx. 100MB)...!CLR_RESET!
    set "FFMPEG_ZIP=%temp%\ffmpeg.zip"
    curl -L -o "!FFMPEG_ZIP!" "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
    if %errorlevel% neq 0 (
        echo !CLR_ERROR![Error] Failed to download FFmpeg!CLR_RESET!
        pause
        exit /b 1
    )
    
    echo !CLR_INFO![Status] Extracting ffmpeg.exe from zip archive...!CLR_RESET!
    powershell -Command "Expand-Archive -Path '!FFMPEG_ZIP!' -DestinationPath '%temp%\ffmpeg_extracted' -Force"
    
    :: Move ffmpeg.exe and ffprobe.exe to local folder
    for /R "%temp%\ffmpeg_extracted" %%F in (ffmpeg.exe ffprobe.exe) do (
        if exist "%%F" move /Y "%%F" "%~dp0" >nul
    )
    
    :: Clean up temp extraction files
    rd /S /Q "%temp%\ffmpeg_extracted" >nul 2>nul
    del "!FFMPEG_ZIP!" >nul 2>nul
    
    if not exist "%~dp0ffmpeg.exe" (
        echo !CLR_ERROR![Error] Failed to locate ffmpeg.exe in extracted archive.!CLR_RESET!
        pause
        exit /b 1
    )
) else (
    echo [Info] ffmpeg.exe already exists. Skipping.
)

echo.
echo !CLR_SUCCESS![Success] Local setup complete! yt-dlp and ffmpeg are ready in this folder.!CLR_RESET!
pause
exit /b 0
