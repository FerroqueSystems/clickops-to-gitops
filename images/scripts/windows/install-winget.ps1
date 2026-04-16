$ErrorActionPreference = "Stop"

if ($env:INSTALL_WINGET_PACKAGES -ne "true") {
    Write-Host "winget bootstrap disabled for this image build. Skipping."
    exit 0
}

function Get-WingetCommand {
    $command = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    return $null
}

$wingetPath = Get-WingetCommand
if ($wingetPath) {
    Write-Host "winget already available at $wingetPath"
    exit 0
}

Write-Host "winget not found. Attempting to bootstrap App Installer."

Install-PackageProvider -Name NuGet -Force | Out-Null

if (-not (Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue)) {
    Register-PSRepository -Default
}

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery -Scope AllUsers
Import-Module Microsoft.WinGet.Client -Force

Repair-WinGetPackageManager -AllUsers

$deadline = (Get-Date).AddMinutes(10)
while ((Get-Date) -lt $deadline) {
    $wingetPath = Get-WingetCommand
    if ($wingetPath) {
        Write-Host "winget bootstrapped at $wingetPath"
        exit 0
    }

    Start-Sleep -Seconds 10
}

throw "winget was not available after bootstrap attempt."
