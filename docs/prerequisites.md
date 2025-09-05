# Prerequisites

System requirements needed before installing the Obliq SRE Agent chart.

## Required

| Requirement | Minimum Version | Purpose |
|-------------|----------------|---------|
| **Kubernetes cluster** | 1.19+ | Platform runtime |
| **Helm** | 3.8+ | Chart deployment |
| **kubectl** | Compatible with cluster | Cluster access |
| **OpenAI API Key** | - | AI services |
| **Container registry access** | - | Image pulling |
| **kubeconfig file** | - | Service cluster access |

### Minimum Cluster Resources
- **CPU**: 4 cores available
- **Memory**: 8GB available
- **Permissions**: Cluster admin for initial setup

## Quick Verification

```bash
# Check cluster access
kubectl cluster-info

# Check Helm
helm version --short

# Check resources (optional)
kubectl describe nodes
```

## Get Required Credentials

1. **OpenAI API Key**: [Get from OpenAI Platform](https://platform.openai.com/api-keys)
2. **Registry Access**: Contact support@aveshasystems.com

## Optional Integration Requirements

The following integrations are **optional** and only required if you enable specific services:

### AWS Integration
**Required for**: `aws-mcp`, `cloudwatch-mcp`, `aws-ec2-cloudwatch-alarms`

| Requirement | Parameters | Reference |
|-------------|------------|-----------|
| **AWS Access Keys** | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` | AWS IAM console |
| **IAM Policies** | Service-specific permissions | [IAM Policies Guide](aws-iam-policies.md) |
| **IAM Roles** | `AWS_ROLE_ARN_AWS_MCP`, `AWS_ROLE_ARN_EC2_CLOUDWATCH_ALARMS` | [IAM Policies Guide](aws-iam-policies.md) |

Setup: Review [aws-iam-policies.md](aws-iam-policies.md) for required policies and roles.

### DataDog Integration
**Required for**: `service-graph-engine`

| Requirement | Parameters | Reference |
|-------------|------------|-----------|
| **DataDog API Key** | `DD_API_KEY` | DataDog Admin → API Keys |
| **DataDog App Key** | `DD_APP_KEY` | DataDog Admin → Application Keys |
| **DataDog Site** (optional) | `DD_SITE` | Default: `us5.datadoghq.com` |

### Slack Integration
**Required for**: `slack-ingester`

| Requirement | Parameters | Reference |
|-------------|------------|-----------|
| **Slack Bot Token** | `SLACK_BOT_TOKEN` | Slack App → OAuth & Permissions |
| **Slack Webhook** (optional) | `SLACK_WEBHOOK_URL` | Slack App → Incoming Webhooks |

### Kubernetes Events
**Required for**: `kubernetes-events-ingester`

| Requirement | Parameters | Reference |
|-------------|------------|-----------|
| **kubeconfig file** | `--set-file global.kubeconfig.content=./kubeconfig` | Cluster access file |
| **Cluster permissions** | Read events, pods, nodes | RBAC configuration |

### Prometheus Integration
**Required for**: `prometheus-mcp`

| Requirement | Parameters | Reference |
|-------------|------------|-----------|
| **Prometheus URL** | `PROMETHEUS_URL` | Prometheus server endpoint |
| **Auth credentials** | `PROMETHEUS_MCP_USERNAME`, `PROMETHEUS_MCP_PASSWORD` | Prometheus auth |

### Loki Integration
**Required for**: `loki-mcp`

| Requirement | Parameters | Reference |
|-------------|------------|-----------|
| **Loki URL** | `LOKI_URL` | Loki server endpoint |
| **Auth credentials** (optional) | `LOKI_USERNAME`, `LOKI_PASSWORD`, `LOKI_TOKEN` | Loki auth |

### JIRA Integration
**Used by**: Multiple services for incident management

| Requirement | Parameters | Reference |
|-------------|------------|-----------|
| **JIRA Base URL** | `JIRA_BASE_URL` | Your JIRA instance URL |
| **JIRA Email** | `JIRA_EMAIL` | User email for API access |
| **JIRA API Token** | `JIRA_API_TOKEN` | JIRA → Profile → Personal Access Tokens |
| **JIRA Project Key** | `JIRA_PROJECT_KEY` | Target project identifier |

---

## Environment Variables with .env File

For easier management of multiple environment variables, you can create a `.env` file instead of exporting each variable individually.

### Create .env File

```bash
# Create .env file with your credentials
cat > .env << 'EOF'
# =============================================================================
# CORE REQUIRED VARIABLES
# =============================================================================

# OpenAI API Key (Required for all AI services)
# Get from: https://platform.openai.com/api-keys
# Used by: anomaly-detection, rca-agent, auto-remediation, incident-manager
export OPENAI_API_KEY="sk-your-openai-api-key"

# =============================================================================
# COMMON CONFIGURATION (Optional)
# =============================================================================

# Environment settings
export NODE_ENV="production"                    # Node.js environment (production/development/staging)
export LOG_LEVEL="INFO"                        # Application log level (DEBUG/INFO/WARN/ERROR)
export LOGURU_LEVEL="INFO"                     # Python logging level (DEBUG/INFO/WARNING/ERROR)
export TZ="UTC"                                # Timezone (UTC/America/New_York/Europe/London)
export ENVIRONMENT="production"                 # Environment name (production/staging/development)
export CLUSTER_NAME="obliq-cluster"            # Kubernetes cluster name
export DEBUG="false"                           # Enable debug mode (true/false)
export AUTOMATIC_EXECUTION_ENABLED="true"      # Enable automatic execution (true/false)

# =============================================================================
# DATABASE CONFIGURATION (Optional - Auto-configured)
# =============================================================================

# Neo4j Graph Database
export NEO4J_USER="neo4j"                      # Neo4j username
export NEO4J_PASSWORD="admin123"               # Neo4j password
export NEO4J_AUTH="neo4j/admin123"             # Neo4j auth string
export NEO4J_DATABASE="neo4j"                  # Neo4j database name

# MongoDB Document Database  
export MONGO_ROOT_USERNAME="admin"             # MongoDB root username
export MONGO_ROOT_PASSWORD="admin123"          # MongoDB root password
export MONGODB_DATABASE="infra_db"             # MongoDB database name
export MONGODB_USERNAME="admin"                # MongoDB app username
export MONGODB_PASSWORD="admin123"             # MongoDB app password

# Neo4j MCP Service
export NEO4J_MCP_USERNAME="admin"              # Neo4j MCP username
export NEO4J_MCP_PASSWORD="admin123"           # Neo4j MCP password

# =============================================================================
# AWS INTEGRATION (Optional)
# =============================================================================

# Core AWS Credentials
# Get from: AWS IAM Console → Users → Security credentials
# Used by: aws-mcp, cloudwatch-mcp, aws-ec2-cloudwatch-alarms
export AWS_ACCESS_KEY_ID="your-aws-access-key"
export AWS_SECRET_ACCESS_KEY="your-aws-secret-key"
export AWS_REGION="us-west-2"                  # AWS region (us-east-1/us-west-2/eu-west-1)

# AWS IAM Roles (for cross-account access)
# Create these roles in your AWS account with appropriate policies
export AWS_ROLE_ARN_AWS_MCP="arn:aws:iam::123456789012:role/your-aws-mcp-role"
export AWS_ROLE_ARN_EC2_CLOUDWATCH_ALARMS="arn:aws:iam::123456789012:role/your-ec2-cloudwatch-role"

# AWS MCP Service Credentials (Optional)
export AWS_MCP_USERNAME="admin"                # AWS MCP service username
export AWS_MCP_PASSWORD="admin123"             # AWS MCP service password

# =============================================================================
# DATADOG INTEGRATION (Optional)
# =============================================================================

# DataDog Service Graph Integration
# Get from: DataDog → Organization Settings → API Keys & Application Keys
# Used by: service-graph-engine for topology mapping
export DD_API_KEY="your-datadog-api-key"
export DD_APP_KEY="your-datadog-app-key"
export DD_SITE="us5.datadoghq.com"             # DataDog site (us1/us3/us5/eu1.datadoghq.com)
export DD_ENVIRONMENTS="production"             # DataDog environments to monitor (comma-separated)

# =============================================================================
# SLACK INTEGRATION (Optional)
# =============================================================================

# Slack Notifications and Ingestion
# Bot Token: Slack App → OAuth & Permissions → Bot User OAuth Token
# Webhook: Slack → Apps → Incoming Webhooks
# Used by: slack-ingester for notifications and message processing
export SLACK_BOT_TOKEN="xoxb-your-slack-bot-token"
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/your-webhook"

# =============================================================================
# OBSERVABILITY INTEGRATION (Optional)
# =============================================================================

# Prometheus Metrics Collection
# Used by: prometheus-mcp for metrics integration
export PROMETHEUS_URL="http://your-prometheus:9090"
export PROMETHEUS_MCP_USERNAME="your-prometheus-user"    # If auth enabled
export PROMETHEUS_MCP_PASSWORD="your-prometheus-password" # If auth enabled

# Loki Log Aggregation  
# Used by: loki-mcp for log collection and analysis
export LOKI_URL="http://your-loki:3100"
export LOKI_USERNAME="your-loki-user"          # If auth enabled
export LOKI_PASSWORD="your-loki-password"      # If auth enabled
export LOKI_TOKEN="your-loki-token"            # Alternative to username/password

# =============================================================================
# JIRA INTEGRATION (Optional)
# =============================================================================

# JIRA Incident Management
# API Token: JIRA → Profile → Personal Access Tokens
# Used by: Multiple services for incident management and ticketing
export JIRA_BASE_URL="https://yourcompany.atlassian.net"
export JIRA_EMAIL="your-email@company.com"
export JIRA_API_TOKEN="your-jira-api-token"
export JIRA_PROJECT_KEY="PROJ"                 # JIRA project key for issues
export JIRA_PAT="your-jira-pat-token"          # Personal Access Token (alternative)

EOF
```

### Use .env File

```bash
# Source the environment variables
source .env

# Add the Helm repository (if not already added)
helm repo add obliq-charts https://repo.obliq.avesha.io/
helm repo update

# Now run any of the installation commands from the main README
helm install obliq-sre-agent obliq-charts/obliq-sre-agent \
  --namespace avesha \
  --create-namespace \
  --set-file global.kubeconfig.content=./kubeconfig \
  --set global.env.openai.OPENAI_API_KEY="${OPENAI_API_KEY}" \
  # ... rest of your installation flags
```

### Security Best Practices

⚠️ **Important Security Notes:**
- Add `.env` to your `.gitignore` to avoid committing credentials to version control
- Set appropriate file permissions: `chmod 600 .env`
- Never share or commit your `.env` file
- Use different `.env` files for different environments (dev, staging, prod)
- Store production credentials in secure secret management systems

---

## Next Steps

After verifying prerequisites:
1. Create registry secret - see [Quick Start](../README.md#1-create-acr-secret)
2. Install chart - see [Installation](../README.md#2-install-the-chart)

For issues: support@aveshasystems.com