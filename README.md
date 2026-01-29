# Obliq AI SRE Agent Platform

A comprehensive AI-powered Site Reliability Engineering platform deployed as a single Helm chart.

## 📖 Documentation

- **[🚀 Getting Started](#-quick-install)** - Installation guide
- **[⚙️ Services Configuration](./docs/services.md)** - Enable/disable services and integrations
- **[📋 Parameters Reference](./docs/parameters.md)** - Complete configuration options and examples
- **[🔐 Secret Management](./docs/secret-management.md)** - Kubernetes secrets and credentials
- **[📋 Prerequisites](./docs/prerequisites.md)** - System requirements and integrations

## ⚡ Quick Install

### Prerequisites

- **Kubernetes cluster** (v1.19+)
- **Helm** (v3.8+)
- **Container Registry Access** - Contact <support@aveshasystems.com> for ACR credentials

📚 **Important Setup Guides**:

- **[Kubernetes Permissions](./docs/kubernetes-permissions.md)** - Required cluster permissions and RBAC setup
- **[Prerequisites Details](./docs/prerequisites.md)** - Comprehensive system requirements and integrations

### 1. Add Helm Repository

```bash
# Add the Obliq Charts Helm repository
helm repo add obliq-charts https://repo.obliq.avesha.io/
helm repo update
```

### 2. Create Registry Secret

```bash
# Get credentials from support@aveshasystems.com
kubectl create namespace obliq --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret docker-registry registry \
  --docker-username=YOUR_USERNAME_FROM_AVESHA \
  --docker-password=YOUR_PASSWORD_FROM_AVESHA \
  --docker-email=your-email@company.com \
  --docker-server=https://avesha.azurecr.io/ \
  -n obliq
```

📚 **For advanced secret management:** Visit the [Secret Management Guide](./docs/secret-management.md)

### 3. Install Options

💡 **Optional: For easier environment variable management, see [.env file setup](./docs/prerequisites.md#environment-variables-with-env-file).**

#### Minimal (Core AI Services)

```bash
export DEFAULT_ADMIN_EMAIL="admin@yourcompany.com"  # Custom admin email
export DEFAULT_ADMIN_PASSWORD="your-secure-password"  # Custom admin password

# Install with LoadBalancer for external UI access
helm install obliq-sre-agent obliq-charts/obliq-sre-agent \
  --namespace obliq \
  --create-namespace \
  --dependency-update `# Update chart dependencies before install` \
  --set global.env.backend.DEFAULT_ADMIN_EMAIL="${DEFAULT_ADMIN_EMAIL}" `# Custom admin email` \
  --set global.env.backend.DEFAULT_ADMIN_PASSWORD="${DEFAULT_ADMIN_PASSWORD}" `# Custom admin password` \
  --set obliq-unified-ui.service.type=LoadBalancer `# Expose UI externally` \
  --timeout 15m
```

#### Full Platform (All 27 Services)

```bash
export DEFAULT_ADMIN_EMAIL="admin@yourcompany.com"  # Custom admin email
export DEFAULT_ADMIN_PASSWORD="your-secure-password"  # Custom admin password

# Optional: Additional credentials for integrations
export DD_API_KEY="your-datadog-api-key"  # For DataDog integration
export DD_APP_KEY="your-datadog-app-key"  # For DataDog integration
export SLACK_BOT_TOKEN="xoxb-your-slack-bot-token"  # For Slack integration

# Install with ALL 27 services enabled
helm install obliq-sre-agent obliq-charts/obliq-sre-agent \
  --namespace obliq \
  --create-namespace \
  --dependency-update `# Update chart dependencies before install` \
  --set global.env.backend.DEFAULT_ADMIN_EMAIL="${DEFAULT_ADMIN_EMAIL}" `# Custom admin email` \
  --set global.env.backend.DEFAULT_ADMIN_PASSWORD="${DEFAULT_ADMIN_PASSWORD}" `# Custom admin password` \
  --set mongodb.persistence.enabled=false `# Disable persistent storage for demo` \
  --set neo4j.volumes.data.mode=volume `# Use volume for Neo4j data` \
  --set neo4j.volumes.data.volume.emptyDir="{}" `# Use emptyDir for Neo4j` \
  `# Enable ALL 27 services` \
  --set prometheus.enabled=true \
  --set jaeger.enabled=true \
  --set opentelemetry-collector.enabled=true \
  --set neo4j.enabled=true \
  --set mongodb.enabled=true \
  --set k8s-mcp.enabled=true \
  --set prometheus-mcp.enabled=true \
  --set neo4j-mcp.enabled=true \
  --set loki-mcp.enabled=true \
  --set kubernetes-events-ingester.enabled=true \
  --set slack-ingester.enabled=true \
  --set anomaly-detection.enabled=true \
  --set active-inventory.enabled=true \
  --set incident-manager.enabled=true \
  --set incident-ingester.enabled=true \
  --set rca-agent.enabled=true \
  --set auto-remediation.enabled=true \
  --set hitl-manager.enabled=true \
  --set backend.enabled=true \
  --set service-graph-engine.enabled=true \
  --set infra-agent.enabled=true \
  --set obliq-unified-ui.enabled=true \
  --set orchestrator.enabled=true \
  `# Optional: Integration credentials` \
  --set global.env.sg.DD_API_KEY="${DD_API_KEY}" \
  --set global.env.sg.DD_APP_KEY="${DD_APP_KEY}" \
  --set global.env.slack.SLACK_BOT_TOKEN="${SLACK_BOT_TOKEN}" \
  --set obliq-unified-ui.service.type=LoadBalancer `# Expose UI externally` \
  --timeout 15m
```

📋 **For full integration with all services:** See [Complete Deployment Examples](./docs/parameters.md#--complete-deployment-examples)

⚠️ **Important**: Full integration requires additional setup:

- **[Kubernetes Permissions](./docs/kubernetes-permissions.md)** - Required RBAC and cluster permissions
- **[Service Dependencies](./docs/services.md)** - Understanding service relationships and dependencies
- **[Secret Management](./docs/secret-management.md)** - Advanced credential and secret handling

### 4. Verify Installation

```bash
# Check pod status (all should be Running)
kubectl get pods -n obliq

# Check deployment status and notes
helm status obliq-sre-agent -n obliq

# Verify core services are ready
kubectl get deployments -n obliq

# Check for any issues
kubectl get events -n obliq --sort-by='.lastTimestamp' | tail -10
```

### 5. Access the UI

```bash
# Get the external IP (may take a few minutes to provision)
kubectl get service -n obliq obliq-unified-ui

# Access at: http://<EXTERNAL-IP>:80
```

🔐 **Default Login Credentials:**

Use the username and password you provided earlier during installation, based on the following:

```sh
export DEFAULT_ADMIN_EMAIL="admin@yourcompany.com"  # Custom admin email
export DEFAULT_ADMIN_PASSWORD="your-secure-password"  # Custom admin password
```

**Alternative access methods:**

- **NodePort**: Add `--set obliq-unified-ui.service.type=NodePort` instead of LoadBalancer
- **Port Forward** (ClusterIP): `kubectl port-forward -n obliq service/obliq-unified-ui 8080:80`

## 🗑️ Uninstall

```bash
# Uninstall the application
helm uninstall obliq-sre-agent -n obliq

# Remove the namespace (optional)
kubectl delete namespace obliq
```

📋 **For complete configuration options:** Visit the [Parameters Reference](./docs/parameters.md)

## 🆘 Troubleshooting

### Common Issues

- **ImagePullBackOff**: Get ACR credentials from <support@aveshasystems.com>
- **Pod failures**: Check logs with `kubectl logs -n obliq <pod-name>`
- **External access**: External HTTP/HTTPS access requires separate ingress controller installation

### Basic Debugging

```bash
# Check pod status
kubectl get pods -n obliq

# View logs
kubectl logs -n obliq deployment/backend -f

# Check events
kubectl get events -n obliq --sort-by='.lastTimestamp' | tail -10
```

## 📞 Support

- **Email**: <support@aveshasystems.com>
- **Documentation**: See linked guides above
- **Issues**: Include pod logs and deployment details

---

📊 **For detailed service configuration:** Visit the [Services Guide](./docs/services.md)
