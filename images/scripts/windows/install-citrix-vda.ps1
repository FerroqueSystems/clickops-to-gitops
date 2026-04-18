$ErrorActionPreference = "Stop"

if ($env:INSTALL_CITRIX_VDA -ne "true") {
    Write-Host "Citrix VDA installation disabled for this image build. Skipping."
    exit 0
}

if ([string]::IsNullOrWhiteSpace($env:CITRIX_VDA_INSTALLER_URL)) {
    throw "CITRIX_VDA_INSTALLER_URL must be set when INSTALL_CITRIX_VDA=true."
}

if ([string]::IsNullOrWhiteSpace($env:CITRIX_VDA_INSTALLER_ARGS)) {
    throw "CITRIX_VDA_INSTALLER_ARGS must be set when INSTALL_CITRIX_VDA=true."
}

$installerRoot = "C:\Temp\PackerInstallers"
New-Item -ItemType Directory -Path $installerRoot -Force | Out-Null

$installerUrl = $env:CITRIX_VDA_INSTALLER_URL
$installerArgs = $env:CITRIX_VDA_INSTALLER_ARGS
$fileName = [System.IO.Path]::GetFileName(([System.Uri]$installerUrl).AbsolutePath)
if ([string]::IsNullOrWhiteSpace($fileName)) {
    $fileName = "CitrixVDAInstaller.exe"
}

$localPath = Join-Path $installerRoot $fileName

Write-Host "Downloading Citrix VDA installer from $installerUrl"
Invoke-WebRequest -Uri $installerUrl -OutFile $localPath -UseBasicParsing

Write-Host "Installing Citrix VDA"
$process = Start-Process -FilePath $localPath -ArgumentList $installerArgs -Wait -PassThru
if ($process.ExitCode -ne 0) {
    throw "Citrix VDA installer failed with exit code $($process.ExitCode)."
}

Write-Host "Citrix VDA installation completed."
