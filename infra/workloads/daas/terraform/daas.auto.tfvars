subscription_id             = "0cb554f1-e4b4-4246-8604-b050e5dec014"
environment_name            = "demo"
catalog_generation          = "2026-04"
compute_gallery_name        = "cgclickopsdemo"
shared_resource_group_name  = "rg-clickops-gitops-demo"
shared_virtual_network_name = "terraform-virtual-network"
management_subnet_name      = "terraform-management-subnet"
server_subnet_name          = "terraform-server-subnet"
client_subnet_name          = "terraform-client-subnet"

resource_location_name  = "demo-canadacentral"
hosting_connection_name = "demo-canadacentral-shared"

cloud_connector_count          = 2
cloud_connector_name_prefix    = "ctx-cc"
cloud_connector_vm_size        = "Standard_D4s_v5"
cloud_connector_subnet_role    = "management"
cloud_connector_admin_username = "localadmin"
cloud_connector_private_ip_addresses = [
  "10.45.1.30",
  "10.45.1.31",
]
cloud_connector_enable_domain_join     = true
cloud_connector_domain_name            = "clickops.demo"
cloud_connector_domain_join_username   = "CLICKOPS\\localadmin"
cloud_connector_auto_shutdown_enabled  = true
cloud_connector_auto_shutdown_time     = "1800"
cloud_connector_auto_shutdown_timezone = "Eastern Standard Time"

catalog_deployments = {
  win11-pooled-2026-03 = {
    logical_name          = "win11-pooled"
    generation            = "2026-03"
    subnet_role           = "server"
    session_type          = "single_session"
    image_definition_name = "win11-25h2-cvad"
    image_version         = "1.0.1"
    machine_count         = 3
    vm_size               = "Standard_D4s_v5"
    delivery_group_name   = "dg-win11-pooled"
  }
  win11-pooled-2026-04 = {
    logical_name          = "win11-pooled"
    generation            = "2026-04"
    subnet_role           = "server"
    session_type          = "single_session"
    image_definition_name = "win11-25h2-cvad"
    image_version         = "1.0.2"
    machine_count         = 5
    vm_size               = "Standard_D4s_v5"
    delivery_group_name   = "dg-win11-pooled"
  }
  ws2022-apps-2026-03 = {
    logical_name          = "ws2022-apps"
    generation            = "2026-03"
    subnet_role           = "server"
    session_type          = "multi_session"
    image_definition_name = "ws2022-cvad-apps"
    image_version         = "1.0.1"
    machine_count         = 2
    vm_size               = "Standard_D8s_v5"
    delivery_group_name   = "dg-published-apps"
  }
  ws2022-apps-2026-04 = {
    logical_name          = "ws2022-apps"
    generation            = "2026-04"
    subnet_role           = "server"
    session_type          = "multi_session"
    image_definition_name = "ws2022-cvad-apps"
    image_version         = "1.0.2"
    machine_count         = 3
    vm_size               = "Standard_D8s_v5"
    delivery_group_name   = "dg-published-apps"
  }
}

active_delivery_group_catalogs = {
  win11-pooled = "win11-pooled-2026-03"
  ws2022-apps  = "ws2022-apps-2026-03"
}

tags = {
  Environment = "demo"
  Purpose     = "citrix-daas-monthly-rebuild"
  Lifecycle   = "mixed"
}

# Secrets are provided via environment variables or GitHub Secrets:
# TF_VAR_cloud_connector_admin_password
# TF_VAR_cloud_connector_domain_join_password
