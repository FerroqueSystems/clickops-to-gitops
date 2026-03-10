# Staged Execution

This folder lets you run the NetScaler deployment in ordered phases.

Run all commands from `infra/workloads/netscaler/terraform`.

## Stage 1 - Base Infra + ADC VMs

```bash
terraform plan \
  -var-file=clickops.tfvars \
  -var-file=stages/01-base/stage.tfvars \
  -out stages/01-base/stage.plan

terraform apply stages/01-base/stage.plan
```

## Notes

- `clickops.tfvars` remains your base config.
- Stage files only override what is needed for each phase.
