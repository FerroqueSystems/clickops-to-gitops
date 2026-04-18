$ErrorActionPreference = "Stop"

if ($env:PREPARE_FOR_CITRIX_MCS -ne "true") {
    Write-Host "Citrix MCS preparation disabled for this image build. Skipping."
    exit 0
}

Write-Host "Preparing Windows image for Citrix MCS capture."

$tempPaths = @(
    "C:\Windows\Temp\*",
    "C:\Temp\*"
)

foreach ($path in $tempPaths) {
    Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
}

Clear-RecycleBin -Force -ErrorAction SilentlyContinue

Write-Host "Citrix MCS preparation completed."
