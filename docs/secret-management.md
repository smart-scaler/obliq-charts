# Secret Management Guide

This guide provides instructions for creating and managing Kubernetes secrets for the Obliq SRE Agent deployment. The chart allows you to either let it manage secrets automatically or provide your own pre-existing Kubernetes secrets.

## 🔧 Secret Types

| Secret Type | Purpose | Chart Creates | Pre-existing Support |
|-------------|---------|---------------|---------------------|
| **Global Secret** | All environment variables | ✅ | ✅ |
| **Image Pull Secret** | Container registry access | ✅ | ✅ |
| **Kubeconfig Secret** | Kubernetes cluster access | ✅ | ✅ |

## 📋 Required Environment Variables

### Core Variables (Required)
- `OPENAI_API_KEY` - OpenAI API key for AI services (required)
- `KUBECONFIG` - Kubernetes configuration for cluster access (required)

### AWS Integration (Optional)
- `AWS_ACCESS_KEY_ID` - AWS access key for cloud services
- `AWS_SECRET_ACCESS_KEY` - AWS secret access key
- `AWS_REGION` - AWS region (default: us-east-1)
- `AWS_ROLE_ARN_AWS_MCP` - IAM role for AWS MCP service
- `AWS_ROLE_ARN_EC2_CLOUDWATCH_ALARMS` - IAM role for CloudWatch alarms

### External Integrations (Optional)
- `SLACK_BOT_TOKEN` - Slack bot token for notifications (xoxb-...)
- `SLACK_WEBHOOK_URL` - Slack webhook URL for alerts
- `DD_API_KEY` - DataDog API key for service graph engine
- `DD_APP_KEY` - DataDog application key
- `JIRA_EMAIL` - Jira user email for incident management
- `JIRA_API_TOKEN` - Jira API token
- `JIRA_BASE_URL` - Jira instance URL (default: https://avesha.atlassian.net)
- `PROMETHEUS_URL` - Prometheus server URL (default: http://prometheus:9090)
- `PROMETHEUS_USER` - Prometheus username (if auth enabled)
- `PROMETHEUS_PASSWORD` - Prometheus password (if auth enabled)
- `LOKI_URL` - Loki server URL (default: http://loki:3100)
- `LOKI_USERNAME` - Loki username (if auth enabled)
- `LOKI_PASSWORD` - Loki password (if auth enabled)
- `LOKI_TOKEN` - Loki authentication token

## 🚀 Method 1: Using Pre-existing Global Secret (Recommended)

Create your own Kubernetes secret with all required environment variables:

### Step 1: Create the Secret

#### Minimal Deployment (Core Services Only)
```bash
kubectl create secret generic obliq-secrets \
  --namespace=avesha \
  --from-literal=OPENAI_API_KEY="sk-your-openai-key"
```

#### AWS Integration
```bash
kubectl create secret generic obliq-secrets \
  --namespace=avesha \
  --from-literal=OPENAI_API_KEY="sk-your-openai-key" \
  --from-literal=AWS_ACCESS_KEY_ID="your-aws-access-key" \
  --from-literal=AWS_SECRET_ACCESS_KEY="your-aws-secret-key" \
  --from-literal=AWS_REGION="us-east-1" \
  --from-literal=AWS_ROLE_ARN_AWS_MCP="arn:aws:iam::account:role/aws-mcp-role"
```

#### Full Integration (All Services)
```bash
kubectl create secret generic obliq-secrets \
  --namespace=avesha \
  --from-literal=OPENAI_API_KEY="sk-your-openai-key" \
  --from-literal=AWS_ACCESS_KEY_ID="your-aws-access-key" \
  --from-literal=AWS_SECRET_ACCESS_KEY="your-aws-secret-key" \
  --from-literal=AWS_REGION="us-east-1" \
  --from-literal=SLACK_BOT_TOKEN="xoxb-your-slack-token" \
  --from-literal=SLACK_WEBHOOK_URL="https://hooks.slack.com/services/your-webhook" \
  --from-literal=DD_API_KEY="your-datadog-api-key" \
  --from-literal=DD_APP_KEY="your-datadog-app-key" \
  --from-literal=JIRA_EMAIL="user@company.com" \
  --from-literal=JIRA_API_TOKEN="your-jira-api-token" \
  --from-literal=JIRA_BASE_URL="https://company.atlassian.net" \
  --from-literal=PROMETHEUS_URL="http://prometheus:9090" \
  --from-literal=PROMETHEUS_USER="admin" \
  --from-literal=PROMETHEUS_PASSWORD="your-prometheus-password" \
  --from-literal=LOKI_URL="http://loki:3100" \
  --from-literal=LOKI_USERNAME="admin" \
  --from-literal=LOKI_PASSWORD="your-loki-password"
```

### Step 2: Configure Chart to Use Existing Secret

Create a values file or use command line flags:

```yaml
# custom-values.yaml
global:
  globalSecret:
    create:
      enabled: false  # Don't create a new secret
    existing:
      enabled: true   # Use existing secret
      name: "obliq-secrets"  # Your secret name
```

### Step 3: Install with Pre-existing Secret

First, add the Helm repository:
```bash
helm repo add obliq-charts https://repo.obliq.avesha.io/
helm repo update
```

Then install with the pre-existing secret:
```bash
helm install obliq-sre-agent obliq-charts/obliq-sre-agent \
  --namespace avesha \
  --create-namespace \
  --set-file global.kubeconfig.content=./kubeconfig \
  --set global.globalSecret.existing.enabled=true \
  --set global.globalSecret.existing.name=obliq-secrets \
  --set global.globalSecret.create.enabled=false
```

## 🔐 Method 2: Using Pre-existing Image Pull Secret

If you already have a Docker registry secret:

### Step 1: Create Registry Secret (if needed)
```bash
kubectl create secret docker-registry registry-secret \
  --docker-server=avesha.azurecr.io \
  --docker-username=your-username \
  --docker-password=your-password \
  --docker-email=your-email \
  --namespace=avesha
```

### Step 2: Configure Chart
```yaml
# custom-values.yaml
global:
  imagePullSecrets:
    - name: registry-secret
  imagePullSecretConfig:
    create:
      enabled: false  # Don't create new registry secret
    existing:
      enabled: true   # Use existing registry secret
      name: "registry-secret"
```

## 📊 Service-Specific Environment Variables

Each service requires specific environment variables from the global secret:

### Core Services (Always Enabled)
- **backend**: `OPENAI_API_KEY`, `PORT`, `INFRA_AGENT_HOST`, `INFRA_AGENT_PORT`
- **orchestrator**: `OPENAI_API_KEY`, `MCP_SERVERS`, `PORT`
- **rca-agent**: `OPENAI_API_KEY`, `MCP_SERVERS`, `PORT`
- **anomaly-detection**: `OPENAI_API_KEY`, `MCP_SERVERS`, `PORT`
- **auto-remediation**: `OPENAI_API_KEY`, `MCP_SERVERS`, `PORT`
- **incident-manager**: `OPENAI_API_KEY`, `MCP_SERVERS`, `PORT`

### Optional Services (Enable as needed)
- **aws-mcp**: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `AWS_ROLE_ARN_AWS_MCP`
- **cloudwatch-mcp**: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`
- **prometheus-mcp**: `PROMETHEUS_URL`, `PROMETHEUS_USER`, `PROMETHEUS_PASSWORD`
- **loki-mcp**: `LOKI_URL`, `LOKI_USERNAME`, `LOKI_PASSWORD`, `LOKI_TOKEN`
- **slack-ingester**: `SLACK_BOT_TOKEN`
- **service-graph-engine**: `DD_API_KEY`, `DD_APP_KEY`, `DD_SITE`

## 🎯 Configuration Examples

### Enable AWS Services
```yaml
# Enable AWS-related services
aws-mcp:
  enabled: true
cloudwatch-mcp:
  enabled: true
aws-ec2-cloudwatch-alarms:
  enabled: true
```

### Enable Observability Services
```yaml
# Enable observability integrations
prometheus-mcp:
  enabled: true
loki-mcp:
  enabled: true
```

### Enable External Integrations
```yaml
# Enable external service integrations
slack-ingester:
  enabled: true
service-graph-engine:
  enabled: true
```

## 🔍 Verification and Troubleshooting

### Check Secret Creation
```bash
# Verify secret exists
kubectl get secrets -n avesha

# Check secret content (keys only)
kubectl describe secret obliq-secrets -n avesha

# View secret data (base64 encoded)
kubectl get secret obliq-secrets -n avesha -o yaml
```

### Verify Environment Variables in Pods
```bash
# Check backend pod environment
kubectl exec -n avesha deployment/backend -- env | grep -E "(OPENAI|AWS|SLACK)" | sort

# Check specific service
kubectl exec -n avesha deployment/aws-mcp -- env | grep AWS

# Check all pods
kubectl get pods -n avesha -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
```

### Common Issues and Solutions

#### 1. Missing Required Variables
**Problem**: Pod fails to start due to missing environment variables
```bash
# Check pod events
kubectl describe pod -n avesha -l app.kubernetes.io/name=backend

# Check logs
kubectl logs -n avesha -l app.kubernetes.io/name=backend
```

**Solution**: Add missing variables to your secret
```bash
kubectl patch secret obliq-secrets -n avesha \
  --type='json' \
  -p='[{"op": "add", "path": "/data/MISSING_VAR", "value": "'$(echo -n "your-value" | base64)'"}]'
```

#### 2. Wrong Secret Name/Namespace
**Problem**: Chart can't find the specified secret
```bash
# Check if secret exists in correct namespace
kubectl get secret obliq-secrets -n avesha
```

**Solution**: Ensure secret name matches configuration and is in correct namespace

#### 3. Invalid Secret Values
**Problem**: Services fail to authenticate with external APIs
```bash
# Test OpenAI API
kubectl exec -n avesha deployment/backend -- curl -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models

# Test AWS credentials
kubectl exec -n avesha deployment/aws-mcp -- aws sts get-caller-identity
```

**Solution**: Verify credentials are correct and have proper permissions

#### 4. Pods Not Picking Up Secret Changes
**Problem**: Updated secret values not reflected in running pods
```bash
# Restart deployments to pick up new values
kubectl rollout restart deployment -n avesha
```

## 📝 Secret Management Best Practices

1. **Use Descriptive Names**: Use clear, descriptive names for your secrets
2. **Organize by Environment**: Create separate secrets for dev/staging/prod
3. **Regular Rotation**: Implement a process for regular secret rotation
4. **Least Privilege**: Only include the secrets each service actually needs
5. **Backup Secrets**: Ensure you have secure backups of critical secrets
6. **Monitor Access**: Use RBAC to control who can access secrets

## 🔗 Related Documentation

- [Main README](../README.md) - Quick start and overview
- [Parameters Guide](parameters.md) - Complete deployment examples
- [Prerequisites](prerequisites.md) - System requirements and setup
- [Parameters Reference](parameters.md) - All configuration options