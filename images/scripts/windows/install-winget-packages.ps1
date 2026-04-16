$ErrorActionPreference = "Stop"

if ($env:INSTALL_WINGET_PACKAGES -ne "true") {
    Write-Host "winget package installation disabled for this image build. Skipping."
    exit 0
}

function Get-WingetCommand {
    $command = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    throw "winget.exe is not available. Run install-winget.ps1 first."
}

$packageIdsRaw = $env:WINGET_PACKAGE_IDS
if ([string]::IsNullOrWhiteSpace($packageIdsRaw)) {
    Write-Host "No winget packages requested. Skipping."
    exit 0
}

$packageIds = $packageIdsRaw.Split("|", [System.StringSplitOptions]::RemoveEmptyEntries) |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ }

if ($packageIds.Count -eq 0) {
    Write-Host "No winget packages requested after parsing. Skipping."
    exit 0
}

$winget = Get-WingetCommand

Write-Host "Updating winget sources."
& $winget source update --accept-source-agreements

foreach ($packageId in $packageIds) {
    Write-Host "Installing $packageId from winget."

    & $winget install `
        --exact `
        --id $packageId `
        --source winget `
        --accept-package-agreements `
        --accept-source-agreements `
        --silent `
        --scope machine `
        --disable-interactivity
}

Write-Host "Installed requested winget packages: $($packageIds -join ', ')"
