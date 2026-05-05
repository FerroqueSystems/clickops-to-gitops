# Citrix DaaS Terraform Guide

This folder manages the Citrix DaaS layer that sits on top of the shared Azure network built with the NetScaler workload.

Use this root for:

- Citrix resource location
- Citrix hosting connection and resource pool
- Cloud Connector VMs
- Machine catalog generations
- Delivery-group cutover between catalog generations

Use the NetScaler/shared-network Terraform root for:

- VNet and subnets
- NSGs
- Ubuntu bastion
- NetScaler infrastructure

## Core Model

This DaaS root is intentionally split into:

- Static layer
  - resource location
  - hosting connection
  - Cloud Connectors
  - shared catalog resource group wiring
- Rotating layer
  - image versions
  - machine catalog generations
  - delivery-group cutover

The design assumption is that Cloud Connectors stay stable while machine catalogs rotate monthly.

## Important Files

- `daas.auto.tfvars`
  - The live tracked configuration used by GitHub Actions.
  - This is the main file operators usually edit.
- `environments/demo/daas.auto.tfvars.example`
  - Example/reference copy of the demo environment settings.
  - Keep it aligned with the live config structure.
- `variables.tf`
  - Input contract for this root module.
  - Read this before introducing new values or secrets.
- `data_shared_infra.tf`
  - Reads the shared Azure RG, VNet, and subnets created elsewhere.
- `cloud_connectors.tf`
  - Provisions Cloud Connector VMs in Azure.
- `cloud_connector_rbac.tf`
  - Grants Cloud Connector identities access required for MCS.
- `hosting_connection.tf`
  - Creates the Citrix hosting connection and resource pool.
- `machine_catalogs.tf`
  - Creates one machine catalog module instance per retained generation.
- `delivery_groups.tf`
  - Points stable delivery groups at the active catalog generation.
- `locals.tf`
  - Contains guardrails and generation-selection logic.
- `backend.hcl.example`
  - Example remote state backend settings.

## What To Edit

Most routine work should happen in `daas.auto.tfvars`.

Common operator changes:

- Update image versions
- Add a new catalog generation
- Cut over active delivery groups
- Adjust machine counts
- Change subnet placement
- Change Cloud Connector counts or static IPs

Avoid editing the module code unless the Terraform behavior itself needs to change.

## What Must Not Be Stored In `daas.auto.tfvars`

Do not commit secrets or sensitive usernames that should come from GitHub Secrets or environment variables.

Use GitHub Secrets or `TF_VAR_...` environment variables for:

- `citrix_customer_id`
- `citrix_client_id`
- `citrix_client_secret`
- `cloud_connector_admin_password`
- `cloud_connector_domain_join_username`
- `cloud_connector_domain_join_password`
- `hosting_connection_application_id`
- `hosting_connection_application_secret`

Current workflows expect at least:

- `CITRIX_CUSTOMER_ID`
- `CITRIX_CLIENT_ID`
- `CITRIX_CLIENT_SECRET`
- `CLOUD_CONNECTOR_ADMIN_PASSWORD`
- `CLOUD_CONNECTOR_DOMAIN_JOIN_USERNAME`
- `CLOUD_CONNECTOR_DOMAIN_JOIN_PASSWORD`

`daas.auto.tfvars` should only contain non-secret environment-specific settings.

## `daas.auto.tfvars` Walkthrough

### Shared environment settings

These values tell the DaaS root where the shared Azure resources already exist:

- `subscription_id`
- `shared_resource_group_name`
- `shared_virtual_network_name`
- `management_subnet_name`
- `server_subnet_name`
- `client_subnet_name`
- `compute_gallery_name`

### Citrix hosting settings

These define the Citrix resource location and Azure hosting connection:

- `resource_location_name`
- `hosting_connection_name`

In `variables.tf`, there are additional optional hosting connection settings if you need to move away from the default `SystemAssignedManagedIdentity` path.

### Cloud Connector settings

These control static infrastructure:

- `cloud_connector_count`
- `cloud_connector_name_prefix`
- `cloud_connector_vm_size`
- `cloud_connector_subnet_role`
- `cloud_connector_private_ip_addresses`
- `cloud_connector_enable_domain_join`
- `cloud_connector_domain_name`
- `cloud_connector_auto_shutdown_*`

Operational guidance:

- Keep Cloud Connectors in the `management` subnet unless you intentionally redesign the network.
- Keep their IPs stable when possible.
- Make sure the `management` subnet can reach domain controllers and server-subnet VDAs.

### `catalog_deployments`

This is the most important rotating section.

Each key is one retained catalog generation, for example:

- `win11-pooled-2026-05`
- `ws2022-apps-2026-05`

Each entry describes:

- `logical_name`
- `generation`
- `subnet_role`
- `session_type`
- `image_definition_name`
- `image_version`
- `machine_count`
- `vm_size`
- `delivery_group_name`

Optional fields:

- `prepared_image_definition_name_override`
- `machine_name_prefix_override`

Rule:

- Keep the old generation and new generation side by side in `catalog_deployments` until cutover and retirement are complete.

### `active_delivery_group_catalogs`

This map controls which generation is live for users.

Example:

```hcl
active_delivery_group_catalogs = {
  win11-pooled = "win11-pooled-2026-05"
  ws2022-apps  = "ws2022-apps-2026-05"
}
```

This is the cutover switch.

Changing only this map moves delivery groups to a newer catalog generation without deleting the older one.

## Safe Monthly Rotation Process

Use this sequence for normal image rotation.

1. Build and validate the new image version in Azure Compute Gallery.
2. Add a new generation block under `catalog_deployments`.
3. Leave the old generation blocks in place.
4. Apply to create the new catalogs side by side.
5. Validate VDA registration and machine health.
6. Update `active_delivery_group_catalogs` to point to the new generation.
7. Apply again to cut over delivery groups.
8. Drain or maintenance-mode the old generation outside Terraform.
9. Only after retirement is complete, remove the old generation blocks from `catalog_deployments`.
10. Apply again to destroy the retired generation.

Do not remove the old generation from `catalog_deployments` before the cutover and drain are complete. If you do, Terraform will try to delete the old catalogs immediately.

## Example: Promote A New Image

Example goal:

- current generation: `2026-05`
- next generation: `2026-06`
- new image version: `5.3.0`

Operator steps:

1. Copy the `2026-05` blocks in `catalog_deployments`.
2. Rename them to `2026-06`.
3. Change `generation = "2026-06"`.
4. Change `image_version = "5.3.0"`.
5. Keep `active_delivery_group_catalogs` pointed at `2026-05`.
6. Apply to create the new catalogs.
7. Validate the new VDAs.
8. Move `active_delivery_group_catalogs` to `2026-06`.
9. Apply again.

## Network Expectations

The DaaS module assumes the shared network permits required east-west traffic.

At minimum:

- Cloud Connectors must reach domain controllers
- VDAs must reach Cloud Connectors
- Cloud Connectors must be able to communicate back to VDAs
- Bastion or admin paths must be allowed if you expect direct RDP troubleshooting

If registration or machine account creation fails, verify:

- subnet NSGs
- NIC NSGs
- Windows Firewall
- DNS resolution
- AD ports such as `53`, `88`, `135`, `389`, `445`

## Troubleshooting Hints

### `FailedToBindToDomainController`

Usually means one of:

- Cloud Connector cannot discover or reach a DC
- DNS is wrong on the Cloud Connector
- domain bind account is wrong
- OU permissions are insufficient
- east-west NSG rules are blocking required traffic

### Machine catalog deletion blocked

If Terraform cannot delete an old catalog because it is associated with a delivery group, the old generation has not been fully drained or detached yet.

Keep the old generation in `catalog_deployments` until you complete the operational drain.

### Image definition deletion blocked

If Citrix says an image definition still has associated image versions, the old prepared image versions still exist in Citrix and must be cleaned up before the definition can be deleted.

## Running Terraform

Typical local flow:

```powershell
terraform init -backend-config=backend.hcl
terraform plan -var-file=daas.auto.tfvars
terraform apply -var-file=daas.auto.tfvars
```

GitHub Actions flow:

- `terraform-plan-azure.yml` runs the plan
- `monthly-daas-apply.yml` runs the apply

These workflows use the tracked `daas.auto.tfvars` file in this folder.

## When To Edit Other Files

Edit `variables.tf` only when:

- you are changing the module interface
- you need a new configurable setting
- you are moving a hardcoded behavior into input data

Edit `machine_catalogs.tf`, `delivery_groups.tf`, or module code only when:

- the resource wiring is wrong
- the lifecycle model needs to change
- Citrix provider behavior requires structural fixes

For routine catalog rotations, stay in `daas.auto.tfvars`.
