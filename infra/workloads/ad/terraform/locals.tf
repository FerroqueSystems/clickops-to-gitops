locals {
  subnet_names_by_role = {
    management = data.azurerm_subnet.management.name
    server     = data.azurerm_subnet.server.name
    client     = data.azurerm_subnet.client.name
  }

  subnet_ids_by_role = {
    management = data.azurerm_subnet.management.id
    server     = data.azurerm_subnet.server.id
    client     = data.azurerm_subnet.client.id
  }

  domain_controller_names = [
    for index in range(var.domain_controller_count) :
    format("%s-%s-%02d", var.domain_controller_name_prefix, var.environment_name, index + 1)
  ]

  winrm_bootstrap_script = <<-EOT
    $ErrorActionPreference = 'Stop'

    Enable-PSRemoting -Force

    $httpsListener = Get-ChildItem WSMan:\Localhost\Listener -ErrorAction SilentlyContinue | Where-Object {
      $_.Keys -match 'Transport=HTTPS'
    }

    if (-not $httpsListener) {
      $dnsNames = @($env:COMPUTERNAME)
      if ($env:USERDNSDOMAIN) {
        $dnsNames += "$($env:COMPUTERNAME).$($env:USERDNSDOMAIN)"
      }

      $cert = New-SelfSignedCertificate -DnsName $dnsNames -CertStoreLocation Cert:\LocalMachine\My
      New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $cert.Thumbprint -Force | Out-Null
    }

    Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $false
    Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $false

    if (-not (Get-NetFirewallRule -DisplayName 'WinRM HTTPS 5986' -ErrorAction SilentlyContinue)) {
      New-NetFirewallRule -DisplayName 'WinRM HTTPS 5986' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5986 | Out-Null
    }
  EOT
}
