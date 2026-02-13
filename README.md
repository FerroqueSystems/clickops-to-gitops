# From Click-Ops to Git-Ops: Sample Citrix & NetScaler Automation Repo

This repository accompanies the session **"From Click-Ops to Git-Ops: Rebuilding Your Citrix & NetScaler Worlds Every 30 Days"**.

It is designed as a **teaching repo** – not production-ready code – to show how you can:

- Define your Citrix and NetScaler configuration as **code**
- Use **Git** as the source of truth
- Drive deployments via **CI/CD pipelines**
- Implement a **monthly rebuild pattern** to reduce security risk and configuration drift

> ⚠️ Disclaimer: All examples here are simplified and should be adapted, validated, and security-hardened before use in a live environment.

---

## Repository Structure

- `docs/` – Conceptual documentation and diagrams for the session  
- `citrix/terraform/` – Terraform examples for Citrix-related automation  
- `citrix/ansible/` – Ansible examples for guest/infra config  
- `netscaler/terraform/` – Terraform examples for NetScaler/ADC  
- `netscaler/ansible/` – Ansible playbooks/roles for config tasks  
- `pipelines/github-actions/` – Sample CI/CD pipeline definitions  
- `scripts/` – Misc helper scripts (PowerShell, Python)

- `infra/nutanix/terraform/` – (NEW) Nutanix on-prem Terraform skeleton
    for initial on-prem development. Azure examples remain in-place; pick
    the appropriate folder and backend when running Terraform.

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

    1. citrix/terraform/variables.tf
    2. netscaler/terraform/variables.tf

4. **Run validation pipeline locally (optional)**

    1. Terraform: terraform init && terraform validate
    2. Ansible: ansible-lint (if installed)

5. **Hook up your CI/CD**

    1. Use pipelines/github-actions/ as a reference for your own pipeline.
