# From Click-Ops to Git-Ops: Sample Citrix & NetScaler Automation Repo

This repository accompanies the session **"From Click-Ops to Git-Ops: Rebuilding Your Citrix & NetScaler Worlds Every 30 Days"**.

It is designed as a **teaching repo** – not production-ready code – to show how you can:

- Define your Citrix and NetScaler configuration as **code**
- Use **Git** as the source of truth
- Drive deployments via **CI/CD pipelines**
- Implement a **monthly rebuild pattern** to reduce security risk and configuration drift

> ⚠️ Disclaimer: All examples here are simplified and should be adapted, validated, and security-hardened before use in a live environment.

This repo aligns with the Citrix Automation Handbook Part 5 (Azure DaaS Deployment) by providing Infrastructure as Code (IaC) examples using Terraform, Ansible, and pipelines. Below, we break down the handbook's 10-part workflow, identifying what's implemented in this repo and where to find it.

---

## Alignment with Citrix Automation Handbook Part 5: Azure DaaS Deployment

The handbook outlines a 10-step process for deploying Citrix DaaS on Azure using IaC (Terraform, Packer, Ansible). This repo provides modular, reusable code snippets and structures for most steps. Not all are fully implemented (e.g., Packer scripts are referenced but not included; add them to `pipelines/` for builds). Adapt to your environment.

### Part 1: Create All Needed Prerequisites
**Description**: Set up Azure basics (Resource Group, Virtual Network, Subnet, NSG, Shared Image Gallery) and Citrix Cloud (Service Principal, Resource Location/Zone).  
**Repo Implementation**: Partially implemented.  
- **Foundation Infra**: `infra/foundation/terraform/` (main.tf, variables.tf, outputs.tf) – Deploys network hub, identity (Entra), Key Vault.  
- **Azure Resources**: `workloads/daas/terraform/data_shared_infra.tf`, `resource_location.tf` – Handles RG, VNet, NSG, Shared Gallery.  
- **Citrix Cloud**: `workloads/daas/terraform/resource_location.tf` – Creates resource location and zone.  
- **Missing/To Add**: Packer for images (integrate via pipelines).  
**Key Files**: `infra/foundation/terraform/main.tf`, `workloads/daas/terraform/providers.tf`.

### Part 2: Using Packer to Create the Master Images
**Description**: Build golden VM images (e.g., Windows with VDA, Citrix Optimizer) and upload to Azure Shared Image Gallery.  
**Repo Implementation**: Referenced but not implemented.  
- **Integration Point**: Add Packer HCL files to `pipelines/github-actions/` or a new `images/` folder. Trigger builds via CI/CD.  
- **Example Usage**: Use `infra/foundation/terraform/` for gallery setup, then Packer to populate it.  
**Key Files**: None yet; add `win11-azure.packer.hcl` (per handbook).

### Part 3: Creating the Cloud Connector VMs
**Description**: Provision VMs for Citrix Cloud Connectors with networking and security.  
**Repo Implementation**: Implemented.  
- **Terraform Code**: `workloads/daas/terraform/cloud_connectors.tf` – Creates VMs, NICs, NSG rules.  
- **Shared Infra**: `workloads/daas/terraform/data_shared_infra.tf` – References VNet/Subnet/NSG.  
**Key Files**: `workloads/daas/terraform/cloud_connectors.tf`, `workloads/daas/terraform/locals.tf`.

### Part 4: Putting the 2 Cloud Connector VMs Into the Active Directory Domain
**Description**: Use Ansible to join CC VMs to AD domain.  
**Repo Implementation**: Partially implemented.  
- **Ansible Playbooks**: `citrix/ansible/playbook-citrix.yml` – Example playbook for domain join.  
- **Roles**: `citrix/ansible/roles/citrix-baseline/tasks/` – Extend for AD tasks.  
**Key Files**: `citrix/ansible/playbook-citrix.yml`, `citrix/ansible/inventory.sample`.

### Part 5: Installing and Configuring the Cloud Connector Software
**Description**: Deploy CC software, generate config (cwc.json), and register with Citrix Cloud.  
**Repo Implementation**: Partially implemented.  
- **Ansible Roles**: `citrix/ansible/roles/citrix-baseline/tasks/` – Add tasks for CC installation.  
- **Terraform Integration**: `workloads/daas/terraform/resource_location.tf` – Provides resource location ID.  
**Key Files**: `citrix/ansible/roles/citrix-baseline/tasks/main.yml`, `workloads/daas/terraform/resource_location.tf`.

### Part 6: Creating the Hypervisor Connection and Hypervisor Resource Pool
**Description**: Connect Azure as hypervisor and create resource pools.  
**Repo Implementation**: Implemented.  
- **Terraform Code**: `workloads/daas/terraform/hosting_connection.tf` – Azure hypervisor and pool.  
**Key Files**: `workloads/daas/terraform/hosting_connection.tf`.

### Part 7: Creating a Machine Catalog on Azure
**Description**: Provision VMs from master images using MCS.  
**Repo Implementation**: Implemented.  
- **Terraform Code**: `workloads/daas/terraform/machine_catalogs.tf` – MCS catalog linked to gallery.  
- **Modules**: `citrix/terraform/modules/machine-catalog/main.tf` – Reusable catalog module.  
**Key Files**: `workloads/daas/terraform/machine_catalogs.tf`, `citrix/terraform/modules/machine-catalog/main.tf`.

### Part 8: Creating a Delivery Group
**Description**: Set up user access, desktops, and autoscaling.  
**Repo Implementation**: Implemented.  
- **Terraform Code**: `workloads/daas/terraform/delivery_groups.tf` – Delivery group with policies.  
- **Modules**: `citrix/terraform/modules/delivery-group/main.tf` – Reusable DG module.  
**Key Files**: `workloads/daas/terraform/delivery_groups.tf`, `citrix/terraform/modules/delivery-group/main.tf`.

### Part 9: Creating Policy Sets, Scopes, and Roles
**Description**: Configure admin roles, scopes, and policies (e.g., printing, HDX).  
**Repo Implementation**: Not implemented.  
- **To Add**: Create `workloads/daas/terraform/policies.tf` with Citrix provider resources for scopes/roles/policy sets.  
**Key Files**: None yet; add based on handbook examples.

### Part 10: Removing Citrix DaaS Entities Using Terraform
**Description**: Decommission resources (reverse of creation).  
**Repo Implementation**: Supported via Terraform.  
- **Usage**: Run `terraform destroy` on relevant modules (e.g., `workloads/daas/terraform/`).  
- **Pipelines**: `pipelines/github-actions/deploy.yml` – Can include destroy steps.  
**Key Files**: All Terraform files support destroy.

---

## Repository Structure

- `docs/` – Conceptual docs (pipeline-flow.md, monthly-rebuild-pattern.md)  
- `infra/foundation/terraform/` – Azure foundation (network, identity, Key Vault)  
- `workloads/daas/terraform/` – Citrix DaaS on Azure (connectors, catalogs, DGs)  
- `citrix/terraform/` – Citrix-specific modules (app-publishing, delivery-group, machine-catalog)  
- `citrix/ansible/` – Ansible for Citrix config (playbooks, roles)  
- `netscaler/terraform/` – NetScaler ADC Terraform (main.tf, variables.tf)  
- `netscaler/ansible/` – Ansible for NetScaler config  
- `pipelines/github-actions/` – CI/CD pipelines (deploy.yml, validate.yml)  
- `infra/nutanix/terraform/` – Nutanix on-prem skeleton  

---

## Getting Started

1. **Clone this repo**  

   ```bash
   git clone https://github.com/FerroqueSystems/clickops-to-gitops.git
   cd clickops-to-gitops
   ```

2. **Review docs**

    1. docs/pipeline-flow.md
    2. docs/monthly-rebuild-pattern.md

3. **Customize variables**

    1. workloads/daas/terraform/variables.tf
    2. netscaler/terraform/variables.tf
    3. infra/foundation/terraform/variables.tf

4. **Run pipelines or Terraform**

    - Validate: `pipelines/github-actions/validate.yml`
    - Deploy: `pipelines/github-actions/deploy.yml`
    - Example: `cd workloads/daas/terraform && terraform init && terraform plan`

For full handbook details, see: https://community.citrix.com/tech-zone/automation/automation-handbook-2601-part5/

4. **Run validation pipeline locally (optional)**

    1. Terraform: terraform init && terraform validate
    2. Ansible: ansible-lint (if installed)

5. **Hook up your CI/CD**

    1. Use pipelines/github-actions/ as a reference for your own pipeline.
