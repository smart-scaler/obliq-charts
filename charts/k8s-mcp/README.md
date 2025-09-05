# K8s MCP

Kubernetes Model Context Protocol integration service

## ⚠️ Important Notice

**This chart is part of the Obliq SRE Agent umbrella chart and should be installed using the global deployment method.**

Individual chart installations are not recommended and may not work correctly due to dependencies and shared configurations.

## Installation

### Recommended: Use the Umbrella Chart

Install the complete Obliq SRE Agent platform which includes this service:

```bash
# Install the complete platform
helm install obliq-sre-agent ./obliq-sre-agent \
  --namespace avesha \
  --create-namespace \
  --wait \
  --timeout 10m
```

### Enable/Disable This Service

To enable or disable this specific service, use the umbrella chart with custom values:

```yaml
# custom-values.yaml
k8s-mcp:
  enabled: true  # Set to false to disable this service
```

```bash
helm install obliq-sre-agent ./obliq-sre-agent \
  --namespace avesha \
  --create-namespace \
  --values custom-values.yaml
```

## 🔑 Kubeconfig Configuration

This service requires Kubernetes API access for cluster operations. Kubeconfig is provided via a global secret:

### Global Kubeconfig Secret (Recommended)
```bash
# Kubeconfig is automatically created via the umbrella chart
helm install obliq-sre-agent ./obliq-sre-agent/ \
  --namespace avesha \
  --set-file global.kubeconfig.content=./kubeconfig
```

### Manual Secret Creation (Alternative)
```bash
# Create secret manually if needed
kubectl create secret generic kubeconfig-secret \
  --from-file=config=./kubeconfig \
  --namespace avesha

# The chart automatically references this secret
```

The kubeconfig secret is mounted at `/etc/kubeconfig` with read-only permissions.

## ⚙️ Configuration Parameters

### Kubeconfig Parameters
| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `volumes.kubeconfig.enabled` | Enable kubeconfig volume | `true` | `false` |
| `volumes.kubeconfig.mountPath` | Mount path | `"/etc/kubeconfig"` | `"/opt/kubeconfig"` |
| `volumes.kubeconfig.secretName` | Secret name | `"kubeconfig-secret"` | `"my-kubeconfig"` |

### Resource Parameters
| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `replicaCount` | Number of replicas | `1` | `3` |
| `resources.limits.cpu` | CPU limit | `""` | `"500m"` |
| `resources.limits.memory` | Memory limit | `""` | `"512Mi"` |
| `resources.requests.cpu` | CPU request | `""` | `"250m"` |
| `resources.requests.memory` | Memory request | `""` | `"256Mi"` |

### RBAC Parameters
| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `rbac.enabled` | Enable RBAC | `true` | `false` |
| `serviceAccount.create` | Create service account | `true` | `false` |
| `rbac.additionalRules` | Additional RBAC rules | `[]` | Custom rules |

### Service-Specific Configuration

Configure this service through the umbrella chart's values:

```yaml
# custom-values.yaml
k8s-mcp:
  enabled: true
  replicaCount: 2
  image:
    tag: "v1.2.0"
  volumes:
    kubeconfig:
      enabled: true
      mountPath: "/etc/kubeconfig"
      secretName: "kubeconfig-secret"
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi
  rbac:
    enabled: true
    additionalRules: []
```

## 🌐 Parameter Inheritance & Global Configuration

### How K8s MCP Uses Global Parameters

The `k8s-mcp` service inherits configuration from the umbrella chart's global values and uses specific global parameters:

```
┌─────────────────────────────────────────────────────────┐
│           Global values.yaml (Umbrella Chart)           │
│                                                         │
│  global.env.common.*     ← LOG_LEVEL, KUBECONFIG, etc   │
│  global.env.aws.*        ← AWS credentials (if needed)  │
│  x-commonConfig          ← Resources, volumes, scaling  │
│                                                         │
└──────────────────┬──────────────────────────────────────┘
                   │ Inherits & Extends
                   ▼
┌─────────────────────────────────────────────────────────┐
│               k8s-mcp Configuration                     │
│                                                         │
│  ✅ Inherits: All global.env.common.* variables         │
│  ✅ Inherits: Resource limits, autoscaling, volumes     │
│  ➕ Adds: RBAC permissions, kubeconfig volumes          │
│  🔄 Overrides: Service-specific ports, endpoints        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 📋 Environment Variables

#### Inherited from Global Configuration:
```yaml
# These are automatically injected via global secret
global:
  env:
    common:
      LOG_LEVEL: "INFO"              # ✅ Inherited
      NODE_ENV: "production"         # ✅ Inherited
      KUBECONFIG: "/etc/kubeconfig/config"  # ✅ Critical for K8s API access
      CLUSTER_NAME: "obliq-cluster"  # ✅ Inherited
      DEBUG: "false"                 # ✅ Inherited
      TZ: "UTC"                      # ✅ Inherited
    
    aws:                            # ✅ Available for cloud integrations
      AWS_ACCESS_KEY_ID: "..."      # If service needs AWS
      AWS_SECRET_ACCESS_KEY: "..."
      AWS_REGION: "us-east-1"
```

#### Service-Specific Configuration:
```yaml
k8s-mcp:
  env:
    app:
      # MCP-specific variables
      MCP_SERVER_PORT: "3000"
      K8S_NAMESPACE_FILTER: ""       # Optional: filter specific namespaces
      API_RATE_LIMIT: "100"          # Kubernetes API rate limiting
      # Global variables are still available
```

### 🔧 Parameter Override Examples

#### Example 1: Override Kubeconfig Path
```bash
# Global default (ConfigMap approach)
--set global.env.common.KUBECONFIG="/etc/kubeconfig/config"

# Override for secret approach
--set global.env.common.KUBECONFIG="/etc/kubeconfig/config" \
--set k8s-mcp.volumes.kubeconfig.enabled=true
```

#### Example 2: Service-Specific RBAC Configuration
```bash
# Enable additional RBAC permissions for k8s-mcp
--set k8s-mcp.rbac.enabled=true \
--set k8s-mcp.rbac.additionalRules[0].apiGroups=["apps"] \
--set k8s-mcp.rbac.additionalRules[0].resources=["deployments"] \
--set k8s-mcp.rbac.additionalRules[0].verbs=["create","update","delete"]
```

#### Example 3: Resource Override for High-Load Clusters
```bash
# Override resources for large Kubernetes clusters
--set k8s-mcp.resources.limits.cpu="1000m" \
--set k8s-mcp.resources.limits.memory="2Gi" \
--set k8s-mcp.replicaCount=2
```

### 🎯 Configuration Dependencies

#### Required Global Parameters:
| Parameter | Purpose | Example |
|-----------|---------|---------|
| `global.env.common.KUBECONFIG` | Kubernetes API access | `"/etc/kubeconfig/config"` |
| `global.env.common.LOG_LEVEL` | Logging configuration | `"INFO"` |
| `global.env.common.CLUSTER_NAME` | Cluster identification | `"production-cluster"` |

#### Optional Global Parameters:
| Parameter | Purpose | When Needed |
|-----------|---------|-------------|
| `global.env.aws.*` | AWS integration | Cross-cloud operations |
| `global.env.database.*` | Database access | If MCP stores state |
| `global.env.slack.*` | Notifications | Alert integration |

### 🔐 RBAC & Security Configuration

The k8s-mcp service requires specific Kubernetes permissions:

#### Default RBAC Permissions:
```yaml
rbac:
  enabled: true
  rules:
    - apiGroups: [""]
      resources: ["pods", "services", "namespaces", "events"]
      verbs: ["get", "list", "watch"]
    - apiGroups: ["apps"]
      resources: ["deployments", "replicasets"]
      verbs: ["get", "list", "watch"]
    # Additional permissions via additionalRules
```

#### Custom RBAC Example:
```yaml
k8s-mcp:
  rbac:
    enabled: true
    additionalRules:
      - apiGroups: ["networking.k8s.io"]
        resources: ["ingresses"]
        verbs: ["get", "list", "watch", "create", "update"]
      - apiGroups: [""]
        resources: ["secrets"]
        verbs: ["get", "list"]
```

### Environment Variables Reference

## Monitoring and Troubleshooting

### Check Service Status

```bash
# Check if the service is running
kubectl get pods -n avesha -l app.kubernetes.io/name=k8s-mcp

# View service logs
kubectl logs -n avesha -l app.kubernetes.io/name=k8s-mcp

# Describe the deployment
kubectl describe deployment -n avesha k8s-mcp
```

### Common Issues

1. **Service not starting**: Check global environment variables and secrets
2. **Image pull errors**: Verify ACR secret configuration in the umbrella chart
3. **Resource issues**: Check resource limits and node capacity

## Upgrading

Upgrade the entire platform (includes this service):

```bash
helm upgrade obliq-sre-agent ./obliq-sre-agent \
  --namespace avesha \
  --values custom-values.yaml
```

## Uninstalling

Remove the entire platform:

```bash
# This will remove all services including k8s-mcp
helm uninstall obliq-sre-agent --namespace avesha
```

## For Developers

### Individual Chart Testing (Development Only)

⚠️ **For development/testing purposes only**

```bash
# Install dependencies first
helm dependency build ../

# Install only this chart (may not work without global context)
helm install k8s-mcp-test ./k8s-mcp \
  --namespace avesha-dev \
  --create-namespace \
  --set global.env.database.NEO4J_PASSWORD=test \
  # ... other required global values
```

## Documentation

- **Main Documentation**: See the [umbrella chart README](../../README.md)
- **Platform Documentation**: [Avesha Documentation](https://docs.avesha.io)
- **Support**: support@avesha.io

## Related Services

This service works in conjunction with other platform services:
- Backend API
- Database services (Neo4j, MongoDB)
- Other microservices in the platform

All services are managed through the umbrella chart for optimal integration.