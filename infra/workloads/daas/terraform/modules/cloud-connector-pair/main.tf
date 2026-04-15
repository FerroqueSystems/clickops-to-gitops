locals {
  planned_names = [
    for index in range(var.instance_count) :
    format("%s-%s-%02d", var.name_prefix, var.environment_name, index + 1)
  ]

  private_ip_addresses_by_index = length(var.private_ip_addresses) > 0 ? var.private_ip_addresses : [
    for _ in range(var.instance_count) : null
  ]

  zone_by_index = length(var.zones) > 0 ? var.zones : [
    for _ in range(var.instance_count) : null
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

  plan = {
    names               = local.planned_names
    instance_count      = var.instance_count
    vm_size             = var.vm_size
    location            = var.location
    resource_group_name = var.resource_group_name
    subnet_role         = var.subnet_role
    subnet_name         = var.subnet_name
    subnet_id           = var.subnet_id
    tags                = var.tags
    lifecycle           = "static"
    admin_username      = var.admin_username
    private_ips         = local.private_ip_addresses_by_index
    zones               = local.zone_by_index
    domain_join_enabled = var.enable_domain_join
    domain_name         = var.domain_name
  }
}

resource "azurerm_network_interface" "cloud_connector" {
  count               = var.instance_count
  name                = "${local.planned_names[count.index]}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = local.private_ip_addresses_by_index[count.index] != null ? "Static" : "Dynamic"
    private_ip_address            = local.private_ip_addresses_by_index[count.index]
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "cloud_connector" {
  count               = var.instance_count
  name                = local.planned_names[count.index]
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.cloud_connector[count.index].id
  ]
  patch_mode         = "AutomaticByOS"
  provision_vm_agent = true
  zone               = local.zone_by_index[count.index]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "cloud_connector_domain_join" {
  count                      = var.enable_domain_join ? var.instance_count : 0
  name                       = "${local.planned_names[count.index]}-domain-join"
  virtual_machine_id         = azurerm_windows_virtual_machine.cloud_connector[count.index].id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    Name    = var.domain_name
    OUPath  = var.domain_join_ou_path
    User    = var.domain_join_username
    Restart = "true"
    Options = 3
  })

  protected_settings = jsonencode({
    Password = var.domain_join_password
  })

  lifecycle {
    precondition {
      condition = (
        var.domain_name != null &&
        trimspace(var.domain_name) != "" &&
        var.domain_join_username != null &&
        trimspace(var.domain_join_username) != "" &&
        var.domain_join_password != null &&
        trimspace(var.domain_join_password) != ""
      )
      error_message = "Set domain_name, domain_join_username, and domain_join_password when enable_domain_join is true."
    }
  }
}

resource "azurerm_virtual_machine_extension" "cloud_connector_winrm_https" {
  count                      = var.instance_count
  name                       = "${local.planned_names[count.index]}-enable-winrm"
  virtual_machine_id         = azurerm_windows_virtual_machine.cloud_connector[count.index].id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    commandToExecute = "powershell.exe -ExecutionPolicy Bypass -EncodedCommand ${textencodebase64(local.winrm_bootstrap_script, "UTF-16LE")}"
  })

  depends_on = [azurerm_virtual_machine_extension.cloud_connector_domain_join]
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "cloud_connector" {
  count                 = var.auto_shutdown_enabled ? var.instance_count : 0
  virtual_machine_id    = azurerm_windows_virtual_machine.cloud_connector[count.index].id
  location              = var.location
  enabled               = var.auto_shutdown_enabled
  daily_recurrence_time = var.auto_shutdown_time
  timezone              = var.auto_shutdown_timezone

  notification_settings {
    enabled = false
  }
}
