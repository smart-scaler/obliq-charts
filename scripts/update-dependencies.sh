#!/bin/bash

# Script to update all Helm chart dependencies
# Run this before packaging or installing charts locally

set -e

echo "🔄 Updating Helm chart dependencies..."

# Clean cached dependencies to avoid version conflicts
echo "🧹 Cleaning cached dependencies and lock files..."
rm -f Chart.lock || true
rm -rf charts/*/charts || true

# Also clean sub-chart locks
for chart_dir in charts/*/; do
  if [[ -f "${chart_dir}Chart.lock" ]]; then
    rm -f "${chart_dir}Chart.lock" || true
  fi
done

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
echo "  - Install locally: helm install obliq-sre-agent . --namespace obliq --create-namespace"
echo "  - Run dry-run: helm install obliq-sre-agent . --dry-run --debug"
