# Services Configuration Reference

This document provides a comprehensive reference for all services in the Obliq SRE Agent platform, including core services, optional services, and external tools.

## 📋 Service Categories

### ✅ **Core Services** (Always Enabled)
Essential services that cannot be disabled - they're required for platform functionality.

### 🔌 **MCP Services** (Optional)
Model Context Protocol servers for integrating with external systems - disabled by default.

### 📊 **Integration Services** (Optional)
Additional services for external integrations - disabled by default to reduce complexity.

### 🔧 **External Tools** (Not Included)
External tools that can be installed separately for enhanced functionality.

---

## ✅ Core Services (Always Enabled)

These services are essential for platform functionality and cannot be disabled.

### Databases & Storage

| Service | Status | Description | Requirements |
|---------|--------|-------------|--------------|
| **neo4j** | `enabled: true` | Graph database for relationships and topology | None - internal service |
| **mongodb** | `enabled: true` | Document database for application data | None - internal service |
| **opentelemetry-collector** | `enabled: true` | Observability data collection and processing | None - internal service |

### Application Core

| Service | Status | Description | Requirements |
|---------|--------|-------------|--------------|
| **backend** | `enabled: true` | Main API server and backend functionality | OpenAI API key |
| **avesha-unified-ui** | `enabled: true` | Web interface and dashboard | None |
| **orchestrator** | `enabled: true` | Workflow orchestration engine | OpenAI API key |

### AI/ML Services

| Service | Status | Description | Requirements |
|---------|--------|-------------|--------------|
| **rca-agent** | `enabled: true` | Root cause analysis engine | OpenAI API key |
| **anomaly-detection** | `enabled: true` | Anomaly detection and alerting | OpenAI API key |
| **auto-remediation** | `enabled: true` | Automated fixes and responses | OpenAI API key |
| **incident-manager** | `enabled: true` | Incident management system | OpenAI API key |

### Infrastructure Services

| Service | Status | Description | Requirements |
|---------|--------|-------------|--------------|
| **active-inventory** | `enabled: true` | Infrastructure inventory and discovery | None - internal service |
| **infra-agent** | `enabled: true` | Infrastructure monitoring agent | None - internal service |

### Core MCP Service

| Service | Status | Description | Requirements |
|---------|--------|-------------|--------------|
| **k8s-mcp** | `enabled: true` | Kubernetes Model Context Protocol server | kubeconfig file |

⚠️ **Important**: Core AI services require an OpenAI API key configured via `global.env.openai.OPENAI_API_KEY`. They will fail to start without this credential.

---

## 🔌 MCP Services (Optional)

Model Context Protocol services are **disabled by default** to reduce resource usage and complexity. Enable them individually based on your integration needs.

⚠️ **IMPORTANT**: Each MCP service requires specific credentials and access configurations.

| MCP Service | Purpose | Required Credentials | Enable Command |
|-------------|---------|---------------------|----------------|
| **`aws-mcp`** | AWS EC2/CloudWatch integration | • `AWS_ACCESS_KEY_ID`<br>• `AWS_SECRET_ACCESS_KEY`<br>• `AWS_ROLE_ARN_AWS_MCP` | `--set aws-mcp.enabled=true` |
| **`prometheus-mcp`** | Prometheus metrics integration | • `PROMETHEUS_URL`<br>• `PROMETHEUS_MCP_USERNAME`<br>• `PROMETHEUS_MCP_PASSWORD` | `--set prometheus-mcp.enabled=true` |
| **`neo4j-mcp`** | Neo4j graph database integration | Uses internal Neo4j by default, optional external credentials | `--set neo4j-mcp.enabled=true` |
| **`loki-mcp`** | Loki logs integration | • `LOKI_URL`<br>• `LOKI_USERNAME` (optional)<br>• `LOKI_PASSWORD` (optional)<br>• `LOKI_TOKEN` (optional) | `--set loki-mcp.enabled=true` |
| **`cloudwatch-mcp`** | AWS CloudWatch integration | • `AWS_ACCESS_KEY_ID`<br>• `AWS_SECRET_ACCESS_KEY`<br>• CloudWatch permissions | `--set cloudwatch-mcp.enabled=true` |

### MCP Configuration Examples

#### AWS MCP Integration
```bash
# Required credentials
export AWS_ACCESS_KEY_ID="your-aws-access-key"
export AWS_SECRET_ACCESS_KEY="your-aws-secret-key"
export AWS_ROLE_ARN_AWS_MCP="arn:aws:iam::123456789012:role/your-aws-mcp-role"

# Enable command
--set aws-mcp.enabled=true \
--set global.env.aws.AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
--set global.env.aws.AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
--set global.env.aws.AWS_ROLE_ARN_AWS_MCP="${AWS_ROLE_ARN_AWS_MCP}"
```

#### Prometheus MCP Integration
```bash
# Required credentials
export PROMETHEUS_URL="http://your-prometheus:9090"
export PROMETHEUS_MCP_USERNAME="your-username"
export PROMETHEUS_MCP_PASSWORD="your-password"

# Enable command
--set prometheus-mcp.enabled=true \
--set global.env.prometheus.PROMETHEUS_URL="${PROMETHEUS_URL}" \
--set global.env.prometheus.PROMETHEUS_MCP_USERNAME="${PROMETHEUS_MCP_USERNAME}" \
--set global.env.prometheus.PROMETHEUS_MCP_PASSWORD="${PROMETHEUS_MCP_PASSWORD}"
```

#### Neo4j MCP Integration
```bash
# Uses internal Neo4j by default
--set neo4j-mcp.enabled=true

# Or configure external Neo4j
--set neo4j-mcp.enabled=true \
--set global.env.database.NEO4J_USER="your-neo4j-user" \
--set global.env.database.NEO4J_PASSWORD="your-neo4j-password" \
--set global.env.mcp.NEO4J_MCP_USERNAME="your-mcp-username" \
--set global.env.mcp.NEO4J_MCP_PASSWORD="your-mcp-password"
```

#### Loki MCP Integration
```bash
# Required credentials
export LOKI_URL="http://your-loki:3100"

# Enable command
--set loki-mcp.enabled=true \
--set global.env.loki.LOKI_URL="${LOKI_URL}"
# Optional authentication:
# --set global.env.loki.LOKI_USERNAME="${LOKI_USERNAME}" \
# --set global.env.loki.LOKI_PASSWORD="${LOKI_PASSWORD}" \
# --set global.env.loki.LOKI_TOKEN="${LOKI_TOKEN}"
```

#### CloudWatch MCP Integration
```bash
# Required credentials
export AWS_ACCESS_KEY_ID="your-aws-access-key"
export AWS_SECRET_ACCESS_KEY="your-aws-secret-key"

# Enable command
--set cloudwatch-mcp.enabled=true \
--set global.env.aws.AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
--set global.env.aws.AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
```

---

## 📊 Integration Services (Optional)

Integration services are **disabled by default** to prevent deployment failures when credentials are not available. Enable them individually based on your integration requirements.

| Service | Purpose | Required Credentials | Enable Command |
|---------|---------|---------------------|----------------|
| **`service-graph-engine`** | DataDog service topology mapping | • `DD_API_KEY`<br>• `DD_APP_KEY`<br>• `DD_SITE` (optional) | `--set service-graph-engine.enabled=true` |
| **`slack-ingester`** | Slack message ingestion | • `SLACK_BOT_TOKEN`<br>• `SLACK_WEBHOOK_URL` (optional) | `--set slack-ingester.enabled=true` |
| **`kubernetes-events-ingester`** | K8s events collection | • `kubeconfig` file<br>• Cluster access permissions | `--set kubernetes-events-ingester.enabled=true` |
| **`aws-ec2-cloudwatch-alarms`** | AWS CloudWatch monitoring | • `AWS_ACCESS_KEY_ID`<br>• `AWS_SECRET_ACCESS_KEY`<br>• `AWS_ROLE_ARN_EC2_CLOUDWATCH_ALARMS` | `--set aws-ec2-cloudwatch-alarms.enabled=true` |

### Integration Configuration Examples

#### DataDog Integration (service-graph-engine)
```bash
# Required credentials
export DD_API_KEY="your-datadog-api-key"
export DD_APP_KEY="your-datadog-app-key"

# Enable command
--set service-graph-engine.enabled=true \
--set global.env.sg.DD_API_KEY="${DD_API_KEY}" \
--set global.env.sg.DD_APP_KEY="${DD_APP_KEY}" \
--set global.env.sg.DD_SITE="us5.datadoghq.com" \
--set global.env.sg.DD_ENVIRONMENTS="production"
```

#### Slack Integration (slack-ingester)
```bash
# Required credentials
export SLACK_BOT_TOKEN="xoxb-your-slack-bot-token"

# Enable command
--set slack-ingester.enabled=true \
--set global.env.slack.SLACK_BOT_TOKEN="${SLACK_BOT_TOKEN}" \
--set global.env.slack.SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL}"  # Optional
```

#### Kubernetes Events Ingestion
```bash
# Enable command
--set kubernetes-events-ingester.enabled=true \
--set-file global.kubeconfig.content=./kubeconfig
```

#### AWS CloudWatch Alarms
```bash
# Required credentials
export AWS_ACCESS_KEY_ID="your-aws-access-key"
export AWS_SECRET_ACCESS_KEY="your-aws-secret-key"
export AWS_ROLE_ARN_EC2_CLOUDWATCH="arn:aws:iam::123456789012:role/your-cloudwatch-role"

# Enable command
--set aws-ec2-cloudwatch-alarms.enabled=true \
--set global.env.aws.AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
--set global.env.aws.AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
--set global.env.aws.AWS_ROLE_ARN_EC2_CLOUDWATCH_ALARMS="${AWS_ROLE_ARN_EC2_CLOUDWATCH}"
```

---

## 🔧 External Tools (Not Included)

These external tools are **NOT included** in the Obliq chart but can be installed separately for enhanced functionality.

| Tool | Purpose | Status | Installation |
|------|---------|--------|-------------|
| **cert-manager** | SSL certificate management | External Add-on | Install from upstream |
| **ingress-nginx** | HTTP/HTTPS routing and load balancing | External Add-on | Install from upstream |

#### External Installation Required:
- **cert-manager**: Install separately if SSL is needed. See official cert-manager documentation.
- **ingress-nginx**: Install separately for external access. See official ingress-nginx documentation.

---

## 🔧 JIRA Integration (Optional)

While not a separate service, JIRA integration can be enabled by providing credentials that affect multiple services:

```bash
# Enable JIRA integration (affects multiple services)
--set global.env.jira.JIRA_BASE_URL="${JIRA_BASE_URL}" \
--set global.env.jira.JIRA_EMAIL="${JIRA_EMAIL}" \
--set global.env.jira.JIRA_API_TOKEN="${JIRA_API_TOKEN}" \
--set global.env.jira.JIRA_PROJECT_KEY="${JIRA_PROJECT_KEY}"
```

---

## 📋 Complete Configuration Examples

Before running any of the examples below, ensure you have added the Helm repository:

```bash
helm repo add obliq-charts https://smart-scaler.github.io/obliq-charts/
helm repo update
```

### Minimal Deployment (Core Services Only)
```bash
helm install obliq-sre-agent obliq-charts/obliq-sre-agent \
  --namespace avesha \
  --create-namespace \
  --set-file global.kubeconfig.content=./kubeconfig \
  --set global.env.openai.OPENAI_API_KEY="${OPENAI_API_KEY}" \
  --set backend.ingress.enabled=true \
  --set avesha-unified-ui.ingress.enabled=true
```

### AWS Integration Deployment
```bash
helm install obliq-sre-agent obliq-charts/obliq-sre-agent \
  --namespace avesha \
  --create-namespace \
  --set-file global.kubeconfig.content=./kubeconfig \
  --set global.env.openai.OPENAI_API_KEY="${OPENAI_API_KEY}" \
  # Enable AWS MCP services
  --set aws-mcp.enabled=true \
  --set cloudwatch-mcp.enabled=true \
  --set aws-ec2-cloudwatch-alarms.enabled=true \
  # AWS credentials
  --set global.env.aws.AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
  --set global.env.aws.AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  --set global.env.aws.AWS_ROLE_ARN_AWS_MCP="${AWS_ROLE_ARN_AWS_MCP}" \
  --set global.env.aws.AWS_ROLE_ARN_EC2_CLOUDWATCH_ALARMS="${AWS_ROLE_ARN_EC2_CLOUDWATCH}" \
  --set backend.ingress.enabled=true \
  --set avesha-unified-ui.ingress.enabled=true
```

### Full Integration Deployment
```bash
helm install obliq-sre-agent obliq-charts/obliq-sre-agent \
  --namespace avesha \
  --create-namespace \
  --set-file global.kubeconfig.content=./kubeconfig \
  --set global.env.openai.OPENAI_API_KEY="${OPENAI_API_KEY}" \
  # Enable optional MCP services
  --set aws-mcp.enabled=true \
  --set prometheus-mcp.enabled=true \
  --set neo4j-mcp.enabled=true \
  --set loki-mcp.enabled=true \
  --set cloudwatch-mcp.enabled=true \
  # Enable optional integration services
  --set service-graph-engine.enabled=true \
  --set slack-ingester.enabled=true \
  --set kubernetes-events-ingester.enabled=true \
  --set aws-ec2-cloudwatch-alarms.enabled=true \
  # Provide all required credentials
  --set global.env.aws.AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
  --set global.env.aws.AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  --set global.env.aws.AWS_ROLE_ARN_AWS_MCP="${AWS_ROLE_ARN_AWS_MCP}" \
  --set global.env.aws.AWS_ROLE_ARN_EC2_CLOUDWATCH_ALARMS="${AWS_ROLE_ARN_EC2_CLOUDWATCH}" \
  --set global.env.sg.DD_API_KEY="${DD_API_KEY}" \
  --set global.env.sg.DD_APP_KEY="${DD_APP_KEY}" \
  --set global.env.slack.SLACK_BOT_TOKEN="${SLACK_BOT_TOKEN}" \
  --set global.env.prometheus.PROMETHEUS_URL="${PROMETHEUS_URL}" \
  --set global.env.prometheus.PROMETHEUS_MCP_USERNAME="${PROMETHEUS_MCP_USERNAME}" \
  --set global.env.prometheus.PROMETHEUS_MCP_PASSWORD="${PROMETHEUS_MCP_PASSWORD}" \
  --set global.env.loki.LOKI_URL="${LOKI_URL}" \
  --set global.env.jira.JIRA_BASE_URL="${JIRA_BASE_URL}" \
  --set global.env.jira.JIRA_EMAIL="${JIRA_EMAIL}" \
  --set global.env.jira.JIRA_API_TOKEN="${JIRA_API_TOKEN}" \
  --set backend.ingress.enabled=true \
  --set avesha-unified-ui.ingress.enabled=true
```

---

## 🔍 Service Dependencies

### Critical Dependencies
- **OpenAI API Key**: Required for all AI/ML services (rca-agent, anomaly-detection, auto-remediation, incident-manager, orchestrator, backend)
- **kubeconfig**: Required for k8s-mcp (core service) and kubernetes-events-ingester (optional)

### Optional Dependencies
- **AWS Credentials**: Required for aws-mcp, cloudwatch-mcp, aws-ec2-cloudwatch-alarms
- **DataDog Credentials**: Required for service-graph-engine
- **Slack Token**: Required for slack-ingester
- **Prometheus Credentials**: Required for prometheus-mcp
- **Loki URL**: Required for loki-mcp

---

## 🆘 Troubleshooting

### Common Issues

1. **Service fails to start**: Check if required credentials are provided
2. **Permission denied**: Verify credential formats and permissions
3. **Connection timeouts**: Ensure network connectivity to external services
4. **Authentication failures**: Validate credential values and expiry

### Verification Commands
```bash
# Check service status
kubectl get pods -n avesha

# View service logs
kubectl logs -n avesha -l app.kubernetes.io/name=<service-name>

# Check MCP services specifically
kubectl get pods -n avesha -l app.kubernetes.io/component=mcp

# Check configuration
helm get values obliq-sre-agent -n avesha
```

### Impact of Disabled Services
- **service-graph-engine**: No DataDog service topology visualization
- **slack-ingester**: No Slack notifications or message ingestion
- **kubernetes-events-ingester**: No Kubernetes event monitoring
- **aws-ec2-cloudwatch-alarms**: No CloudWatch alarm monitoring
- **MCP services**: Limited external system integration

---

## 🔒 Security Considerations

- Store credentials securely using environment variables or secret management systems
- Use IAM roles instead of access keys when possible (for AWS services)
- Regularly rotate credentials and monitor access
- Follow principle of least privilege for service permissions
- Review enabled services periodically to minimize attack surface
