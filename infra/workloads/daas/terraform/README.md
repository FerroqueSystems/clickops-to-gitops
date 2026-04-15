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
- `hosting_connection.tf`: starter plan for the Azure hosting connection
- `cloud_connectors.tf`: static support component plan
  - now provisions Windows Server Cloud Connector VMs, optional AD domain join,
    WinRM bootstrap, and auto-shutdown schedules
- `machine_catalogs.tf`: rotating catalog layer keyed by `catalog_generation`
- `delivery_groups.tf`: stable delivery-group layer that can point to a new catalog generation

## Notes

- This scaffold now deploys the Azure VM layer for Cloud Connectors. Citrix Cloud
  registration and later machine-catalog resources still need follow-on work.
- The current NetScaler NSGs are lab-oriented and should be reviewed before placing Cloud Connectors or VDAs in these subnets.
- The `client` subnet should remain ADC-facing. Use `management` for static support components and `server` for rotating machine catalogs after the NSGs are adjusted for DaaS traffic.

## Monthly Rebuild Pattern

1. Refresh the machine image.
2. Bump `catalog_generation` in the environment tfvars.
3. Apply the rotating catalog layer.
4. Validate the new catalog.
5. Cut over the delivery group mapping.
6. Remove the old catalog generation.
