# Kubernetes Events Ingester

Kubernetes events collection and processing service

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
kubernetes-events-ingester:
  enabled: true  # Set to false to disable this service
```

```bash
helm install obliq-sre-agent ./obliq-sre-agent \
  --namespace avesha \
  --create-namespace \
  --values custom-values.yaml
```

## 🔑 Kubeconfig Configuration

This service requires Kubernetes API access to ingest events. Configure kubeconfig using one of these approaches:

### Option 1: Using Global Secret (Recommended)
```bash
# Kubeconfig content is automatically stored in the global secret
helm install obliq-sre-agent ./obliq-sre-agent \
  --namespace avesha \
  --set-file global.kubeconfig.content=./kubeconfig \
  [other parameters...]
```

### Option 2: Using Pre-created Global Secret (Alternative)
```bash
# Create global secret first
kubectl create secret generic obliq-sre-agent-global-secret \
  --from-literal=KUBECONFIG_CONTENT="$(cat ./kubeconfig | base64 -w 0)" \
  --namespace avesha

# Install with global secret reference
helm install obliq-sre-agent ./obliq-sre-agent \
  --namespace avesha \
  --set kubernetes-events-ingester.kubeconfig.secretRef.enabled=true \
  --set global.env.common.KUBECONFIG_FILE_PATH=/etc/kubeconfig/config \
  [other parameters...]
```

### Option 3: Using Custom Values File
```yaml
# kubeconfig-values.yaml
kubernetes-events-ingester:
  kubeconfig:
    content: |
      # Your kubeconfig content here
      apiVersion: v1
      kind: Config
      # ... rest of kubeconfig
```

```bash
helm install obliq-sre-agent ./obliq-sre-agent \
  --namespace avesha \
  --values kubeconfig-values.yaml \
  [other parameters...]
```

## ⚙️ Configuration Parameters

### Kubeconfig Parameters
| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `kubeconfig.content` | Kubeconfig file content | `""` | Use `--set-file` |
| `kubeconfig.secretRef.enabled` | Use secret for kubeconfig | `false` | `true` |
| `kubeconfig.secretRef.name` | Secret name | `"kubeconfig-secret"` | `"my-kubeconfig"` |
| `kubeconfig.secretRef.key` | Secret key | `"config"` | `"kubeconfig"` |

### Resource Parameters
| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `replicaCount` | Number of replicas | `1` | `3` |
| `resources.limits.cpu` | CPU limit | `""` | `"500m"` |
| `resources.limits.memory` | Memory limit | `""` | `"512Mi"` |
| `resources.requests.cpu` | CPU request | `""` | `"250m"` |
| `resources.requests.memory` | Memory request | `""` | `"256Mi"` |

### Volume Parameters
| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `volumes.persistent.enabled` | Enable persistent volume | `false` | `true` |
| `volumes.persistent.size` | Volume size | `"20Gi"` | `"50Gi"` |
| `volumes.config.enabled` | Enable config volume | `true` | `false` |
| `volumes.config.mountPath` | Config mount path | `"/home/appuser/.kube"` | `"/opt/config"` |

### Service-Specific Configuration

Configure this service through the umbrella chart's values:

```yaml
# custom-values.yaml
kubernetes-events-ingester:
  enabled: true
  replicaCount: 2
  image:
    tag: "v1.2.0"
  kubeconfig:
    content: ""  # Use --set-file for this
    secretRef:
      enabled: false
      name: "kubeconfig-secret"
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi
  volumes:
    config:
      enabled: true
      mountPath: "/home/appuser/.kube"
```

## 🌐 Parameter Inheritance & Global Configuration

### How This Service Uses Global Parameters

The `kubernetes-events-ingester` inherits configuration from the umbrella chart's global values through multiple layers:

```
┌─────────────────────────────────────────────────────────┐
│           Global values.yaml (Umbrella Chart)           │
│                                                         │
│  global.env.common.*     ← Shared by ALL services      │
│  global.env.database.*   ← Database connections        │
│  global.env.aws.*        ← AWS credentials             │
│  x-commonConfig          ← Resource templates          │
│                                                         │
└──────────────────┬──────────────────────────────────────┘
                   │ Inherits & Overrides
                   ▼
┌─────────────────────────────────────────────────────────┐
│        kubernetes-events-ingester Configuration         │
│                                                         │
│  ✅ Inherits: LOG_LEVEL, NODE_ENV, KUBECONFIG_FILE_PATH           │
│  ✅ Inherits: Resources, volumes, autoscaling           │
│  ➕ Adds: kubeconfig.content, service-specific config   │
│  🔄 Overrides: Can override any inherited setting       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 📋 Environment Variables

#### Inherited from Global Configuration:
```yaml
# These are automatically available in the pod via global secret
global:
  env:
    common:
      LOG_LEVEL: "INFO"           # ✅ Inherited
      NODE_ENV: "production"      # ✅ Inherited  
      KUBECONFIG_FILE_PATH: "/etc/kubeconfig/config"  # ✅ Inherited - Secret mount path
      TZ: "UTC"                   # ✅ Inherited
      DEBUG: "false"              # ✅ Inherited
    
    database:                     # ✅ Available if needed
      NEO4J_PASSWORD: "admin123"
      MONGODB_URI: "mongodb://mongodb:27017"
    
    aws:                          # ✅ Available for cloud integrations
      AWS_ACCESS_KEY_ID: "..."
      AWS_SECRET_ACCESS_KEY: "..."
```

#### Service-Specific Environment Variables:
```yaml
kubernetes-events-ingester:
  env:
    app:
      # Add service-specific variables here
      BATCH_SIZE: "100"
      POLL_INTERVAL: "30s"
      # Global variables are still available alongside these
```

### 🔧 Parameter Override Examples

#### Example 1: Override Global Log Level
```bash
# Global setting for all services
--set global.env.common.LOG_LEVEL="INFO"

# Override just for this service
--set kubernetes-events-ingester.env.app.LOG_LEVEL="DEBUG"

# Result: kubernetes-events-ingester uses DEBUG, others use INFO
```

#### Example 2: Service-Specific Resource Override
```bash
# Uses common resource template by default
# Override for this specific service:
--set kubernetes-events-ingester.resources.limits.cpu="500m" \
--set kubernetes-events-ingester.resources.limits.memory="1Gi" \
--set kubernetes-events-ingester.replicaCount=2
```

#### Example 3: Multiple Configuration Layers
```yaml
# In umbrella chart values.yaml
global:
  env:
    common:
      LOG_LEVEL: "INFO"        # Layer 1: Global default

kubernetes-events-ingester:
  env:
    app:
      LOG_LEVEL: "WARN"        # Layer 2: Service override
      
# During helm install:
--set kubernetes-events-ingester.env.app.LOG_LEVEL="DEBUG"  # Layer 3: Install override
```

### 🎯 Configuration Precedence

Parameters follow this precedence (highest to lowest):

1. **Helm `--set` flags** → `--set kubernetes-events-ingester.env.app.LOG_LEVEL="DEBUG"`
2. **Custom values files** → `-f my-values.yaml`  
3. **Service config** → `kubernetes-events-ingester.env.app.*`
4. **Common templates** → `x-commonConfig` inheritance
5. **Global env vars** → `global.env.common.*`
6. **Chart defaults** → Default values in this chart

### 🔍 Understanding Dependencies

This service depends on these global configurations:

#### Required Global Parameters:
- `global.env.common.KUBECONFIG_FILE_PATH` → Path to kubeconfig file in container
- `global.env.common.LOG_LEVEL` → Logging configuration
- `global.env.common.NODE_ENV` → Runtime environment

#### Optional Global Parameters:
- `global.env.database.*` → If service needs database access
- `global.env.aws.*` → If service needs AWS integration
- `global.env.slack.*` → If service sends Slack notifications

### Environment Variables Reference

## Monitoring and Troubleshooting

### Check Service Status

```bash
# Check if the service is running
kubectl get pods -n avesha -l app.kubernetes.io/name=kubernetes-events-ingester

# View service logs
kubectl logs -n avesha -l app.kubernetes.io/name=kubernetes-events-ingester

# Describe the deployment
kubectl describe deployment -n avesha kubernetes-events-ingester
```

### Kubeconfig Issues

If you see "Failed to load kubeconfig" or "permission denied" errors:

```bash
# Check if ConfigMap exists and has content
kubectl get configmap kubernetes-events-ingester-config -n avesha -o yaml

# Verify kubeconfig content
kubectl get configmap kubernetes-events-ingester-config -n avesha -o jsonpath='{.data.config}' | head -c 100

# For secret approach, check secret
kubectl get secret kubeconfig-secret -n avesha -o yaml

# Restart pod to pick up new config
kubectl delete pod -n avesha -l app.kubernetes.io/name=kubernetes-events-ingester
```

### Common Solutions

**Problem**: Empty kubeconfig in ConfigMap
```bash
# Update ConfigMap manually
kubectl patch configmap kubernetes-events-ingester-config -n avesha --patch "$(cat <<EOF
data:
  config: |
$(cat ./kubeconfig | sed 's/^/    /')
EOF
)"
```

**Problem**: Wrong mount path
```bash
# Check current mount
kubectl describe pod -n avesha -l app.kubernetes.io/name=kubernetes-events-ingester | grep -A 10 "Mounts:"

# Update KUBECONFIG_FILE_PATH environment variable if using secret approach
--set global.env.common.KUBECONFIG_FILE_PATH=/etc/kubeconfig/config
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
# This will remove all services including kubernetes-events-ingester
helm uninstall obliq-sre-agent --namespace avesha
```

## For Developers

### Individual Chart Testing (Development Only)

⚠️ **For development/testing purposes only**

```bash
# Install dependencies first
helm dependency build ../

# Install only this chart (may not work without global context)
helm install kubernetes-events-ingester-test ./kubernetes-events-ingester \
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