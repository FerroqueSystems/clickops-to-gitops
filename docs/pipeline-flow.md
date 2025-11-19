# Pipeline Flow – From Click-Ops to Git-Ops

This document explains the **end-to-end flow** from a change in Git to an updated Citrix / NetScaler environment.

## 1. Admin Workflow

1. Admin edits a configuration file (Citrix or NetScaler Terraform).
2. Creates a branch and pull request.
3. PR triggers the validation pipeline (terraform validate, etc.).

## 2. Validation Stage

- Syntax and formatting checks
- Drift detection (optional)
- Security or policy checks (optional)

## 3. Deployment Stage

On merge to main:
- Pipeline authenticates to Citrix / NetScaler.
- Runs terraform init/plan/apply.
- Optionally runs Ansible for guest or policy config.

## 4. Monthly Rebuild Pattern

See `monthly-rebuild-pattern.md` for more detail.
