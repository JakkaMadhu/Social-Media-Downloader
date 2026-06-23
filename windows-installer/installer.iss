; Inno Setup Script for Social Media Downloader
; =====================================================================

[Setup]
AppName=Social Media Downloader
AppVersion=1.0.0
AppPublisher=Your Name
AppPublisherURL=https://github.com/JakkaMadhu/Social-Media-Downloader
AppSupportURL=https://github.com/JakkaMadhu/Social-Media-Downloader/issues
AppUpdatesURL=https://github.com/JakkaMadhu/Social-Media-Downloader/releases
DefaultDirName={autopf}\SocialMediaDownloader
DefaultGroupName=Social Media Downloader
DisableProgramGroupPage=yes
OutputDir=.\Output
OutputBaseFilename=SocialMediaDownloader-v1.0.0-windows-x64-Setup
SetupIconFile=icon.ico
ArchitecturesInstallIn64BitMode=x64
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
UninstallDisplayIcon={app}\icon.ico

; =====================================================================
[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

; =====================================================================
[Files]
; Core script (placed in bin)
Source: "grab.bat";      DestDir: "{app}\bin"; Flags: ignoreversion

; Icon file (placed in root)
Source: "icon.ico";      DestDir: "{app}"; Flags: ignoreversion

; yt-dlp binary (placed in bin)
Source: "yt-dlp.exe";   DestDir: "{app}\bin"; Flags: ignoreversion

; ffmpeg binaries (placed in bin)
Source: "ffmpeg.exe";   DestDir: "{app}\bin"; Flags: ignoreversion
Source: "ffprobe.exe";  DestDir: "{app}\bin"; Flags: ignoreversion

; =====================================================================
[Registry]
; Add bin folder to system PATH automatically
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; \
    ValueType: expandsz; ValueName: "Path"; \
    ValueData: "{olddata};{app}\bin"; \
    Check: NeedsAddPath('{app}\bin')

; =====================================================================
[Code]
// Helper function: only adds to PATH if not already present
function NeedsAddPath(Param: string): boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(
    HKLM,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path', OrigPath)
  then begin
    Result := True;
    exit;
  end;
  Result := Pos(';' + Param + ';', ';' + OrigPath + ';') = 0;
end;

// =====================================================================
[UninstallDelete]
Type: filesandordirs; Name: "{app}"

; =====================================================================
[Messages]
WelcomeLabel1=Welcome to Social Media Downloader Setup
WelcomeLabel2=This will install Social Media Downloader on your computer.%n%nYou will be able to run the 'grab' command from any Command Prompt window to download videos and audio from YouTube, Instagram, Facebook, TikTok, Twitter/X, and 1000+ other websites!%n%nClick Next to continue.
FinishedHeadingLabel=Social Media Downloader is ready!
FinishedLabel=The installation is complete.%n%nOpen any Command Prompt window and type:%n%n  grab "<video-or-audio-link>"  %n%nto start downloading immediately.
