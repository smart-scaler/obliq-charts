# GCP MCP

Google Cloud Platform Model Context Protocol (MCP) service for integrating with Google Cloud Platform services.

## Introduction

This chart deploys the GCP MCP service on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.8+
- GCP Service Account JSON credentials

## Installing the Chart

This chart is part of the Obliq SRE Agent umbrella chart. To install:

```bash
helm install obliq-sre-agent ./obliq-sre-agent \
  --set gcp-mcp.enabled=true \
  --set-file global.gcpCredentials.content=./gcp-credentials.json
```

## Uninstalling the Chart

To uninstall/delete the deployment:

```bash
helm uninstall obliq-sre-agent
```

## Configuration

The following table lists the configurable parameters of the GCP MCP chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | GCP MCP image repository | `agents/release/gcp-mcp` |
| `image.tag` | GCP MCP image tag | `1.2.0` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8098` |
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `1Gi` |
| `resources.requests.cpu` | CPU request | `500m` |
| `resources.requests.memory` | Memory request | `512Mi` |
| `volumes.gcpCredentials.enabled` | Enable GCP credentials volume | `true` |
| `volumes.gcpCredentials.secretName` | GCP credentials secret name | `gcp-credentials-secret` |
| `volumes.gcpCredentials.fileName` | GCP credentials file name | `gcp.json` |

## GCP Credentials Setup

### 1. Create GCP Service Account

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to IAM & Admin > Service Accounts
3. Create a new service account
4. Download the JSON key file

### 2. Install with GCP Credentials

```bash
# Install with GCP credentials (global approach)
helm install obliq-sre-agent ./obliq-sre-agent \
  --set gcp-mcp.enabled=true \
  --set-file global.gcpCredentials.content=./gcp-credentials.json
```

## Environment Variables

The chart automatically sets the following environment variables:

- `GOOGLE_APPLICATION_CREDENTIALS=/app/gcp.json` - Path to GCP credentials file
- `PORT=8098` - Service port

## Accessing the Service

Once deployed, the GCP MCP service can be accessed via:

- **Internal**: `http://gcp-mcp:8098` (within the cluster)
- **Port Forward**: `kubectl port-forward service/gcp-mcp 8098:8098`

## Security Considerations

- GCP credentials are stored as Kubernetes secrets
- The service runs as a non-root user
- Credentials are mounted as read-only volumes
- Network policies can be enabled for additional security

## Troubleshooting

### Common Issues

1. **Authentication Errors**: Verify GCP credentials are valid and have proper permissions
2. **Service Not Starting**: Check if the GCP credentials secret exists and is properly mounted
3. **Permission Denied**: Ensure the GCP service account has the required IAM roles

### Debug Commands

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=gcp-mcp

# View logs
kubectl logs -l app.kubernetes.io/name=gcp-mcp

# Check secret
kubectl get secret gcp-credentials-secret -o yaml

# Test connectivity
kubectl exec -it deployment/gcp-mcp -- curl http://localhost:8098/health
```
