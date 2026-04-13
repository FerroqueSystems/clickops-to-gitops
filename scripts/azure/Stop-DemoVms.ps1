[CmdletBinding()]
param(
    [string]$ResourceGroupName = "rg-clickops-gitops-demo",
    [string]$SubscriptionId,
    [switch]$WhatIf
)

$scriptPath = Join-Path $PSScriptRoot "Set-DemoVmPowerState.ps1"

& $scriptPath -Action Stop -ResourceGroupName $ResourceGroupName -SubscriptionId $SubscriptionId -WhatIf:$WhatIf
