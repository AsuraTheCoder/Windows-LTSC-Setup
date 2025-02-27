# Ensure PowerShell Execution Policy allows running scripts
Set-ExecutionPolicy Bypass -Scope Process -Force

# Ensure the script runs from its directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Detect system architecture
$arch = $env:PROCESSOR_ARCHITECTURE
switch ($arch) {
    "AMD64"   { $arch = "x64" }
    "x86"     { $arch = "x86" }
    "ARM"     { $arch = "arm" }
    "ARM64"   { $arch = "arm64" }
    default   { Write-Host "Unknown architecture detected. Exiting..."; Pause; Exit }
}
Write-Host "Detected system architecture: $arch"

# Create download directory
$downloadPath = "$scriptPath\Downloaded_Files"
if (!(Test-Path $downloadPath)) { New-Item -ItemType Directory -Path $downloadPath | Out-Null }

# URLs for dependencies and Winget
$wingetURL = "https://github.com/microsoft/winget-cli/releases/download/v1.10.320/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$dependenciesURL = "https://github.com/microsoft/winget-cli/releases/download/v1.10.320/DesktopAppInstaller_Dependencies.zip"
$wingetInstallerPath = "$downloadPath\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$dependenciesZipPath = "$downloadPath\DesktopAppInstaller_Dependencies.zip"

# Download Winget
Write-Host "Downloading Winget..."
Invoke-WebRequest -Uri $wingetURL -OutFile $wingetInstallerPath

# Download Dependencies
Write-Host "Downloading dependencies..."
Invoke-WebRequest -Uri $dependenciesURL -OutFile $dependenciesZipPath

# Extract Dependencies
Write-Host "Extracting dependencies..."
Expand-Archive -Path $dependenciesZipPath -DestinationPath $downloadPath -Force

# Find dependencies for detected architecture
$dependencyPath = "$downloadPath\DesktopAppInstaller_Dependencies"
$archFolder = Get-ChildItem -Path $dependencyPath | Where-Object { $_.Name -match $arch }
if ($archFolder) {
    $archPath = $archFolder.FullName
    $dependencyFiles = Get-ChildItem -Path $archPath -Filter "*.appx"
} else {
    Write-Host "No matching dependencies found for $arch. Exiting..."
    Pause
    Exit
}

# Install dependencies
Write-Host "Installing dependencies for $arch..."
foreach ($file in $dependencyFiles) {
    Write-Host "Installing $file..."
    try {
        Add-AppxPackage -Path $file.FullName -ErrorAction Stop
        Write-Host "Successfully installed $file"
    } catch {
        Write-Host "Failed to install $file. Error: $_"
    }
}

# Install Winget
Write-Host "Installing Winget..."
try {
    Add-AppxPackage -Path $wingetInstallerPath -ErrorAction Stop
    Write-Host "Successfully installed Winget."
} catch {
    Write-Host "Failed to install Winget. Error: $_"
}

Write-Host "Installation complete."
Pause
