# Obliq Chart Helm Repository

This repository publishes the Obliq master Helm chart to GitHub Pages, making it available as a Helm repository.

## 📦 Using the Helm Repository

### Add Repository
```bash
helm repo add obliq-charts https://smart-scaler.github.io/obliq-charts/
helm repo update
```

### List Available Charts
```bash
helm search repo obliq-charts
```

### Install Chart
```bash
# Install the Obliq master chart (contains all services)
helm install obliq-sre-agent obliq-charts/obliq-sre-agent
```

## 🚀 Publishing Chart

### Manual Release (Workflow Dispatch)
1. Go to **Actions** → **Release Obliq Helm Chart to gh-pages Branch**
2. Click **Run workflow**
3. Ensure "Release Obliq Master Helm Chart" is set to "Yes"
4. Click **Run workflow**

## 📋 Available Chart

- **obliq-sre-agent** - Master chart containing all Obliq services and components:
  - Active inventory management
  - Anomaly detection
  - Auto-remediation
  - Unified web interface
  - AWS integrations (MCP, CloudWatch)
  - Backend API services
  - Incident management
  - Infrastructure monitoring
  - Kubernetes integrations
  - Log processing (Loki)
  - Databases (MongoDB, Neo4j)
  - OpenTelemetry collection
  - Orchestration services
  - Prometheus monitoring
  - Root cause analysis
  - Service graph engine
  - Slack integration

## 🔧 Repository Configuration

The Helm repository is hosted at: `https://smart-scaler.github.io/obliq-charts/`

Charts are automatically indexed and made available through GitHub Pages on the `gh-pages` branch.
