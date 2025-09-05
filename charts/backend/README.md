# Backend

Main API server and orchestration backend

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
backend:
  enabled: true  # Set to false to disable this service
```

```bash
helm install obliq-sre-agent ./obliq-sre-agent \
  --namespace avesha \
  --create-namespace \
  --values custom-values.yaml
```

### Service-Specific Configuration

Configure this service through the umbrella chart's values:

```yaml
# custom-values.yaml
backend:
  enabled: true
  replicaCount: 2
  image:
    tag: "v1.2.0"
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi
  # Additional service-specific configurations
```

## Environment Variables

This service inherits environment variables from the global configuration:

```yaml
# Environment variables are configured globally
global:
  env:
    common:
      LOG_LEVEL: "INFO"
      NODE_ENV: "production"
    database:
      NEO4J_PASSWORD: "your-password"
      MONGODB_URI: "mongodb://..."
    # ... other global env sections
```

## Monitoring and Troubleshooting

### Check Service Status

```bash
# Check if the service is running
kubectl get pods -n avesha -l app.kubernetes.io/name=backend

# View service logs
kubectl logs -n avesha -l app.kubernetes.io/name=backend

# Describe the deployment
kubectl describe deployment -n avesha backend
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
# This will remove all services including backend
helm uninstall obliq-sre-agent --namespace avesha
```

## For Developers

### Individual Chart Testing (Development Only)

⚠️ **For development/testing purposes only**

```bash
# Install dependencies first
helm dependency build ../

# Install only this chart (may not work without global context)
helm install backend-test ./backend \
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