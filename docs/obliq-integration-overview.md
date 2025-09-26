# Obliq SRE Agent - Integration Overview

## OpenAI Integration
**Purpose**: Anomaly Detection, Auto-Remediation, and ChatBot Functionality

The Obliq SRE Agent leverages OpenAI's advanced AI capabilities to provide intelligent monitoring and automated response capabilities:

**Key Features**:
- **Anomaly Detection**: Utilizes OpenAI's machine learning models to identify unusual patterns in system metrics, logs, and events across your infrastructure
- **Auto-Remediation**: Automatically executes corrective actions when anomalies are detected, reducing mean time to resolution (MTTR)
- **ChatBot Functionality**: Provides intelligent conversational interface for SRE teams to query system status, get recommendations, and interact with the monitoring platform

**Enabled Functionality**:
- **Intelligent Pattern Recognition**: Advanced machine learning models analyze complex system patterns across multiple data sources
- **Real-time Anomaly Detection**: Continuously monitors system metrics, logs, and events to identify unusual patterns and potential issues
- **Automated Incident Response**: Executes predefined corrective actions when anomalies are detected, reducing manual intervention
- **Natural Language Interface**: Conversational chatbot for SRE teams to query system status and get intelligent recommendations
- **Predictive Analytics**: Proactive identification of potential issues before they impact system performance
- **Contextual Insights**: Provides intelligent analysis and recommendations based on historical data and current system state

## Kubernetes Integration
**Purpose**: Metrics Collection and Cluster Management via kubeconfig

The Obliq SRE Agent integrates with Kubernetes clusters through kubeconfig authentication to provide comprehensive monitoring and management capabilities:

**Key Features**:
- **Metrics Collection**: Automatically gathers performance metrics, resource utilization, and health indicators from Kubernetes clusters
- **MCP Server Functionality**: Operates as a Model Context Protocol (MCP) server to provide structured access to Kubernetes cluster data
- **RBAC-Based Security**: Implements secure access through Kubernetes Role-Based Access Control (RBAC)

**Enabled Functionality**:
- **Core Resource Monitoring**: Monitor pods, services, endpoints, nodes, namespaces, and events across the cluster
- **Pod Log Access**: Access pod logs for troubleshooting and analysis
- **Workload Monitoring**: Track deployments, daemonsets, statefulsets, and replicasets status and health
- **Batch Job Monitoring**: Monitor jobs and cronjobs execution and status
- **Resource Metrics**: Collect CPU and memory metrics for pods and nodes
- **Network Monitoring**: Track ingresses and network policies for security and connectivity analysis

## AWS Integration
**Purpose**: Cloud Infrastructure Monitoring and Optimization

The Obliq SRE Agent connects to Amazon Web Services to provide comprehensive cloud infrastructure monitoring and optimization:

**Key Features**:
- **Metrics, Logs, and Events Collection**: Automatically collects telemetry data from AWS services to enable autonomous monitoring and optimization
- **Workflow Automation**: Monitors, optimizes, and automates AWS workflows based on collected data
- **IAM-Based Security**: Implements secure access through AWS IAM roles and policies

**Enabled Functionality**:
- **EC2 Monitoring**: Monitor instance status, regions, account attributes, security groups, and VPCs
- **ECS Container Management**: Track clusters, services, tasks, and task definitions for containerized workloads
- **Load Balancer Monitoring**: Monitor load balancers, target groups, target health, listeners, rules, and tags
- **Auto Scaling Monitoring**: Track auto scaling groups and their configurations
- **CloudWatch Metrics**: Collect and analyze metric statistics and lists for comprehensive monitoring
- **Cross-Account Access**: Assume roles and verify caller identity for secure multi-account operations

