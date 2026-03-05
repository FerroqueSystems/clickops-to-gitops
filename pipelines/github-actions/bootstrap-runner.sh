#!/bin/bash
# Bootstrap script for automated GitHub Actions runner setup on Linux (Nutanix env)
# This script fetches a registration token via GitHub API using a PAT, downloads
# the runner, configures it, and installs as a systemd service.
#
# Prerequisites:
# - GitHub PAT with 'repo' scope (for repo-level runners) or 'admin:org' (for org-level)
# - curl, jq installed (script installs them if missing)
# - sudo access for service installation
#
# Usage: ./bootstrap-runner.sh <owner> <repo> <pat> [runner_version]
# Example: ./bootstrap-runner.sh myorg myrepo ghp_1234567890abcdef 2.311.0

set -e

OWNER="$1"
REPO="$2"
PAT="$3"
RUNNER_VERSION="${4:-2.311.0}"  # Default to a recent version; update as needed

if [ -z "$OWNER" ] || [ -z "$REPO" ] || [ -z "$PAT" ]; then
  echo "Usage: $0 <owner> <repo> <pat> [runner_version]"
  exit 1
fi

# Install prerequisites
echo "Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y libicu70 curl jq  # Adjust libicu version for your distro

# Create runner directory
RUNNER_DIR="/opt/actions-runner"
sudo mkdir -p "$RUNNER_DIR"
cd "$RUNNER_DIR"

# Download runner
echo "Downloading GitHub Actions runner v$RUNNER_VERSION..."
curl -Lo actions-runner.tar.gz "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
tar xzf actions-runner.tar.gz

# Fetch registration token
echo "Fetching registration token..."
TOKEN_RESPONSE=$(curl -s -X POST \
  -H "Authorization: token $PAT" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$OWNER/$REPO/actions/runners/registration-token")

TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.token')
if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
  echo "Failed to get registration token. Check PAT permissions and repo/org access."
  echo "Response: $TOKEN_RESPONSE"
  exit 1
fi

# Configure runner
echo "Configuring runner..."
./config.sh --url "https://github.com/$OWNER/$REPO" --token "$TOKEN" --labels "linux,nutanix" --work _work --unattended

# Install and start service
echo "Installing as systemd service..."
sudo ./svc.sh install
sudo ./svc.sh start

echo "Runner setup complete. Check status with: sudo ./svc.sh status"