#!/bin/bash

# Script to update all Helm chart dependencies
# Run this before packaging or installing charts locally

set -e

echo "🔄 Updating Helm chart dependencies..."

# Update dependencies for the main chart
echo "📦 Updating main chart dependencies..."
helm dependency update .

# Update dependencies for all sub-charts that have them
echo "📦 Checking sub-charts for dependencies..."
for chart_dir in charts/*/; do
  if [[ -f "${chart_dir}Chart.yaml" ]]; then
    echo "🔍 Checking dependencies for ${chart_dir}"
    if grep -q "^dependencies:" "${chart_dir}Chart.yaml"; then
      echo "⬇️  Updating dependencies for ${chart_dir}"
      helm dependency update "${chart_dir}"
    else
      echo "✅ No external dependencies found for ${chart_dir}"
    fi
  fi
done

echo "✅ All dependencies updated successfully!"
echo ""
echo "You can now:"
echo "  - Package the chart: helm package ."
echo "  - Install locally: helm install obliq-sre-agent . --namespace avesha --create-namespace"
echo "  - Run dry-run: helm install obliq-sre-agent . --dry-run --debug"
