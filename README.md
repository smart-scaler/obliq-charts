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
- **Container Registry Access** - Contact [support@aveshasystems.com](mailto:support@aveshasystems.com) for ACR credentials

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

### 3. Install Instructions

💡 **NOTE: For easier environment variable management, see [.env file setup](./docs/prerequisites.md#environment-variables-with-env-file).**

#### Full Platform (All 28 Services)

```bash
# Required
export DEFAULT_ADMIN_EMAIL="admin@yourcompany.com"
export DEFAULT_ADMIN_PASSWORD="your-secure-password"
export OPENAI_API_KEY="sk-your-openai-api-key"

# Optional: OpenAI (defaults to Groq if unset)
export OPENAI_BASE_URL="https://api.groq.com/openai/v1"
export LS_OPENAI_BASE_URL="${OPENAI_BASE_URL:-https://api.groq.com/openai/v1}"
export SI_OPENAI_BASE_URL="${OPENAI_BASE_URL:-https://api.groq.com/openai/v1}"
export RCA_OPENAI_BASE_URL="${OPENAI_BASE_URL:-https://api.groq.com/openai/v1}"
export OPENAI_MODEL="llama-3.3-70b-versatile"

# Optional: AWS
export AWS_ROLE_ARN_AWS_MCP="arn:aws:iam::..."
export AWS_ROLE_ARN_EC2_CLOUDWATCH="arn:aws:iam::..."

# Optional: DataDog, Slack
export DD_API_KEY="your-datadog-api-key"
export DD_APP_KEY="your-datadog-app-key"
export SLACK_BOT_TOKEN="xoxb-your-slack-bot-token"

# Optional: Observability
export OTEL_JAEGER_URL="http://obliq-sre-agent-jaeger-query:16686"
export JAEGER_URL="${OTEL_JAEGER_URL:-http://demo.example.com:8080/jaeger/ui}"
export ADDITIONAL_SERVICE_TAGS=""

# Optional: Neo4j (defaults in command)
export NEO4J_USER="neo4j"
export NEO4J_PASSWORD="admin123"

# Optional: Prometheus, Loki, Jira
export PROMETHEUS_URL="http://prometheus:9090"
export PROMETHEUS_MCP_USERNAME=""
export PROMETHEUS_MCP_PASSWORD=""
export LOKI_URL="http://loki:3100"
export JIRA_BASE_URL="https://yourcompany.atlassian.net"
export JIRA_EMAIL="your-email@company.com"
export JIRA_API_TOKEN="your-jira-api-token"

helm upgrade --install obliq-sre-agent obliq-charts/obliq-sre-agent \
  --namespace obliq \
  --create-namespace \
  --dependency-update \
  --timeout 15m \
  --set global.env.openai.OPENAI_API_KEY="${OPENAI_API_KEY}" \
  --set global.env.openai.OPENAI_BASE_URL="${OPENAI_BASE_URL:-https://api.groq.com/openai/v1}" \
  --set global.env.openai.LS_OPENAI_BASE_URL="${LS_OPENAI_BASE_URL:-${OPENAI_BASE_URL:-https://api.groq.com/openai/v1}}" \
  --set global.env.openai.SI_OPENAI_BASE_URL="${SI_OPENAI_BASE_URL:-${OPENAI_BASE_URL:-https://api.groq.com/openai/v1}}" \
  --set global.env.openai.RCA_OPENAI_BASE_URL="${RCA_OPENAI_BASE_URL:-${OPENAI_BASE_URL:-https://api.groq.com/openai/v1}}" \
  --set global.env.openai.OPENAI_MODEL="${OPENAI_MODEL:-llama-3.3-70b-versatile}" \
  --set mongodb.persistence.enabled=false \
  --set prometheus.enabled=true \
  --set jaeger.enabled=true \
  --set jaeger.allInOne.enabled=true \
  --set jaeger.storage.type=none \
  --set jaeger.agent.enabled=false \
  --set jaeger.collector.enabled=false \
  --set jaeger.query.enabled=false \
  --set opentelemetry-collector.enabled=true \
  --set neo4j.enabled=true \
  --set mongodb.enabled=true \
  --set aws-mcp.enabled=true \
  --set k8s-mcp.enabled=true \
  --set gcp-mcp.enabled=true \
  --set oke-mcp.enabled=true \
  --set prometheus-mcp.enabled=true \
  --set neo4j-mcp.enabled=true \
  --set loki-mcp.enabled=true \
  --set cloudwatch-mcp.enabled=true \
  --set aws-ec2-cloudwatch-alarms.enabled=true \
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
  --set global.env.aws.AWS_ROLE_ARN_AWS_MCP="${AWS_ROLE_ARN_AWS_MCP}" \
  --set global.env.aws.AWS_ROLE_ARN_EC2_CLOUDWATCH_ALARMS="${AWS_ROLE_ARN_EC2_CLOUDWATCH}" \
  --set global.env.sg.DD_API_KEY="${DD_API_KEY}" \
  --set global.env.sg.DD_APP_KEY="${DD_APP_KEY}" \
  --set global.env.sg.OTEL_JAEGER_URL="${OTEL_JAEGER_URL}" \
  --set global.env.sg.JAEGER_URL="${JAEGER_URL:-${OTEL_JAEGER_URL:-http://demo.example.com:8080/jaeger/ui}}" \
  --set global.env.sg.ADDITIONAL_SERVICE_TAGS="${ADDITIONAL_SERVICE_TAGS}" \
  --set global.env.database.NEO4J_USER="${NEO4J_USER:-neo4j}" \
  --set global.env.database.NEO4J_PASSWORD="${NEO4J_PASSWORD:-admin123}" \
  --set global.env.slack.SLACK_BOT_TOKEN="${SLACK_BOT_TOKEN}" \
  --set global.env.prometheus.PROMETHEUS_URL="${PROMETHEUS_URL}" \
  --set global.env.prometheus.PROMETHEUS_MCP_USERNAME="${PROMETHEUS_MCP_USERNAME}" \
  --set global.env.prometheus.PROMETHEUS_MCP_PASSWORD="${PROMETHEUS_MCP_PASSWORD}" \
  --set global.env.loki.LOKI_URL="${LOKI_URL}" \
  --set global.env.jira.JIRA_BASE_URL="${JIRA_BASE_URL}" \
  --set global.env.jira.JIRA_EMAIL="${JIRA_EMAIL}" \
  --set global.env.jira.JIRA_API_TOKEN="${JIRA_API_TOKEN}" \
  --set global.env.backend.DEFAULT_ADMIN_EMAIL="${DEFAULT_ADMIN_EMAIL}" \
  --set global.env.backend.DEFAULT_ADMIN_PASSWORD="${DEFAULT_ADMIN_PASSWORD}" \
  --set obliq-unified-ui.service.type=LoadBalancer
```

#### Dry Run (validate without applying)

Add `--dry-run --debug` to the command above to render and validate templates without creating resources.

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

- **ImagePullBackOff**: Get ACR credentials from [support@aveshasystems.com](mailto:support@aveshasystems.com)
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

- **Email**: [support@aveshasystems.com](mailto:support@aveshasystems.com)
- **Documentation**: See linked guides above
- **Issues**: Include pod logs and deployment details

---

📊 **For detailed service configuration:** Visit the [Services Guide](./docs/services.md)
