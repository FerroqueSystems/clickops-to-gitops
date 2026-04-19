# Citrix DaaS Terraform Scaffold

This root module is the starter layout for Citrix DaaS running in the same Azure resource group and virtual network as the existing NetScaler deployment.

The design goal is to keep the shared platform static while making machine catalogs easy to rebuild every 30 days.

## Lifecycle Split

Static layer:
- Shared Azure resource group, VNet, and subnets
- NetScaler and NetScaler Console Agent
- Citrix resource location
- Citrix hosting connection
- Cloud Connectors

Rotating layer:
- Golden image versions
- Machine catalogs
- Catalog cutover into delivery groups

## File Layout

- `data_shared_infra.tf`: reads the existing Azure resource group, VNet, and subnets
- `resource_location.tf`: starter plan for the Citrix resource location
  - now creates the Citrix Cloud resource location and exposes its real ID
- `hosting_connection.tf`: creates the Citrix zone, Azure hypervisor, and Azure hypervisor resource pool
- `cloud_connectors.tf`: static support component plan
  - now provisions Windows Server Cloud Connector VMs, optional AD domain join,
    WinRM bootstrap, auto-shutdown schedules, and optional system-assigned managed identity
- `machine_catalogs.tf`: rotating catalog layer keyed by `catalog_generation`
  - now creates real `citrix_machine_catalog` resources backed by the Azure Compute Gallery image versions
- `delivery_groups.tf`: stable delivery-group layer that can point to a new catalog generation
  - still emits the cutover plan only

## Notes

- This scaffold now deploys the Azure VM layer for Cloud Connectors, creates
  the Citrix Cloud resource location, creates the Citrix Azure hosting
  connection objects, and creates the Citrix machine catalogs.
- The recommended Azure hosting connection mode is
  `SystemAssignedManagedIdentity`, which requires system-assigned identities on
  the Cloud Connector VMs and Azure RBAC that allows those identities to manage
  the target Azure resources for MCS.
- The current NetScaler NSGs are lab-oriented and should be reviewed before placing Cloud Connectors or VDAs in these subnets.
- The `client` subnet should remain ADC-facing. Use `management` for static support components and `server` for rotating machine catalogs after the NSGs are adjusted for DaaS traffic.

## Monthly Rebuild Pattern

1. Refresh the machine image.
2. Bump `catalog_generation` in the environment tfvars.
3. Apply the rotating catalog layer.
4. Validate the new catalog.
5. Cut over the delivery group mapping.
6. Remove the old catalog generation.
