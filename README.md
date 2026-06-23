<div align="center">
  <h1>Social Media Downloader</h1>
  <p><b>A lightweight, high-performance command-line utility for Windows and Linux.</b></p>
  <p>
    <a href="https://github.com/JakkaMadhu/Social-Media-Downloader/releases">
      <img src="https://img.shields.io/github/v/release/JakkaMadhu/Social-Media-Downloader?color=3b82f6&logo=github&style=for-the-badge" alt="Release">
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
  <p><b>Direct Downloads:</b> <a href="https://github.com/JakkaMadhu/Social-Media-Downloader/releases/download/v1.0.0/SocialMediaDownloader-v1.0.0-Setup.exe">Windows Installer (.exe)</a> | <a href="https://github.com/JakkaMadhu/Social-Media-Downloader/releases/download/v1.0.0/social-media-downloader_1.0.0_ubuntu_all.deb">Linux Package (.deb)</a></p>
</div>

---

## Why Social Media Downloader?

Most command-line media downloaders require memorizing long, complex option flags, leave temporary subtitle files cluttering your folders, and require manual environment PATH setup. 

Social Media Downloader solves these problems by providing:
* **Pre-configured settings:** Downloads the highest resolution, merges video/audio, and embeds subtitles automatically on the fly.
* **Automatic PATH setup:** The native installers (`.exe` for Windows, `.deb` for Linux) configure your system environment instantly so you can type `grab` from any directory.
* **Smart automation:** Automatically detects playlist links and structures downloads into ordered folders.

---

## Table of Contents
- [Key Features](#key-features)
- [Installation](#installation)
- [Usage & Commands](#usage--commands)
- [Troubleshooting](#troubleshooting)
- [Developer Resources](#developer-resources)
- [License](#license)

---

## Key Features

### Smart Automation
* **Automatic Subtitle Embedding:** Downloads and embeds English subtitles directly inside the video container (`.mkv`) on the fly, keeping your folders clean.
* **Sequential Playlist Management:** Automatically detects playlist URLs, creates a sub-folder matching the playlist title, and numbers all tracks sequentially (e.g. `01 - Video Title.mkv`).
* **Lock-File Resilience:** Prevents write collisions from Windows Defender or active file-indexing sync services using a 10x smart retry mechanism.

### Clean User Experience
* **Minimalist Console UI:** Filters out confusing network logs to show only clean progress percentages in the terminal.
* **Interactive Paste Mode:** Run `grab` by itself to be prompted for a link. This avoids command-prompt URL splitting without requiring you to type double quotes.
* **Platform Agnostic:** Identical feature sets and syntax on both Windows and Linux terminals.

---

<a id="installation"></a>
## Installation

<a id="windows-setup"></a>
### Windows Setup
Download and run the installer:
1. Download **[SocialMediaDownloader-v1.0.0-Setup.exe](https://github.com/JakkaMadhu/Social-Media-Downloader/releases/download/v1.0.0/SocialMediaDownloader-v1.0.0-Setup.exe)** directly, or visit the [Releases](https://github.com/JakkaMadhu/Social-Media-Downloader/releases) section.
2. The installation wizard will install the utility to your program files and configure your system PATH.
3. Open a new Command Prompt or PowerShell window and run the `grab` command.

---

<a id="linux-setup"></a>
### Linux (Ubuntu/Debian) Setup
Download the native package and install it using the system package manager:
1. Download **[social-media-downloader_1.0.0_ubuntu_all.deb](https://github.com/JakkaMadhu/Social-Media-Downloader/releases/download/v1.0.0/social-media-downloader_1.0.0_ubuntu_all.deb)** directly, or visit the [Releases](https://github.com/JakkaMadhu/Social-Media-Downloader/releases) section.
2. In your terminal, run:
   ```bash
   sudo apt install ./social-media-downloader_1.0.0_ubuntu_all.deb
   ```
3. This installs the command and configures all background dependencies automatically.

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
> Because the application is installed in system-protected folders (`C:\Program Files\` on Windows or `/usr/local/bin/` on Linux), you must run your Command Prompt/PowerShell as **Administrator** on Windows, or run `sudo grab --update` on Linux, to have the correct write permissions to download and overwrite the downloader engine.

---

## Troubleshooting

> [!TIP]
> **Q: The command 'grab' is not recognized.**
> Make sure to open a new Command Prompt, PowerShell, or Terminal window after running the installer. If it still fails, check your environment PATH variables to ensure the installation bin directory is listed.

> [!WARNING]
> **Q: Download fails on restricted, private, or age-gated videos.**
> Private or restricted videos require authentication to access. Ensure the link you are pasting is publicly viewable.

---

## Developer Resources

Looking to build the installers from source? Check out the configurations:
* **Windows Installer:** [Inno Setup Configuration](windows-installer/installer.iss)
* **Linux Installer:** [Debian Package Configuration](debian-package/DEBIAN/control)

---

<a id="license"></a>
## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
