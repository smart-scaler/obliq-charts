#!/bin/bash

# Optional: update root Helm chart dependencies (e.g. after adding a new subchart).
# MongoDB and Jaeger subchart deps are vendored; no need to run this for a normal install.

set -e

echo "🔄 Updating root chart dependencies..."
rm -f Chart.lock || true
helm dependency update .
echo "✅ Root dependencies updated."
echo ""
echo "You can now:"
echo "  - Package the chart: helm package ."
echo "  - Install locally: helm install obliq-sre-agent . --namespace obliq --create-namespace"
echo "  - Run dry-run: helm install obliq-sre-agent . --dry-run --debug"
