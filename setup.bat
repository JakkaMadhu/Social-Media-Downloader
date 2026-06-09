@echo off
rem =====================================================================
rem Script Name: setup.bat
rem Description: Installer Wizard for YouTube Smart Downloader
rem =====================================================================
setlocal enabledelayedexpansion

:: 1. Color and Environment Constants
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

:: 2. Try installing via winget first (System-wide installation)
where winget >nul 2>nul
if %errorlevel% equ 0 (
    echo !CLR_INFO![1/2] Installing yt-dlp system-wide via winget...!CLR_RESET!
    winget install --id yt-dlp.yt-dlp --source winget --accept-package-agreements --accept-source-agreements
    set "_w1=!errorlevel!"
    
    echo.
    echo !CLR_INFO![2/2] Installing ffmpeg system-wide via winget...!CLR_RESET!
    winget install --id Gyan.FFmpeg --source winget --accept-package-agreements --accept-source-agreements
    set "_w2=!errorlevel!"
    
    if !_w1! equ 0 (
        if !_w2! equ 0 (
            echo.
            echo !CLR_SUCCESS![Success] Global installation complete! Please restart your terminal to use 'yt'.!CLR_RESET!
            pause
            endlocal
            exit /b 0
        )
    )
    echo.
    echo !CLR_WARN![Notice] winget installation failed or was cancelled.!CLR_RESET!
    echo Falling back to downloading local binaries...
    echo.
)

:: 3. Fallback: Download locally to the current folder using curl & powershell
echo !CLR_INFO![Status] Setting up local binaries in this folder...!CLR_RESET!
echo.

:: Download yt-dlp.exe
if not exist "%~dp0yt-dlp.exe" (
    echo !CLR_INFO![1/2] Downloading yt-dlp.exe...!CLR_RESET!
    curl -L -o "%~dp0yt-dlp.exe" "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
    if !errorlevel! neq 0 (
        echo !CLR_ERROR![Error] Failed to download yt-dlp.exe!CLR_RESET!
        pause
        endlocal
        exit /b 1
    )
) else (
    echo [Info] yt-dlp.exe already exists. Skipping.
)

:: Download and extract ffmpeg
if not exist "%~dp0ffmpeg.exe" (
    echo !CLR_INFO![2/2] Downloading FFmpeg essentials archive...!CLR_RESET!
    set "_ffmpeg_zip=%temp%\ffmpeg_%random%.zip"
    curl -L -o "!_ffmpeg_zip!" "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
    if !errorlevel! neq 0 (
        echo !CLR_ERROR![Error] Failed to download FFmpeg!CLR_RESET!
        pause
        endlocal
        exit /b 1
    )
    
    echo !CLR_INFO![Status] Extracting ffmpeg.exe from archive...!CLR_RESET!
    powershell -Command "Expand-Archive -Path '!_ffmpeg_zip!' -DestinationPath '%temp%\ffmpeg_extracted' -Force"
    
    :: Move ffmpeg.exe and ffprobe.exe to local folder
    for /R "%temp%\ffmpeg_extracted" %%F in (ffmpeg.exe ffprobe.exe) do (
        if exist "%%F" move /Y "%%F" "%~dp0" >nul
    )
    
    :: Clean up temp extraction files
    rd /S /Q "%temp%\ffmpeg_extracted" >nul 2>nul
    del "!_ffmpeg_zip!" >nul 2>nul
    
    if not exist "%~dp0ffmpeg.exe" (
        echo !CLR_ERROR![Error] Failed to locate ffmpeg.exe in extracted archive.!CLR_RESET!
        pause
        endlocal
        exit /b 1
    )
) else (
    echo [Info] ffmpeg.exe already exists. Skipping.
)

echo.
echo !CLR_SUCCESS![Success] Local setup complete! yt-dlp and ffmpeg are ready in this folder.!CLR_RESET!
echo.
echo !CLR_INFO![Tip] To run the 'yt' command from ANY folder on your computer:!CLR_RESET!
echo  1. Copy the path to this folder: %~dp0
echo  2. Search for "env" in Windows and click "Edit environment variables for your account".
echo  3. Double-click "Path", click "New", paste the folder path, and save.
echo.
pause
endlocal
exit /b 0
