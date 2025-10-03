{{/*
Expand the name of the chart.
*/}}
{{- define "obliq-sre-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "obliq-sre-agent.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "obliq-sre-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "obliq-sre-agent.labels" -}}
helm.sh/chart: {{ include "obliq-sre-agent.chart" . }}
{{ include "obliq-sre-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "obliq-sre-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "obliq-sre-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "obliq-sre-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "obliq-sre-agent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the namespace to use
*/}}
{{- define "obliq-sre-agent.namespace" -}}
{{- if .Values.global.namespace }}
{{- .Values.global.namespace }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Get the image registry
*/}}
{{- define "obliq-sre-agent.imageRegistry" -}}
{{- if .Values.global.imageRegistry }}
{{- .Values.global.imageRegistry }}
{{- else }}
{{- "avesha.azurecr.io" }}
{{- end }}
{{- end }}



{{/*
Generate Docker config JSON for registry authentication
*/}}
{{- define "obliq-sre-agent.dockerConfigJson" -}}
{{- $registry := .Values.global.imagePullSecretConfig.create.registry }}
{{- $username := .Values.global.imagePullSecretConfig.create.username }}
{{- $password := .Values.global.imagePullSecretConfig.create.password }}
{{- if and $username $password }}
{{- $auth := printf "%s:%s" $username $password | b64enc }}
{{- printf "{\"auths\":{\"%s\":{\"auth\":\"%s\"}}}" $registry $auth }}
{{- else }}
{{- printf "{\"auths\":{}}" }}
{{- end }}
{{- end }}

{{/*
Generate service URL with dynamic namespace
*/}}
{{- define "obliq-sre-agent.serviceUrl" -}}
{{- $service := .service -}}
{{- $port := .port -}}
{{- $namespace := include "obliq-sre-agent.namespace" . -}}
{{- printf "http://%s.%s.svc.cluster.local:%s" $service $namespace $port -}}
{{- end }}

{{/*
Generate database URL with dynamic namespace
*/}}
{{- define "obliq-sre-agent.databaseUrl" -}}
{{- $service := .service -}}
{{- $port := .port -}}
{{- $protocol := .protocol -}}
{{- $namespace := include "obliq-sre-agent.namespace" . -}}
{{- printf "%s://%s.%s.svc.cluster.local:%s" $protocol $service $namespace $port -}}
{{- end }}

{{/*
Get NEO4J URI with dynamic namespace
*/}}
{{- define "obliq-sre-agent.neo4jUri" -}}
{{- $namespace := include "obliq-sre-agent.namespace" . -}}
{{- printf "bolt://neo4j.%s.svc.cluster.local:7687" $namespace -}}
{{- end }}

{{/*
Get MONGODB URI with dynamic namespace
*/}}
{{- define "obliq-sre-agent.mongodbUri" -}}
{{- $namespace := include "obliq-sre-agent.namespace" . -}}
{{- printf "mongodb://mongodb.%s.svc.cluster.local:27017" $namespace -}}
{{- end }}

{{/*
Get service URLs with dynamic namespace
*/}}
{{- define "obliq-sre-agent.anomalyDetectionUrl" -}}
{{- $namespace := include "obliq-sre-agent.namespace" . -}}
{{- printf "http://anomaly-detection.%s.svc.cluster.local:8061" $namespace -}}
{{- end }}

{{- define "obliq-sre-agent.incidentManagerUrl" -}}
{{- $namespace := include "obliq-sre-agent.namespace" . -}}
{{- printf "http://incident-manager.%s.svc.cluster.local:8064" $namespace -}}
{{- end }}

{{- define "obliq-sre-agent.rcaAgentUrl" -}}
{{- $namespace := include "obliq-sre-agent.namespace" . -}}
{{- printf "http://rca-agent.%s.svc.cluster.local:8062" $namespace -}}
{{- end }}

{{- define "obliq-sre-agent.autoRemediationUrl" -}}
{{- $namespace := include "obliq-sre-agent.namespace" . -}}
{{- printf "http://auto-remediation.%s.svc.cluster.local:8063" $namespace -}}
{{- end }}

{{- define "obliq-sre-agent.activeInventoryUrl" -}}
{{- $namespace := include "obliq-sre-agent.namespace" . -}}
{{- printf "http://active-inventory.%s.svc.cluster.local:8065" $namespace -}}
{{- end }}

{{- define "obliq-sre-agent.awsMcpUrl" -}}
{{- $namespace := include "obliq-sre-agent.namespace" . -}}
{{- printf "http://aws-mcp.%s.svc.cluster.local:8080" $namespace -}}
{{- end }}

{{- define "obliq-sre-agent.k8sMcpUrl" -}}
{{- $namespace := include "obliq-sre-agent.namespace" . -}}
{{- printf "http://k8s-mcp.%s.svc.cluster.local:8080" $namespace -}}
{{- end }}

{{/*
Image Pull Secret Name Helper
Determines the correct image pull secret name based on configuration
*/}}
{{- define "obliq-sre-agent.imagePullSecretName" -}}
{{- if .Values.global.imagePullSecretConfig.existing.enabled -}}
{{- .Values.global.imagePullSecretConfig.existing.name -}}
{{- else if .Values.global.imagePullSecretConfig.create.enabled -}}
{{- .Values.global.imagePullSecretConfig.create.name -}}
{{- else -}}
{{- range .Values.global.imagePullSecrets -}}
{{- .name -}}
{{- break -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Image Pull Secrets Array Helper
Generates the image pull secrets array based on configuration
*/}}
{{- define "obliq-sre-agent.imagePullSecrets" -}}
{{- $secretName := include "obliq-sre-agent.imagePullSecretName" . -}}
{{- if $secretName }}
- name: {{ $secretName }}
{{- end }}
{{- end }}

{{/*
Global Secret Name Helper
Determines the correct global secret name based on configuration
*/}}
{{- define "obliq-sre-agent.globalSecretName" -}}
{{- if .Values.global.globalSecret.existing.enabled -}}
{{- .Values.global.globalSecret.existing.name -}}
{{- else -}}
{{- .Values.global.globalSecret.create.name -}}
{{- end -}}
{{- end }}

{{/*
Global Secret Environment Variables Template
This template provides all environment variables from the global secret
*/}}
{{- define "obliq-sre-agent.globalSecretEnv" -}}
# Service URLs from global Secret
- name: NEO4J_URI
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: NEO4J_URI
- name: MONGODB_URI
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: MONGODB_URI
- name: ANOMALY_DETECTOR_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: ANOMALY_DETECTOR_URL
- name: INCIDENT_MANAGER_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: INCIDENT_MANAGER_URL
- name: RCA_SERVICE_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: RCA_SERVICE_URL
- name: AUTO_REMEDIATION_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: AUTO_REMEDIATION_URL
- name: ACTIVE_INVENTORY_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: ACTIVE_INVENTORY_URL
- name: AWS_MCP_SERVER_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: AWS_MCP_SERVER_URL
- name: K8S_SERVER_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: K8S_SERVER_URL
- name: NAMESPACE
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: NAMESPACE

# Common environment variables from global Secret
- name: NODE_ENV
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: NODE_ENV
- name: LOG_LEVEL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: LOG_LEVEL
- name: LOGURU_LEVEL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: LOGURU_LEVEL
- name: TZ
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: TZ
- name: ENVIRONMENT
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: ENVIRONMENT
- name: CLUSTER_NAME
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: CLUSTER_NAME
- name: AUTOMATIC_EXECUTION_ENABLED
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: AUTOMATIC_EXECUTION_ENABLED
- name: DEBUG
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: DEBUG
# SSL/TLS Configuration for internal service communication
- name: SSL_VERIFY
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: SSL_VERIFY
- name: TLS_VERIFY
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: TLS_VERIFY
- name: DISABLE_SSL_VERIFICATION
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: DISABLE_SSL_VERIFICATION
# PORT is service-specific and not included in global secrets

# Backend Service Configuration from global Secret
- name: DEFAULT_ADMIN_EMAIL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: DEFAULT_ADMIN_EMAIL
- name: DEFAULT_ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: DEFAULT_ADMIN_PASSWORD

# Database configuration from global Secret
- name: NEO4J_USER
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: NEO4J_USER
- name: NEO4J_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: NEO4J_PASSWORD
- name: NEO4J_AUTH
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: NEO4J_AUTH
- name: NEO4J_DATABASE
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: NEO4J_DATABASE
- name: MONGO_ROOT_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: MONGO_ROOT_USERNAME
- name: MONGO_ROOT_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: MONGO_ROOT_PASSWORD
- name: MONGODB_DATABASE
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: MONGODB_DATABASE
- name: MONGODB_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: MONGODB_USERNAME
- name: MONGODB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: MONGODB_PASSWORD


# AWS configuration from global Secret
- name: AWS_ROLE_ARN_AWS_MCP
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: AWS_ROLE_ARN_AWS_MCP
- name: AWS_ROLE_ARN_EC2_CLOUDWATCH_ALARMS
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: AWS_ROLE_ARN_EC2_CLOUDWATCH_ALARMS
- name: AWS_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: AWS_ACCESS_KEY_ID
- name: AWS_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: AWS_SECRET_ACCESS_KEY
- name: AWS_REGION
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: AWS_REGION
- name: AWS_MCP_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: AWS_MCP_USERNAME
- name: AWS_MCP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: AWS_MCP_PASSWORD
- name: AWS_WEB_IDENTITY_TOKEN_FILE
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: AWS_WEB_IDENTITY_TOKEN_FILE
- name: METRICS_SAMPLING_INTERVAL_SECONDS
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: METRICS_SAMPLING_INTERVAL_SECONDS


# OpenAI configuration from global Secret
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: OPENAI_API_KEY


# Prometheus configuration from global Secret
- name: PROMETHEUS_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: PROMETHEUS_URL
- name: PROMETHEUS_USER
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: PROMETHEUS_USER
- name: PROMETHEUS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: PROMETHEUS_PASSWORD
- name: PROMETHEUS_MCP_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: PROMETHEUS_MCP_USERNAME
- name: PROMETHEUS_MCP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: PROMETHEUS_MCP_PASSWORD

# Loki configuration from global Secret
- name: LOKI_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: LOKI_URL
- name: LOKI_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: LOKI_TOKEN
- name: LOKI_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: LOKI_USERNAME
- name: LOKI_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: LOKI_PASSWORD

# Jira configuration from global Secret
- name: JIRA_EMAIL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: JIRA_EMAIL
- name: JIRA_API_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: JIRA_API_TOKEN
- name: JIRA_BASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: JIRA_BASE_URL
- name: JIRA_PROJECT_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: JIRA_PROJECT_KEY
- name: JIRA_PAT
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: JIRA_PAT


# Slack configuration from global Secret
- name: SLACK_WEBHOOK_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: SLACK_WEBHOOK_URL
- name: SLACK_BOT_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: SLACK_BOT_TOKEN




# MCP configurations from global Secret
- name: MCP_SERVERS_AWS_EC2
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: MCP_SERVERS_AWS_EC2
- name: MCP_SERVERS_K8S
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: MCP_SERVERS_K8S
- name: MCP_SERVERS_PROMETHEUS
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: MCP_SERVERS_PROMETHEUS
- name: MCP_SERVERS_NEO4J
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: MCP_SERVERS_NEO4J
- name: MCP_SERVERS_LOKI
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: MCP_SERVERS_LOKI
- name: MCP_SERVERS_FULL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: MCP_SERVERS_FULL
- name: MCP_SERVERS
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: MCP_SERVERS
- name: NEO4J_MCP_URL
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: NEO4J_MCP_URL
- name: NEO4J_MCP_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: NEO4J_MCP_USERNAME
- name: NEO4J_MCP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: NEO4J_MCP_PASSWORD


# Certificate configuration removed - configure cert-manager manually if needed


# Service Graph configuration from global Secret
- name: APM_PROVIDER
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: APM_PROVIDER
- name: UPDATE_INTERVAL_SECONDS
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: UPDATE_INTERVAL_SECONDS
- name: DD_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: DD_API_KEY
- name: DD_APP_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: DD_APP_KEY
- name: DD_SITE
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: DD_SITE
- name: DD_ENVIRONMENTS
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: DD_ENVIRONMENTS
- name: SG_APM_PROVIDER
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: SG_APM_PROVIDER
- name: SG_UPDATE_INTERVAL_SECONDS
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: SG_UPDATE_INTERVAL_SECONDS

# Observability configuration from global Secret
- name: OTEL_COLLECTOR_ENDPOINT
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: OTEL_COLLECTOR_ENDPOINT
- name: OTEL_COLLECTOR_HTTP_ENDPOINT
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: OTEL_COLLECTOR_HTTP_ENDPOINT
- name: OTEL_EXPORTER_OTLP_ENDPOINT
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: OTEL_EXPORTER_OTLP_ENDPOINT
- name: OTEL_EXPORTER_OTLP_INSECURE
  valueFrom:
    secretKeyRef:
      name: {{ include "obliq-sre-agent.globalSecretName" . }}
      key: OTEL_EXPORTER_OTLP_INSECURE

# Certificate configuration removed - configure cert-manager manually if needed

{{- end }}





{{/*
Service-specific Environment Variables Template
This template provides service-specific environment variables from individual service configuration
*/}}
{{- define "obliq-sre-agent.serviceSpecificEnv" -}}
{{- $serviceName := .serviceName -}}
{{- $serviceConfig := index .root.Values $serviceName -}}
{{- if and $serviceConfig $serviceConfig.env $serviceConfig.env.app -}}
{{- range $key, $value := $serviceConfig.env.app }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}
