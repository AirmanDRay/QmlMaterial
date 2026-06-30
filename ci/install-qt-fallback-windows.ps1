param(
  [string]$QTDIR = "C:\Qt\6.8.3"
)

$ErrorActionPreference = 'Stop'
Write-Host "Fallback installer (Windows) target QTDIR=$QTDIR"

if (Test-Path (Join-Path $QTDIR 'lib\cmake\Qt6ShaderTools')) {
  Write-Host "Qt6ShaderTools already present at $QTDIR\lib\cmake\Qt6ShaderTools"
  Get-ChildItem (Join-Path $QTDIR 'lib\cmake\Qt6ShaderTools') -Force
  exit 0
}

$installer = "qt-unified-windows-x86-online.exe"
if (-not (Test-Path $installer)) {
  Write-Host "Downloading Qt online installer..."
  Invoke-WebRequest -Uri "https://download.qt.io/official_releases/online_installers/qt-unified-windows-x86-online.exe" -OutFile $installer
}

# Create a minimal script file for the installer. Component IDs may need adjustment.
$scriptXml = @"
<Installer>
  <AutoAcceptLicense>true</AutoAcceptLicense>
</Installer>
"@
$scriptPath = "qt-installer-script.xml"
$scriptXml | Out-File -FilePath $scriptPath -Encoding utf8

Write-Host "Running Qt installer (non-interactive attempt). This may require elevation and may fail on hosted runners."
Start-Process -FilePath $installer -ArgumentList ("--script", $scriptPath) -Wait -NoNewWindow

Write-Host "Installer finished. Listing $QTDIR\lib\cmake"
if (Test-Path (Join-Path $QTDIR 'lib\cmake')) {
  Get-ChildItem (Join-Path $QTDIR 'lib\cmake') -Force
} else {
  Write-Host "No cmake dir at $QTDIR"
}
