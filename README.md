<div align="center">
  <h1>Social Media Downloader</h1>
  <p><b>A lightweight, high-performance command-line utility for Windows and Linux.</b></p>
  <p>
    <a href="https://github.com/JakkaMadhu/Social-Media-Downloader/releases">
      <img src="https://img.shields.io/github/v/tag/JakkaMadhu/Social-Media-Downloader?color=3b82f6&logo=github&style=for-the-badge" alt="Release">
    </a>
    <a href="#installation">
      <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-0078D6?style=for-the-badge" alt="Platform">
    </a>
    <a href="#license">
      <img src="https://img.shields.io/badge/License-MIT-10b981?style=for-the-badge" alt="License">
    </a>
    <a href="https://github.com/JakkaMadhu/Social-Media-Downloader/releases">
      <img src="https://img.shields.io/github/downloads/JakkaMadhu/Social-Media-Downloader/total?color=f59e0b&style=for-the-badge" alt="Downloads">
    </a>
  </p>

  <p>Download high-quality videos and audio tracks from YouTube, Instagram, Facebook, TikTok, Twitter/X, and 1,000+ sites using a single command: <code>grab</code>.</p>
  <p><b>Direct Downloads:</b> <a href="https://github.com/JakkaMadhu/Social-Media-Downloader/releases">Windows Installer (.exe)</a> | <a href="https://github.com/JakkaMadhu/Social-Media-Downloader/releases">Linux Package (.deb)</a></p>
</div>

---

## Why Social Media Downloader?

Most command-line media downloaders require memorizing long, complex option flags, leave temporary subtitle or fragment files cluttering your folders, and require manual environment PATH setup. 

Social Media Downloader solves these problems by providing:
* **Pre-configured settings:** Downloads the highest resolution, merges video/audio, and embeds subtitles automatically on the fly.
* **Automatic PATH setup:** The native installers (`.exe` for Windows, `.deb` for Linux) configure your system environment instantly so you can type `grab` from any directory.
* **Zero-Leak Cleanup:** If a download is canceled or fails, all temporary files and `.part` files are automatically deleted, leaving your download folder 100% clean.

---

## Table of Contents
- [Key Features](#key-features)
- [Installation](#installation)
- [Usage & Commands](#usage--commands)
- [Troubleshooting & Smart Errors](#troubleshooting--smart-errors)
- [Developer Resources & Packaging Guide](#developer-resources--packaging-guide)
- [License](#license)

---

## Key Features

### Smart Automation & Formatting
* **Strict URL Input Validation**: Validates URLs locally to catch typos or incomplete formats (e.g. `https://www.`) before executing network requests.
* **Smart Error Parsing**: Distinguishes between network failures, private/restricted links, unsupported homepages (e.g. `instagram.com`), and broken/deleted IDs (e.g. truncated reel links) to print helpful, non-technical warnings.
* **Isolated Temporary Directory**: Active downloads are processed in a hidden, process-unique temporary directory (`.grab_temp_*`) to avoid workspace clutter and prevent multi-download collisions.
* **Automatic Subtitle Embedding:** Downloads and embeds English subtitles directly inside the video container (`.mkv`) on the fly, keeping your folders clean.
* **Sequential Playlist Management:** Automatically detects playlist URLs, creates a sub-folder matching the playlist title, and numbers all tracks sequentially (e.g. `01 - Video Title.mkv`).

### Clean User Experience
* **Minimalist Console UI:** Real-time progress percentages and speeds are printed smoothly in the terminal while technical network retry tracebacks are silenced.
* **Interactive Mode**: Run `grab` by itself to be prompted for a link. Enclosing quotes are automatically stripped from pasted text to prevent shell parsing errors.
* **Platform Agnostic**: Identical feature sets, CLI behaviors, and syntax on both Windows and Linux terminals.

---

<a id="installation"></a>
## Installation

### Windows Setup
1. Go to the [Releases](https://github.com/JakkaMadhu/Social-Media-Downloader/releases) section and download the latest `SocialMediaDownloader-v1.0.0-windows-x64-Setup.exe` installer.
2. Run the installer. The wizard will install the utility and configure your system environment `Path` registry keys automatically.
3. Open a new Command Prompt or PowerShell window and run the `grab` command.

### Linux (Ubuntu/Debian) Setup
1. Go to the [Releases](https://github.com/JakkaMadhu/Social-Media-Downloader/releases) section and download the native `.deb` package.
2. In your terminal, install it using `apt` (this automatically configures dependencies like `ffmpeg`):
   ```bash
   sudo apt install ./social-media-downloader_1.0.0_ubuntu_all.deb
   ```
3. Type `grab` from any directory.

---

## Usage & Commands

> [!IMPORTANT]
> When running commands directly in Command Prompt or Terminal, always wrap the link in **double quotes (`"..."`)** to prevent the command line shell from parsing URL symbols like `&`.

### Basic Video Download
Downloads the highest resolution video streams and embeds English subtitles:
```cmd
# Standard video download
grab "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

### Audio Extraction (MP3)
Downloads, extracts, and tags the highest quality audio track as a standalone MP3 file:
```cmd
# Download as audio track
grab -audio "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

### Playlist Management
Downloads all tracks, structures them into a directory, and renames files:
```cmd
# Download entire playlist
grab "https://www.youtube.com/playlist?list=PL3oW2tjiIxvQ1H8jT2D36H..."
```

### Range-Specific Playlist Extraction
Extract a custom range or list of tracks from a playlist:
```cmd
# Download tracks 1 through 5
grab -items 1-5 "https://www.youtube.com/playlist?list=..."

# Download only tracks 1, 3, and 5
grab -items 1,3,5 "https://www.youtube.com/playlist?list=..."
```

### Disable Subtitles
Overrides the default subtitle embedding behavior:
```cmd
# Skip downloading subtitles
grab -nosub "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

### Keep Tool Updated
Instantly checks and upgrades the core downloader engine:
```cmd
# Update downloader engine
grab --update
```

> [!IMPORTANT]
> Because the application is installed in system-protected folders (`C:\Program Files\` on Windows or `/usr/bin/` on Linux), you must run your Command Prompt/PowerShell as **Administrator** on Windows, or run `sudo grab --update` on Linux, to have the correct write permissions to download and overwrite the downloader engine.

---

## Troubleshooting & Smart Errors

> [!TIP]
> **Q: The command 'grab' is not recognized.**
> Make sure to open a new Command Prompt, PowerShell, or Terminal window after running the installer. If it still fails, check your environment PATH variables to ensure the installation bin directory is listed.

> [!WARNING]
> **Q: What do the specific error messages mean?**
> * **`[Error] Invalid URL`**: The text entered does not follow a valid URL format or has an incomplete domain.
> * **`[Error] This video is restricted or private`**: The link is age-gated or requires account login to view.
> * **`[Error] Unsupported URL`**: The link is a valid webpage (like a homepage) but does not contain a downloadable video or audio track.
> * **`[Error] Media not found`**: The link is broken or the video has been deleted.
> * **`[Error] The media is not accessible`**: Instagram or the platform requires authentication or block anonymous downloads.

---

## Developer Resources & Packaging Guide

If you wish to modify the code or build the installers from source, follow this guide.

### Prerequisites
The repository utilizes `yt-dlp` and `ffmpeg` as backends.
* **Windows**: Download the latest `yt-dlp.exe` and static `ffmpeg.exe` / `ffprobe.exe` binaries and place them directly in the `windows-installer/` directory.
* **Linux**: Install packaging tools:
  ```bash
  sudo apt install dpkg-dev
  ```

### 1. Building the Windows Installer (.exe)
We use **Inno Setup** to compile the Windows `.exe` setup file:
1. Download and install **[Inno Setup Compiler](https://jrsoftware.org/isdl.php)**.
2. Open Inno Setup and load the script [windows-installer/installer.iss](windows-installer/installer.iss).
3. Click **Build -> Compile** (or press `Ctrl + F9`).
4. The setup executable will be generated inside the `windows-installer/Output/` directory.

### 2. Building the Linux Package (.deb)
To build the `.deb` package on a Debian/Ubuntu system, run the following commands in your terminal:
```bash
# 1. Set strict Debian file permissions
chmod -R 755 debian-package
chmod 755 debian-package/DEBIAN/postinst
chmod 755 debian-package/DEBIAN/postrm
chmod 755 debian-package/usr/local/bin/grab

# 2. Build the package
dpkg-deb --build debian-package social-media-downloader_1.0.0_ubuntu_all.deb
```

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
