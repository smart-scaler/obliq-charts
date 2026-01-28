# Kubernetes Permissions Guide

This document provides step-by-step instructions for setting up Kubernetes permissions (RBAC) for the Obliq SRE Agent platform.

## 📋 Table of Contents

### **1. Core Resources**
- [**Complete RBAC Configuration**](#complete-rbac-configuration) - Ready-to-copy RBAC manifests
- [**Permission Breakdown**](#permission-breakdown) - Detailed permission explanations

## Overview

The Obliq SRE Agent platform requires specific Kubernetes permissions to monitor cluster resources and collect metrics.

## Complete RBAC Configuration

**Copy this complete RBAC configuration for immediate use:**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: obliq-sre-agent
rules:
- apiGroups: [""]
  resources:
  - pods
  - pods/log
  - services
  - endpoints
  - nodes
  - namespaces
  - events
  verbs: ["get", "list", "watch"]

- apiGroups: ["apps"]
  resources:
  - deployments
  - daemonsets
  - statefulsets
  - replicasets
  verbs: ["get", "list", "watch"]

- apiGroups: ["batch"]
  resources:
  - jobs
  - cronjobs
  verbs: ["get", "list", "watch"]

- apiGroups: ["metrics.k8s.io"]
  resources:
  - pods
  - nodes
  verbs: ["get", "list"]

- apiGroups: ["networking.k8s.io"]
  resources:
  - ingresses
  - networkpolicies
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: obliq-sre-agent
subjects:
- kind: ServiceAccount
  name: obliq-sre-agent
  namespace: obliq
roleRef:
  kind: ClusterRole
  name: obliq-sre-agent
  apiGroup: rbac.authorization.k8s.io
```

## Permission Breakdown

The RBAC configuration includes permissions for:

### **Core Resources**
- **Pods**: get, list, watch - Access to pod information and status
- **Pods/Log**: get - Access to pod logs for troubleshooting
- **Services**: get, list, watch - Access to service information
- **Endpoints**: get, list, watch - Access to service endpoints
- **Nodes**: get, list, watch - Access to cluster node information
- **Namespaces**: get, list, watch - Access to namespace information
- **Events**: get, list, watch - Access to Kubernetes events

### **Workload APIs**
- **Deployments**: get, list, watch - Access to deployment status
- **DaemonSets**: get, list, watch - Access to daemon set information
- **StatefulSets**: get, list, watch - Access to stateful set status
- **ReplicaSets**: get, list, watch - Access to replica set information

### **Batch APIs**
- **Jobs**: get, list, watch - Access to job information
- **CronJobs**: get, list, watch - Access to cron job information

### **Metrics API**
- **Pods Metrics**: get, list - Access to pod resource metrics (CPU, memory)
- **Nodes Metrics**: get, list - Access to node resource metrics

### **Networking**
- **Ingresses**: get, list, watch - Access to ingress information
- **Network Policies**: get, list, watch - Access to network policy information
