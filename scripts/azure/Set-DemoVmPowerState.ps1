[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Start", "Stop")]
    [string]$Action,

    [string]$ResourceGroupName = "rg-clickops-gitops-demo",

    [string]$SubscriptionId,

    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-StartPriority {
    param(
        [Parameter(Mandatory = $true)]
        [string]$VmName
    )

    switch -Regex ($VmName) {
        '^terraform-adc-machine-node-' { return 10 }
        '^ad-dc-' { return 20 }
        '^terraform-netscaler-agent$' { return 30 }
        '^ctx-cc-' { return 40 }
        '^terraform-ubuntu-bastion-machine$' { return 50 }
        default { return 50 }
    }
}

function Get-StopPriority {
    param(
        [Parameter(Mandatory = $true)]
        [string]$VmName
    )

    switch -Regex ($VmName) {
        '^terraform-ubuntu-bastion-machine$' { return 10 }
        '^ctx-cc-' { return 20 }
        '^terraform-netscaler-agent$' { return 30 }
        '^ad-dc-' { return 40 }
        '^terraform-adc-machine-node-' { return 50 }
        default { return 50 }
    }
}

function Get-DesiredPowerState {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Start", "Stop")]
        [string]$RequestedAction
    )

    if ($RequestedAction -eq "Start") {
        return "VM running"
    }

    return "VM deallocated"
}

if ($SubscriptionId) {
    az account set --subscription $SubscriptionId | Out-Null
}

$vmJson = az vm list `
    --resource-group $ResourceGroupName `
    --show-details `
    --query "[].{name:name,powerState:powerState}" `
    --output json

$vms = $vmJson | ConvertFrom-Json

if (-not $vms) {
    Write-Host "No VMs found in resource group '$ResourceGroupName'."
    exit 0
}

if ($Action -eq "Start") {
    $orderedVms = $vms |
        Sort-Object @{ Expression = { Get-StartPriority -VmName $_.name } }, @{ Expression = { $_.name } }
}
else {
    $orderedVms = $vms |
        Sort-Object @{ Expression = { Get-StopPriority -VmName $_.name } }, @{ Expression = { $_.name } }
}

$desiredPowerState = Get-DesiredPowerState -RequestedAction $Action

Write-Host "$Action order for resource group '$ResourceGroupName':"
$orderedVms | ForEach-Object {
    Write-Host (" - {0} ({1})" -f $_.name, $_.powerState)
}

foreach ($vm in $orderedVms) {
    if ($WhatIf) {
        Write-Host ("[WhatIf] {0} {1}" -f $Action, $vm.name)
        continue
    }

    if ($Action -eq "Start" -and $vm.powerState -eq $desiredPowerState) {
        Write-Host ("Skipping {0}; already running." -f $vm.name)
        continue
    }

    if ($Action -eq "Stop" -and $vm.powerState -eq $desiredPowerState) {
        Write-Host ("Skipping {0}; already deallocated." -f $vm.name)
        continue
    }

    if ($Action -eq "Start") {
        Write-Host ("Starting {0}..." -f $vm.name)
        az vm start --resource-group $ResourceGroupName --name $vm.name | Out-Null
    }
    else {
        Write-Host ("Deallocating {0}..." -f $vm.name)
        az vm deallocate --resource-group $ResourceGroupName --name $vm.name | Out-Null
    }

    $currentPowerState = $null
    do {
        Start-Sleep -Seconds 10
        $instanceViewJson = az vm get-instance-view `
            --resource-group $ResourceGroupName `
            --name $vm.name `
            --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus | [0]" `
            --output tsv

        $currentPowerState = ($instanceViewJson | Out-String).Trim()
        Write-Host ("   Current state for {0}: {1}" -f $vm.name, $currentPowerState)
    }
    while ($currentPowerState -ne $desiredPowerState)
}

Write-Host ("Completed {0} sequence for resource group '{1}'." -f $Action.ToLowerInvariant(), $ResourceGroupName)
