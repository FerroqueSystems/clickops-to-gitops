#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
terraform_dir="${1:-$script_dir/../terraform}"
output_file="${2:-$script_dir/inventory.ini}"

terraform -chdir="$terraform_dir" output -raw ansible_inventory > "$output_file"

echo "Wrote Ansible inventory to $output_file"
