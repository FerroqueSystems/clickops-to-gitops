[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Start", "Stop")]
    [string]$Action,

    [string[]]$ResourceGroupNames = @(
        "rg-clickops-gitops-demo",
        "rg-clickops-gitops-demo-catalogs"
    ),

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
        default { return 50 }
        '^terraform-ubuntu-bastion-machine$' { return 60 }
    }
}

function Get-StopPriority {
    param(
        [Parameter(Mandatory = $true)]
        [string]$VmName
    )

    switch -Regex ($VmName) {
        default { return 10 }
        '^ctx-cc-' { return 20 }
        '^terraform-netscaler-agent$' { return 30 }
        '^ad-dc-' { return 40 }
        '^terraform-adc-machine-node-' { return 50 }
        '^terraform-ubuntu-bastion-machine$' { return 60 }
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

$vms = foreach ($resourceGroupName in $ResourceGroupNames) {
    $vmJson = az vm list `
        --resource-group $resourceGroupName `
        --show-details `
        --query "[].{name:name,powerState:powerState}" `
        --output json

    $resourceGroupVms = $vmJson | ConvertFrom-Json

    foreach ($vm in $resourceGroupVms) {
        [PSCustomObject]@{
            name              = $vm.name
            powerState        = $vm.powerState
            resourceGroupName = $resourceGroupName
        }
    }
}

if (-not $vms) {
    Write-Host ("No VMs found in resource groups: {0}." -f ($ResourceGroupNames -join ", "))
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

Write-Host ("{0} order for resource groups: {1}" -f $Action, ($ResourceGroupNames -join ", "))
$orderedVms | ForEach-Object {
    Write-Host (" - {0} [{1}] ({2})" -f $_.name, $_.resourceGroupName, $_.powerState)
}

foreach ($vm in $orderedVms) {
    if ($WhatIf) {
        Write-Host ("[WhatIf] {0} {1} [{2}]" -f $Action, $vm.name, $vm.resourceGroupName)
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
        Write-Host ("Starting {0} in {1}..." -f $vm.name, $vm.resourceGroupName)
        az vm start --resource-group $vm.resourceGroupName --name $vm.name | Out-Null
    }
    else {
        Write-Host ("Deallocating {0} in {1}..." -f $vm.name, $vm.resourceGroupName)
        az vm deallocate --resource-group $vm.resourceGroupName --name $vm.name | Out-Null
    }

    $currentPowerState = $null
    do {
        Start-Sleep -Seconds 10
        $instanceViewJson = az vm get-instance-view `
            --resource-group $vm.resourceGroupName `
            --name $vm.name `
            --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus | [0]" `
            --output tsv

        $currentPowerState = ($instanceViewJson | Out-String).Trim()
        Write-Host ("   Current state for {0}: {1}" -f $vm.name, $currentPowerState)
    }
    while ($currentPowerState -ne $desiredPowerState)
}

Write-Host ("Completed {0} sequence for resource groups: {1}" -f $Action.ToLowerInvariant(), ($ResourceGroupNames -join ", "))
