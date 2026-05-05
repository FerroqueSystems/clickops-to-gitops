# Monthly Rebuild Pattern

This repo is designed around rebuilding the parts of the Citrix environment that drift the fastest instead of keeping one long-lived catalog forever.

## What Changes Monthly

The intended split is:

- Static layers
  - shared NetScaler network
  - Citrix resource location
  - hosting connection
  - Cloud Connectors
- Rotating layers
  - machine catalog generations
  - image versions in Azure Compute Gallery
- Cutover layer
  - delivery groups pointing to the active catalog generation

In other words, the DaaS root is built to keep the control plane stable while rotating the worker image generations.

## Why This Pattern Exists

The monthly rebuild model helps you:

- reduce configuration drift
- shorten attacker dwell time on long-lived VDAs
- force the image pipeline to stay usable
- make rollback and cutover decisions explicit in Git

## Source Of Truth In This Repo

The main monthly rotation inputs live in:

- `infra/workloads/daas/terraform/daas.auto.tfvars`
  - catalog generations, image versions, machine counts, and active cutover map
- `infra/workloads/daas/terraform/locals.tf`
  - guardrails around generation selection
- `infra/workloads/daas/terraform/delivery_groups.tf`
  - stable delivery groups that point at the chosen active catalog

The shared network usually does not need monthly edits unless the rebuild uncovers reachability or NSG issues.

## Recommended Monthly Sequence

1. Build and validate a new golden image in Azure Compute Gallery.
2. Add a new generation entry under `catalog_deployments` in `infra/workloads/daas/terraform/daas.auto.tfvars`.
3. Keep the previous generation entries in place.
4. Run Terraform apply so the new machine catalogs are created side by side.
5. Validate VDA registration, machine health, and user access.
6. Change `active_delivery_group_catalogs` to point delivery groups at the new generation.
7. Apply again to perform the cutover.
8. Drain, maintenance, or otherwise retire the old generation operationally.
9. Remove the retired generation blocks from `catalog_deployments`.
10. Apply a final time to destroy the old generation.

Do not remove the old generation before cutover and drain are complete. If you do, Terraform will treat it as immediate retirement.

## Rollback Model

Rollback is intentionally simple while both generations still exist:

1. Change `active_delivery_group_catalogs` back to the prior generation.
2. Apply the DaaS root again.

That is one of the main reasons the repo keeps side-by-side catalog generations instead of doing an in-place mutation.

## What Stays Outside The Pattern

The current GitHub Actions workflows do not fully automate every part of the monthly cycle.

You may still need separate steps for:

- image creation under `images/`
- Ansible-based Cloud Connector configuration
- smoke tests and user validation
- AD or GPO changes
- formal change windows and old-catalog drain procedures

## Related Docs

- [pipeline-flow.md](./pipeline-flow.md)
- [backend-setup.md](./backend-setup.md)
- [infra/workloads/daas/terraform/README.md](../infra/workloads/daas/terraform/README.md)
