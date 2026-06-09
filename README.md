# 🚀 YouTube Smart Downloader (`yt.bat`)

A fast, clean, and extremely robust Windows Command Prompt wrapper for `yt-dlp` and `ffmpeg`. It simplifies downloading YouTube videos, playlists, and audio tracks, featuring automated setups, auto-subtitles, file-lock resilience, and an interactive link prompt.

---

## ✨ Features

* **🧹 Clean Console UI:** Silences background extraction metadata logs. Shows only clean progress bars and simple error notices.
* **📝 Automatic Subtitles:** Downloads and embeds English subtitles (`en*`) directly into your videos on the fly. No extra `.vtt` subtitle files left cluttering your folders.
* **📂 Smart Playlists:** Automatically creates a folder named after the playlist and numbers all output files sequentially (e.g., `01 - Video Title.mkv`).
* **🔒 Lock-File Resilience:** Automatically waits and retries rename/move operations up to 10 times to prevent errors from Windows Defender, OneDrive syncs, or Explorer file indexing.
* **⚠️ Typo Protection:** Automatically intercepts misspelled or invalid option flags and outputs clean warnings instead of raising credential logins.
* **⌨️ Interactive Mode:** Just run `yt` without arguments, and it will prompt you to paste the URL, completely bypassing Windows command splitting without requiring you to type double quotes.

---

## ⚡ Quick Installation

1. Download this repository (or copy [yt.bat](yt.bat) and [setup.bat](setup.bat) to a folder on your PC).
2. Double-click **`setup.bat`**. 
   * It will automatically install `yt-dlp` and `ffmpeg` globally using **Windows Package Manager (`winget`)**.
   * If `winget` is not available, it will fall back to downloading `yt-dlp.exe` and `ffmpeg.exe` directly into your folder.
3. *Optional:* Add this folder to your system **Path** environment variables so you can run `yt` from any folder on your computer.

---

## 📖 Usage Guide

Open Command Prompt (CMD) and run these commands. 

> 💡 **Important:** When running a command directly, always wrap the link in **double quotes (`"..."`)** to prevent Windows from breaking the URL at `&` characters.

### 🎥 Download Video
Downloads the highest quality video format and embeds English subtitles:
```cmd
yt "https://www.youtube.com/watch?v=yye7rSsiV6k"
```

### 🎵 Download Audio (MP3)
Extracts and downloads highest-quality audio as a tagged MP3 track:
```cmd
yt -audio "https://www.youtube.com/watch?v=yye7rSsiV6k"
```

### 🎞️ Download Playlists
Downloads the entire playlist, structures it inside a directory, and sequences files:
```cmd
yt "https://www.youtube.com/playlist?list=PL3oW2tjiIxvQ1H8jT2D36H-dgh3jX0a_k"
```

### 🔢 Download Specific Playlist Items
Downloads only a specific range, list, or step sequence of videos:
```cmd
yt -items 1-5 "https://www.youtube.com/playlist?list=..."
yt -items 1,3,5 "https://www.youtube.com/playlist?list=..."
yt -items ::2 "https://www.youtube.com/playlist?list=..."
```

### 🚫 Download Without Subtitles
Overrides the default auto-subtitle behavior:
```cmd
yt -nosub "https://www.youtube.com/watch?v=yye7rSsiV6k"
```

### 🔄 Update the Downloader
Instantly updates `yt-dlp` to the latest release:
```cmd
yt -update
```

---

## 🛠️ Advanced Tip: Interactive Paste (No Quotes!)

If you run the command by itself:
```cmd
yt
```
The script will prompt you:
```text
Please paste the YouTube link:
```
Paste your link directly and hit Enter. Windows will not split the ampersand `&` characters in this mode, meaning **you do not need to wrap your link in double quotes!**
