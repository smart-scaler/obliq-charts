# Incident Ingester

ServiceNow incident ingester service for integrating with ServiceNow and ingesting incident data into the Obliq SRE Agent platform.

## Introduction

This chart deploys the Incident Ingester service on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.8+
- ServiceNow instance with API access
- Neo4j database (for incident storage)
- OpenAI API key (for LLM processing)

## Installing the Chart

This chart is part of the Obliq SRE Agent umbrella chart. To install:

```bash
helm install obliq-sre-agent ./obliq-sre-agent \
  --set incident-ingester.enabled=true \
  --set global.env.servicenow.SERVICE_NOW_INSTANCE="https://yourcompany.service-now.com" \
  --set global.env.servicenow.SERVICE_NOW_USERNAME="your-username" \
  --set global.env.servicenow.SERVICE_NOW_PASSWORD="your-password"
```

## Uninstalling the Chart

To uninstall/delete the deployment:

```bash
helm uninstall obliq-sre-agent
```

## Configuration

The following table lists the configurable parameters of the Incident Ingester chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Incident Ingester image repository | `agents/release/incident-ingester` |
| `image.tag` | Incident Ingester image tag | `1.2.0` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8065` |
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `1Gi` |
| `resources.requests.cpu` | CPU request | `500m` |
| `resources.requests.memory` | Memory request | `512Mi` |

## Environment Variables

The chart automatically sets the following environment variables:

- `AGENT_TYPE=incident_ingester` - Service type identifier
- `PORT=8065` - Service port
- `SERVICE_NOW_CALLER_USERNAME=admin` - ServiceNow caller username
- `INCIDENTS_START_TIME=2025-09-26T06:00:00.0000Z` - Start time for incident ingestion
- `OPENAI_MODEL=gpt-4o-mini` - OpenAI model for LLM processing
- `LLM_TEMPERATURE=0.2` - LLM temperature setting

### Global Environment Variables (from globalSecretEnv)

- `OTEL_COLLECTOR_ENDPOINT` - OpenTelemetry collector endpoint
- `NEO4J_URI` - Neo4j database connection URI
- `NEO4J_USER` - Neo4j username
- `NEO4J_PASSWORD` - Neo4j password
- `ORCHESTRATOR_URL` - Orchestrator service URL
- `SERVICE_NOW_INSTANCE` - ServiceNow instance URL
- `SERVICE_NOW_USERNAME` - ServiceNow username
- `SERVICE_NOW_PASSWORD` - ServiceNow password
- `INCIDENT_MANAGER_URL` - Incident Manager service URL
- `OPENAI_API_KEY` - OpenAI API key for LLM processing

## ServiceNow Integration

### Prerequisites

1. **ServiceNow Instance**: Access to a ServiceNow instance
2. **API Credentials**: Username and password for ServiceNow API access
3. **Permissions**: Appropriate permissions to read incident data

### Configuration

```bash
# Enable incident-ingester with ServiceNow credentials
helm install obliq-sre-agent ./obliq-sre-agent \
  --set incident-ingester.enabled=true \
  --set global.env.servicenow.SERVICE_NOW_INSTANCE="https://yourcompany.service-now.com" \
  --set global.env.servicenow.SERVICE_NOW_USERNAME="your-username" \
  --set global.env.servicenow.SERVICE_NOW_PASSWORD="your-password" \
  --set global.env.openai.OPENAI_API_KEY="sk-your-openai-key"
```

## Accessing the Service

Once deployed, the Incident Ingester service can be accessed via:

- **Internal**: `http://incident-ingester:8065` (within the cluster)
- **Port Forward**: `kubectl port-forward service/incident-ingester 8065:8065`

## Features

### ServiceNow Integration
- Connects to ServiceNow instance via REST API
- Ingests incident data from ServiceNow
- Processes incidents using AI/LLM capabilities

### AI Processing
- Uses OpenAI GPT-4o-mini for incident analysis
- Configurable temperature for LLM responses
- Integrates with orchestrator for workflow management

### Data Flow
- Ingests incidents from ServiceNow
- Stores incident data in Neo4j
- Communicates with incident-manager for processing
- Sends traces to Jaeger for observability

## Dependencies

- **ServiceNow**: Required for incident data source
- **Neo4j**: Required for incident storage and relationships
- **OpenAI API**: Required for LLM processing
- **Orchestrator**: Required for workflow coordination
- **Incident Manager**: Required for incident processing
- **Jaeger**: Optional for distributed tracing

## Security Considerations

- ServiceNow credentials are stored as Kubernetes secrets
- Runs as non-root user
- Network policies can be enabled for additional security
- All external API calls use authentication

## Troubleshooting

### Common Issues

1. **ServiceNow Connection Errors**: Verify ServiceNow credentials and instance URL
2. **Neo4j Connection Issues**: Check Neo4j service is running and accessible
3. **OpenAI API Errors**: Verify OpenAI API key is valid and has sufficient credits
4. **Service Not Starting**: Check all required environment variables are set

### Debug Commands

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=incident-ingester

# View logs
kubectl logs -l app.kubernetes.io/name=incident-ingester

# Test connectivity
kubectl exec -it deployment/incident-ingester -- curl http://localhost:8065/health

# Check environment variables
kubectl exec -it deployment/incident-ingester -- env | grep -E "(SERVICE_NOW|NEO4J|OPENAI)"
```
