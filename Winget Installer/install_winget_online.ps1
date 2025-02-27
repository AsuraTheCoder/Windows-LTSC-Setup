# Ensure the script runs from its directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Define URLs for latest Winget & dependencies
$wingetUrl = "https://github.com/microsoft/winget-cli/releases/download/v1.10.320/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$dependenciesZipUrl = "https://github.com/microsoft/winget-cli/releases/download/v1.10.320/DesktopAppInstaller_Dependencies.zip"
$dependenciesZip = "DesktopAppInstaller_Dependencies.zip"

# Download dependencies zip
Write-Host "Downloading dependencies..."
Invoke-WebRequest -Uri $dependenciesZipUrl -OutFile $dependenciesZip -UseBasicParsing

# Extract dependencies
Write-Host "Extracting dependencies..."
Expand-Archive -Path $dependenciesZip -DestinationPath "$scriptPath\Dependencies" -Force

# Identify architecture (x64, x86, arm64, arm) - Using x64 for most cases
$arch = "x64"  # Change manually if required
$dependencyFiles = Get-ChildItem -Path "$scriptPath\Dependencies" -Recurse -Filter "*$arch*.appx"

# Download Winget
Write-Host "Downloading Winget..."
Invoke-WebRequest -Uri $wingetUrl -OutFile "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -UseBasicParsing

# Install dependencies
Write-Host "Installing dependencies..."
foreach ($file in $dependencyFiles) {
    Write-Host "Installing $file..."
    Add-AppxPackage -Path $file.FullName
}

# Install Winget
Write-Host "Installing Winget..."
Add-AppxPackage -Path "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

Write-Host "Installation complete!"
Pause
