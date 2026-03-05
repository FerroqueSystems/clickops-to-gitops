# Self-hosted runner setup (Linux) — for Nutanix workflows

This document explains how to register and run a self-hosted GitHub Actions
runner on a Linux host in your Nutanix environment. The `nutanix-deploy.yml`
workflow expects a runner with the labels `self-hosted`, `linux`, and `nutanix`.

1. Create a registration token

- Go to your repository -> Settings -> Actions -> Runners -> New self-hosted runner.
- Follow the UI to pick the runner OS (Linux) and copy the generated
  registration commands.

2. Install the runner (example, systemd)

Run these commands on the target Linux host (example uses Ubuntu). Replace
values with the release URL and token provided by the GitHub UI.

```bash
# create a folder for the runner
mkdir -p /opt/actions-runner && cd /opt/actions-runner

# download the runner package (check latest release URL on GitHub)
curl -Lo actions-runner.tar.gz https://github.com/actions/runner/releases/download/v2.x.x/actions-runner-linux-x64-2.x.x.tar.gz
tar xzf actions-runner.tar.gz

# install prerequisites (example)
sudo apt-get update && sudo apt-get install -y libicu[0-9][0-9] curl jq

# configure the runner (this will ask for the registration token)
./config.sh --url https://github.com/<owner>/<repo> --token YOUR_REGISTRATION_TOKEN --labels "linux,nutanix" --work _work

# run interactively to test
./run.sh

# install the runner as a service (systemd)
sudo ./svc.sh install
sudo ./svc.sh start
```

**Automated bootstrap (recommended):** Use the provided `bootstrap-runner.sh` script
to automate token fetching and setup. It requires a GitHub PAT with repo scope.

```bash
# Copy the script to your Linux host
scp pipelines/github-actions/bootstrap-runner.sh user@linux-host:/tmp/

# Run it (replace with your values)
ssh user@linux-host "chmod +x /tmp/bootstrap-runner.sh && /tmp/bootstrap-runner.sh <owner> <repo> <pat> [version]"
```

3. Automating registration (optional)

- To provision runners automatically, use the GitHub REST API to create a
  registration token and pass it to `config.sh` during bootstrap. The token
  requires a PAT with `repo` or `admin:org` scope depending on target.

4. Notes and best practices

- Keep the registration token secret; it is single-use and short-lived.
- Ensure the runner has Terraform installed (or let the workflow install it)
  and network access to the Nutanix Prism endpoint.
- Use a dedicated, hardened host or VM for runners and monitor resource usage.
- On cloud or automated builds, rotate and reprovision runners regularly.
