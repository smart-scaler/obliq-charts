---
layout: default
title: Parameters Reference
parent: Documentation
nav_order: 2
---

# Parameters Reference Guide
{: .fs-8 }

This comprehensive guide covers all Helm chart parameters for the Obliq SRE Agent platform, including parameter architecture, configuration flow, and complete deployment examples.
{: .fs-6 .fw-300 }

<!-- Last updated: 2025-01-06 15:38 IST - Force rebuild -->

## 🎯 Quick Navigation

- [Parameter Architecture](#️-parameter-architecture)
- [Global Environment Variables](#-global-environment-variables)
- [Service Configuration](#️-service-configuration)
- [Complete Deployment Examples](#--complete-deployment-examples)
- [Parameter Validation](#-parameter-validation)

---

## 🏗️ Parameter Architecture

The Obliq SRE Agent uses a sophisticated **umbrella chart architecture** where parameters flow from global configurations to individual service charts through multiple layers:

```
┌─────────────────────────────────────────────────────────┐
│                Global values.yaml                       │
│  ┌─────────────────┬──────────────────┬─────────────────┐  │
│  │   Global Env    │  Common Config   │  Service Config │  │
│  │   Variables     │   Templates      │   Overrides     │  │
│  └─────────────────┴──────────────────┴─────────────────┘  │
└─────────────────────┬───────────────────────────────────┘
                      │
       ┌──────────────┼──────────────┐
       ▼              ▼              ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│  Service A  │ │  Service B  │ │  Service C  │
│   Chart     │ │   Chart     │ │   Chart     │
│  values.yaml│ │  values.yaml│ │  values.yaml│
└─────────────┘ └─────────────┘ └─────────────┘
```

### 🔄 Parameter Flow & Precedence

Parameters follow this precedence order (highest to lowest):

1. **Helm Install/Upgrade `--set` flags** (highest priority)
2. **Custom values files** (`-f custom-values.yaml`)
3. **Service-specific configuration** (in umbrella values.yaml)
4. **Common configuration templates** (`x-commonConfig`)
5. **Global environment variables** (`global.env.*`)
6. **Individual chart defaults** (lowest priority)

### Example Parameter Flow:
```bash
# 1. Global env var sets default
global.env.common.LOG_LEVEL: "INFO"

# 2. Service inherits global + adds specific config
backend:
  env:
    app:
      AGENT_TYPE: "backend"  # Service-specific
      # LOG_LEVEL: "INFO"    # Inherited from global

# 3. Helm install can override
helm install --set backend.env.app.LOG_LEVEL="DEBUG"  # Highest priority
```

---

## 🌐 Global Environment Variables

### Common Environment Variables

| Parameter | Description | Default | Required | Example |
|-----------|-------------|---------|----------|---------|
| `global.env.common.NODE_ENV` | Node.js environment | `"production"` | No | `"development"` |
| `global.env.common.LOG_LEVEL` | Application log level | `"INFO"` | No | `"DEBUG"` |
| `global.env.common.LOGURU_LEVEL` | Python logging level | `"INFO"` | No | `"WARNING"` |
| `global.env.common.TZ` | Timezone | `"UTC"` | No | `"America/New_York"` |
| `global.env.common.ENVIRONMENT` | Environment name | `"production"` | No | `"staging"` |
| `global.env.common.CLUSTER_NAME` | Kubernetes cluster name | `"obliq-cluster"` | No | `"my-cluster"` |
| `global.env.common.KUBECONFIG` | Path to kubeconfig file | `"/etc/kubeconfig/config"` | No | `"/root/.kube/config"` |
| `global.env.common.DEBUG` | Enable debug mode | `"false"` | No | `"true"` |
| `global.env.common.AUTOMATIC_EXECUTION_ENABLED` | Enable automatic execution | `"true"` | No | `"false"` |

### AWS Configuration
| Parameter | Description | Default | Required | Example |
|-----------|-------------|---------|----------|---------|
| `global.env.aws.AWS_ACCESS_KEY_ID` | AWS access key ID | `""` | Yes | `"AKIAIOSFODNN7EXAMPLE"` |
| `global.env.aws.AWS_SECRET_ACCESS_KEY` | AWS secret access key | `""` | Yes | `"wJalrXUtnFEMI/K7MDENG/bPxRfiCY"` |
| `global.env.aws.AWS_REGION` | AWS region | `"us-east-1"` | No | `"us-west-2"` |
| `global.env.aws.AWS_ROLE_ARN_AWS_MCP` | AWS MCP role ARN | `""` | For aws-mcp | `"arn:aws:iam::123456789012:role/aws-mcp"` |
| `global.env.aws.AWS_ROLE_ARN_EC2_CLOUDWATCH_ALARMS` | CloudWatch alarms role ARN | `""` | For aws-ec2-cloudwatch-alarms | `"arn:aws:iam::123456789012:role/cloudwatch"` |
| `global.env.aws.AWS_MCP_USERNAME` | AWS MCP username | `"admin"` | No | `"your-username"` |
| `global.env.aws.AWS_MCP_PASSWORD` | AWS MCP password | `"admin123"` | No | `"your-password"` |

### OpenAI Configuration
| Parameter | Description | Default | Required | Example |
|-----------|-------------|---------|----------|---------|
| `global.env.openai.OPENAI_API_KEY` | OpenAI API key | `""` | Yes | `"sk-1234567890abcdef..."` |

### Database Configuration
| Parameter | Description | Default | Required | Example |
|-----------|-------------|---------|----------|---------|
| `global.env.database.NEO4J_USER` | Neo4j username | `"neo4j"` | No | `"admin"` |
| `global.env.database.NEO4J_PASSWORD` | Neo4j password | `"admin123"` | No | `"changeme"` |
| `global.env.database.NEO4J_AUTH` | Neo4j auth string | `"neo4j/admin123"` | No | `"neo4j/changeme"` |
| `global.env.database.NEO4J_DATABASE` | Neo4j database name | `"neo4j"` | No | `"production"` |
| `global.env.database.MONGO_ROOT_USERNAME` | MongoDB root username | `"admin"` | No | `"root"` |
| `global.env.database.MONGO_ROOT_PASSWORD` | MongoDB root password | `"admin123"` | No | `"changeme"` |
| `global.env.database.MONGODB_DATABASE` | MongoDB database name | `"infra_db"` | No | `"obliq_data"` |
| `global.env.database.MONGODB_USERNAME` | MongoDB app username | `"admin"` | No | `"appuser"` |
| `global.env.database.MONGODB_PASSWORD` | MongoDB app password | `"admin123"` | No | `"changeme"` |

### Integration Services Configuration
| Parameter | Description | Default | Required | Example |
|-----------|-------------|---------|----------|---------|
| `global.env.slack.SLACK_BOT_TOKEN` | Slack bot token | `""` | For slack-ingester | `"xoxb-your-token"` |
| `global.env.slack.SLACK_WEBHOOK_URL` | Slack webhook URL | `""` | No | `"https://hooks.slack.com/..."` |
| `global.env.sg.DD_API_KEY` | DataDog API key | `""` | For service-graph-engine | `"your-dd-api-key"` |
| `global.env.sg.DD_APP_KEY` | DataDog app key | `""` | For service-graph-engine | `"your-dd-app-key"` |
| `global.env.sg.DD_SITE` | DataDog site | `"us5.datadoghq.com"` | No | `"datadoghq.com"` |
| `global.env.sg.DD_ENVIRONMENTS` | DataDog environments | `"production"` | No | `"staging,production"` |

### MCP Services Configuration
| Parameter | Description | Default | Required | Example |
|-----------|-------------|---------|----------|---------|
| `global.env.prometheus.PROMETHEUS_URL` | Prometheus URL | `""` | For prometheus-mcp | `"http://prometheus:9090"` |
| `global.env.prometheus.PROMETHEUS_MCP_USERNAME` | Prometheus MCP username | `""` | For prometheus-mcp | `"admin"` |
| `global.env.prometheus.PROMETHEUS_MCP_PASSWORD` | Prometheus MCP password | `""` | For prometheus-mcp | `"password"` |
| `global.env.loki.LOKI_URL` | Loki URL | `""` | For loki-mcp | `"http://loki:3100"` |
| `global.env.loki.LOKI_USERNAME` | Loki username | `""` | No | `"admin"` |
| `global.env.loki.LOKI_PASSWORD` | Loki password | `""` | No | `"password"` |
| `global.env.loki.LOKI_TOKEN` | Loki token | `""` | No | `"your-token"` |
| `global.env.mcp.NEO4J_MCP_USERNAME` | Neo4j MCP username | `"admin"` | No | `"mcp-user"` |
| `global.env.mcp.NEO4J_MCP_PASSWORD` | Neo4j MCP password | `"admin123"` | No | `"mcp-password"` |

### JIRA Integration Configuration
| Parameter | Description | Default | Required | Example |
|-----------|-------------|---------|----------|---------|
| `global.env.jira.JIRA_BASE_URL` | JIRA base URL | `""` | For JIRA integration | `"https://company.atlassian.net"` |
| `global.env.jira.JIRA_EMAIL` | JIRA email | `""` | For JIRA integration | `"admin@company.com"` |
| `global.env.jira.JIRA_API_TOKEN` | JIRA API token | `""` | For JIRA integration | `"your-api-token"` |
| `global.env.jira.JIRA_PROJECT_KEY` | JIRA project key | `""` | For JIRA integration | `"PROJ"` |

### External Tools (Optional)
| Parameter | Description | Default | Required | Example |
|-----------|-------------|---------|----------|---------|
| **cert-manager** | **OPTIONAL ADD-ON - Install separately** | N/A | No | Install from upstream |
| **ingress-nginx** | **OPTIONAL ADD-ON - Install separately** | N/A | No | Install from upstream |

---

## ⚙️ Service Configuration

### Service Enable/Disable Flags
| Service | Default | Purpose | Dependencies |
|---------|---------|---------|-------------|
| **Core Services (Always Enabled)** |
| `neo4j.enabled` | `true` | Graph database | None |
| `mongodb.enabled` | `true` | Document database | None |
| `opentelemetry-collector.enabled` | `true` | Observability | None |
| `backend.enabled` | `true` | Main API server | OpenAI API key |
| `avesha-unified-ui.enabled` | `true` | Web interface | None |
| `orchestrator.enabled` | `true` | Workflow engine | OpenAI API key |
| `rca-agent.enabled` | `true` | Root cause analysis | OpenAI API key |
| `anomaly-detection.enabled` | `true` | Anomaly detection | OpenAI API key |
| `auto-remediation.enabled` | `true` | Auto-remediation | OpenAI API key |
| `incident-manager.enabled` | `true` | Incident management | OpenAI API key |
| `active-inventory.enabled` | `true` | Infrastructure inventory | None |
| `infra-agent.enabled` | `true` | Infrastructure monitoring | None |
| `k8s-mcp.enabled` | `true` | Kubernetes MCP | kubeconfig |
| **Optional MCP Services (Disabled by Default)** |
| `aws-mcp.enabled` | `false` | AWS MCP integration | AWS credentials |
| `prometheus-mcp.enabled` | `false` | Prometheus MCP | Prometheus credentials |
| `neo4j-mcp.enabled` | `false` | Neo4j MCP | Uses internal Neo4j |
| `loki-mcp.enabled` | `false` | Loki MCP | Loki URL |
| `cloudwatch-mcp.enabled` | `false` | CloudWatch MCP | AWS credentials |
| **Optional Integration Services (Disabled by Default)** |
| `service-graph-engine.enabled` | `false` | DataDog integration | DataDog credentials |
| `slack-ingester.enabled` | `false` | Slack integration | Slack token |
| `kubernetes-events-ingester.enabled` | `false` | K8s events | kubeconfig |
| `aws-ec2-cloudwatch-alarms.enabled` | `false` | CloudWatch alarms | AWS credentials |

### Common Service Parameters

Each service supports these common configuration options:

#### Resource Management
```yaml
<service-name>:
  resources:
    limits:
      cpu: "1000m"
      memory: "1Gi"
    requests:
      cpu: "500m"
      memory: "512Mi"
  
  replicaCount: 1
  
  autoscaling:
    enabled: false
    minReplicas: 1
    maxReplicas: 3
    targetCPUUtilizationPercentage: 80
```

#### Service Configuration
```yaml
<service-name>:
  service:
    type: ClusterIP
    port: 8080
    targetPort: 8080
  
  ingress:
    enabled: false
    annotations: {}
    hosts:
      - host: service.example.com
        paths:
          - path: /
            pathType: Prefix
    tls: []
```

#### Health Checks
```yaml
<service-name>:
  livenessProbe:
    enabled: true
    httpGet:
      path: /health
      port: http
    initialDelaySeconds: 30
    periodSeconds: 10
  
  readinessProbe:
    enabled: true
    httpGet:
      path: /ready
      port: http
    initialDelaySeconds: 5
    periodSeconds: 5
```

#### Security Context
```yaml
<service-name>:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
  
  podSecurityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
```

---

## 📋 Complete Deployment Examples

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
  --set global.env.openai.OPENAI_API_KEY="${OPENAI_API_KEY}"
```

### AWS Integration Deployment
```bash
# Enable AWS services and credentials
helm install obliq-sre-agent obliq-charts/obliq-sre-agent \
  --namespace avesha \
  --create-namespace \
  --set-file global.kubeconfig.content=./kubeconfig \
  --set global.env.openai.OPENAI_API_KEY="${OPENAI_API_KEY}" \
  --set aws-mcp.enabled=true \
  --set cloudwatch-mcp.enabled=true \
  --set aws-ec2-cloudwatch-alarms.enabled=true \
  --set global.env.aws.AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
  --set global.env.aws.AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  --set global.env.aws.AWS_ROLE_ARN_AWS_MCP="${AWS_ROLE_ARN_AWS_MCP}" \
  --set global.env.aws.AWS_ROLE_ARN_EC2_CLOUDWATCH_ALARMS="${AWS_ROLE_ARN_EC2_CLOUDWATCH}"
```

### Full Integration Deployment
```bash
# Essential parameters
helm install obliq-sre-agent obliq-charts/obliq-sre-agent \
  --namespace avesha \
  --create-namespace \
  --set-file global.kubeconfig.content=./kubeconfig \
  --set global.env.openai.OPENAI_API_KEY="${OPENAI_API_KEY}" \
  --set aws-mcp.enabled=true \
  --set prometheus-mcp.enabled=true \
  --set neo4j-mcp.enabled=true \
  --set loki-mcp.enabled=true \
  --set cloudwatch-mcp.enabled=true \
  --set service-graph-engine.enabled=true \
  --set slack-ingester.enabled=true \
  --set kubernetes-events-ingester.enabled=true \
  --set aws-ec2-cloudwatch-alarms.enabled=true \
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

### Environment-Specific Configuration
```bash
# Production values
--set global.env.common.NODE_ENV="production" \
--set global.env.common.LOG_LEVEL="WARN" \
--set global.env.common.ENVIRONMENT="production" \
--set backend.replicaCount=3 \
--set backend.resources.limits.cpu="2000m" \
--set backend.resources.limits.memory="2Gi"

# Staging values
--set global.env.common.NODE_ENV="staging" \
--set global.env.common.LOG_LEVEL="DEBUG" \
--set global.env.common.ENVIRONMENT="staging" \
--set backend.replicaCount=1 \
--set backend.resources.limits.cpu="500m" \
--set backend.resources.limits.memory="512Mi"
```

---

## 🔍 Parameter Validation

### Pre-deployment Validation
```bash
# Dry run to validate configuration
helm install obliq-sre-agent obliq-charts/obliq-sre-agent \
  --namespace avesha \
  --dry-run \
  --set-file global.kubeconfig.content=./kubeconfig \
  --set global.env.openai.OPENAI_API_KEY="test"
  # Add other parameters as needed
```

### Common Parameter Validation Errors
- **Empty required parameters**: OpenAI API key, kubeconfig content
- **Invalid ARN formats**: AWS role ARNs must follow proper format
- **Missing service dependencies**: Enabling services without required credentials
- **Resource conflicts**: Setting conflicting resource limits

### Required Parameters
| Parameter | Required For | Error Message |
|-----------|-------------|---------------|
| `global.env.openai.OPENAI_API_KEY` | Core AI services | "OpenAI API key is required for AI services" |
| `global.kubeconfig.content` | k8s-mcp, kubernetes-events-ingester | "kubeconfig is required for Kubernetes integration" |
| `global.env.aws.AWS_ACCESS_KEY_ID` | AWS services | "AWS credentials required for AWS integrations" |
| `global.env.sg.DD_API_KEY` | service-graph-engine | "DataDog API key required for service graph engine" |
| `global.env.slack.SLACK_BOT_TOKEN` | slack-ingester | "Slack bot token required for Slack integration" |

---

## 💡 Configuration Tips

### Parameter Organization
1. **Start with minimal**: Begin with core services only
2. **Add incrementally**: Enable optional services as needed
3. **Environment-specific**: Use different parameter sets per environment
4. **Security first**: Use real credentials for production
5. **Monitor resources**: Watch resource usage and adjust limits

### Common Patterns
```bash
# Override global settings for specific service
--set global.env.common.LOG_LEVEL="INFO" \
--set backend.env.app.LOG_LEVEL="DEBUG"

# Service-specific resource configuration
--set service-graph-engine.resources.limits.cpu="2000m" \
--set service-graph-engine.resources.limits.memory="4Gi" \
--set service-graph-engine.replicaCount=3

# Conditional service enablement
--set aws-mcp.enabled=true \
--set global.env.aws.AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
--set global.env.aws.AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
```

### Configuration Dependencies
- **Core AI Services**: All require `global.env.openai.OPENAI_API_KEY`
- **AWS Services**: All require `global.env.aws.AWS_ACCESS_KEY_ID` and `global.env.aws.AWS_SECRET_ACCESS_KEY`
- **Kubernetes Services**: `k8s-mcp` and `kubernetes-events-ingester` require kubeconfig
- **Database Services**: Use `global.env.database.*` for credentials
- **External Integrations**: Each requires service-specific credentials

---

## 📞 Support

For parameter-related issues, see the main [README troubleshooting section](../README.md#-troubleshooting).

Common parameter validation errors:
- Empty required parameters
- Invalid ARN formats
- Missing service dependencies
- Resource conflicts

For additional help:
- **Documentation**: [Services Configuration](services.md)
- **Prerequisites**: [System Requirements](prerequisites.md)
- **Support**: support@aveshasystems.com
