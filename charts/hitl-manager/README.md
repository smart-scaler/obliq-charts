# HITL Manager

Human-in-the-Loop (HITL) Manager service for managing human intervention workflows and evidence collection in the Obliq SRE Agent platform.

## Introduction

This chart deploys the HITL Manager service on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.8+
- Neo4j database (for workflow management)
- MongoDB database (for evidence storage)

## Installing the Chart

This chart is part of the Obliq SRE Agent umbrella chart. To install:

```bash
helm install obliq-sre-agent ./obliq-sre-agent \
  --set hitl-manager.enabled=true
```

## Uninstalling the Chart

To uninstall/delete the deployment:

```bash
helm uninstall obliq-sre-agent
```

## Configuration

The following table lists the configurable parameters of the HITL Manager chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | HITL Manager image repository | `agents/release/hitl-manager` |
| `image.tag` | HITL Manager image tag | `1.2.0` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8065` |
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `1Gi` |
| `resources.requests.cpu` | CPU request | `500m` |
| `resources.requests.memory` | Memory request | `512Mi` |

## Environment Variables

The chart automatically sets the following environment variables:

- `AGENT_TYPE=hitl_manager` - Service type identifier
- `PORT=8065` - Service port
- `EVIDENCE_STORAGE_TYPE=mongodb` - Evidence storage backend
- `EVIDENCE_MONGO_HOST=mongodb` - MongoDB host
- `EVIDENCE_MONGO_PORT=27017` - MongoDB port
- `EVIDENCE_MONGO_DB=infra_db` - MongoDB database name
- `EVIDENCE_MONGO_COLLECTION=evidence_files` - Evidence collection name
- `EVIDENCE_GRIDFS_THRESHOLD=262144` - GridFS threshold (256KB)
- `EVIDENCE_MAX_FILE_SIZE=104857600` - Maximum file size (100MB)

### Global Environment Variables (from globalSecretEnv)

- `NEO4J_URI` - Neo4j database connection URI
- `NEO4J_USER` - Neo4j username
- `NEO4J_PASSWORD` - Neo4j password
- `EVIDENCE_MONGO_USERNAME` - MongoDB username
- `EVIDENCE_MONGO_PASSWORD` - MongoDB password
- `LOG_LEVEL` - Application log level
- `OTEL_SERVICE_NAME` - OpenTelemetry service name
- `OTEL_EXPORTER_JAEGER_ENDPOINT` - Jaeger tracing endpoint

## Accessing the Service

Once deployed, the HITL Manager service can be accessed via:

- **Internal**: `http://hitl-manager:8065` (within the cluster)
- **Port Forward**: `kubectl port-forward service/hitl-manager 8065:8065`

## Features

### Human-in-the-Loop Workflows
- Manages human intervention requests
- Tracks workflow states and approvals
- Handles escalation procedures

### Evidence Collection
- Stores evidence files in MongoDB
- Supports GridFS for large files
- Configurable file size limits
- Metadata management

### Integration
- Neo4j integration for workflow management
- MongoDB integration for evidence storage
- OpenTelemetry tracing support
- Prometheus metrics endpoint

## Dependencies

- **Neo4j**: Required for workflow and state management
- **MongoDB**: Required for evidence file storage
- **Jaeger**: Optional for distributed tracing

## Security Considerations

- Runs as non-root user
- Network policies can be enabled for additional security
- Evidence files are stored securely in MongoDB
- All database connections use authentication

## Troubleshooting

### Common Issues

1. **Database Connection Errors**: Verify Neo4j and MongoDB are running and accessible
2. **Evidence Storage Issues**: Check MongoDB credentials and permissions
3. **Service Not Starting**: Verify all required environment variables are set

### Debug Commands

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=hitl-manager

# View logs
kubectl logs -l app.kubernetes.io/name=hitl-manager

# Test connectivity
kubectl exec -it deployment/hitl-manager -- curl http://localhost:8065/health

# Check environment variables
kubectl exec -it deployment/hitl-manager -- env | grep -E "(NEO4J|MONGO|EVIDENCE)"
```
