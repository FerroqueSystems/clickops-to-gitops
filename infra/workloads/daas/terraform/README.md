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
- Parallel machine catalog generations
- Explicit catalog cutover into delivery groups

## File Layout

- `data_shared_infra.tf`: reads the existing Azure resource group, VNet, and subnets
- `resource_location.tf`: starter plan for the Citrix resource location
  - now creates the Citrix Cloud resource location and exposes its real ID
- `hosting_connection.tf`: creates the Citrix zone, Azure hypervisor, and Azure hypervisor resource pool
- `cloud_connectors.tf`: static support component plan
  - now provisions Windows Server Cloud Connector VMs, optional AD domain join,
    WinRM bootstrap, auto-shutdown schedules, and optional system-assigned managed identity
- `machine_catalogs.tf`: rotating catalog deployment layer
  - now supports multiple retained generations side by side, keyed by `catalog_deployments`
- `delivery_groups.tf`: stable delivery-group layer that points to an explicitly selected active catalog deployment

## Notes

- This scaffold now deploys the Azure VM layer for Cloud Connectors, creates
  the Citrix Cloud resource location, creates the Citrix Azure hosting
  connection objects, and creates the Citrix machine catalogs.
- The recommended Azure hosting connection mode is
  `SystemAssignedManagedIdentity`, which requires system-assigned identities on
  the Cloud Connector VMs and Azure RBAC that allows those identities to manage
  the target Azure resources for MCS.
- For machine catalogs, prefer a pre-created or imported Citrix service
  account and pass its ID through
  `machine_catalog_domain_service_account_id`. That keeps the AD credential in
  Citrix instead of passing the password inline during catalog creation.
- Keep the Citrix hosting unit scoped to the `server` subnet unless you have a
  clear MCS requirement for additional subnets. Cloud Connectors are deployed as
  static Azure VMs and do not need to be provisioned through the hosting unit.
- Use a dedicated Azure resource group for machine catalog VDA resources. The
  shared resource group can continue to host the gallery, hosting connection
  dependencies, and Cloud Connectors.
- This Terraform root grants the Cloud Connector system-assigned managed
  identities `Contributor` on the dedicated machine catalog resource group so
  Citrix MCS can create catalog Azure resources there.
- The current NetScaler NSGs are lab-oriented and should be reviewed before placing Cloud Connectors or VDAs in these subnets.
- The `client` subnet should remain ADC-facing. Use `management` for static support components and `server` for rotating machine catalogs after the NSGs are adjusted for DaaS traffic.

## Monthly Rebuild Pattern

1. Refresh the machine image.
2. Add a new `catalog_deployments` entry for the next generation and apply.
3. Validate the new catalog while `active_delivery_group_catalogs` still points to the old generation.
4. Put the old delivery targets into drain mode outside Terraform and wait for zero sessions.
5. Change `active_delivery_group_catalogs` to the new generation and apply.
6. Remove the old `catalog_deployments` entry in a later apply after shutdown is complete.
