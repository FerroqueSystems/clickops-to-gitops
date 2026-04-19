[CmdletBinding()]
param(
    [string[]]$ResourceGroupNames = @(
        "rg-clickops-gitops-demo",
        "rg-clickops-gitops-demo-catalogs"
    ),
    [string]$SubscriptionId,
    [switch]$WhatIf
)

$scriptPath = Join-Path $PSScriptRoot "Set-DemoVmPowerState.ps1"

& $scriptPath -Action Start -ResourceGroupNames $ResourceGroupNames -SubscriptionId $SubscriptionId -WhatIf:$WhatIf
