resource "azurerm_virtual_machine_extension" "domain_controller_winrm_https" {
  count                      = var.domain_controller_count
  name                       = "${local.domain_controller_names[count.index]}-enable-winrm"
  virtual_machine_id         = azurerm_windows_virtual_machine.domain_controller[count.index].id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    commandToExecute = "powershell.exe -ExecutionPolicy Bypass -EncodedCommand ${textencodebase64(local.winrm_bootstrap_script, "UTF-16LE")}"
  })
}
