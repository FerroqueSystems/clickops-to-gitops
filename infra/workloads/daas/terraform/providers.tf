provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

provider "citrix" {
  cvad_config = {
    customer_id   = var.citrix_customer_id
    client_id     = var.citrix_client_id
    client_secret = var.citrix_client_secret
    environment   = var.citrix_cloud_environment
  }
}
