# Kubernetes Permissions Guide

This document provides step-by-step instructions for setting up Kubernetes permissions and kubeconfig for the Obliq SRE Agent platform.

## 📋 Table of Contents

### **1. Core Resources**
- [**Complete RBAC Configuration**](#complete-rbac-configuration) - Ready-to-copy RBAC manifests
- [**Permission Breakdown**](#permission-breakdown) - Detailed permission explanations

### **2. Setup Methods**
- [**Generate Kubeconfig**](#generate-kubeconfig) - Complete setup with kubeconfig generation

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
# ───────── Core resources ─────────
- apiGroups: [""]
  resources:
  - pods
  - pods/log        # for log retrieval
  - services
  - endpoints
  - nodes
  - namespaces
  - events
  verbs: ["get", "list", "watch"]

# ───────── Workload APIs (apps) ─────────
- apiGroups: ["apps"]
  resources:
  - deployments
  - daemonsets
  - statefulsets
  - replicasets
  verbs: ["get", "list", "watch"]

# ───────── Batch APIs (CronJob / Job) ─────────
- apiGroups: ["batch"]
  resources:
  - jobs
  - cronjobs
  verbs: ["get", "list", "watch"]

# ───────── Metrics API ─────────
- apiGroups: ["metrics.k8s.io"]
  resources:
  - pods
  - nodes
  verbs: ["get", "list"]

# ───────── Optional extras used by generic resources_list ─────────
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
  namespace: avesha
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

## Generate Kubeconfig

**Prerequisites**: Cluster admin access, kubectl configured.

### **Step 1: Create Namespace and Service Account**
```bash
# Create namespace
kubectl create namespace avesha

# Create service account
kubectl create serviceaccount obliq-sre-agent -n avesha
```

### **Step 2: Apply RBAC Configuration**
```bash
# Apply the complete RBAC configuration
kubectl apply -f - << EOF
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
  namespace: avesha
roleRef:
  kind: ClusterRole
  name: obliq-sre-agent
  apiGroup: rbac.authorization.k8s.io
EOF
```

### **Step 3: Generate Service Account Token**
```bash
# Create token secret
kubectl apply -f - << EOF
apiVersion: v1
kind: Secret
metadata:
  name: obliq-sre-agent-token
  namespace: avesha
  annotations:
    kubernetes.io/service-account.name: obliq-sre-agent
type: kubernetes.io/service-account-token
EOF

# Wait for token to be generated
sleep 10

# Get token
TOKEN=$(kubectl get secret obliq-sre-agent-token -n avesha -o jsonpath='{.data.token}' | base64 -d)

# Get cluster information
CLUSTER_NAME="your-cluster-name"
CLUSTER_ENDPOINT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CLUSTER_CA=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')
```

### **Step 4: Create Kubeconfig**
```bash
# Create kubeconfig file
cat > obliq-sre-agent-kubeconfig.yaml << EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${CLUSTER_CA}
    server: ${CLUSTER_ENDPOINT}
  name: ${CLUSTER_NAME}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    user: obliq-sre-agent
  name: ${CLUSTER_NAME}
current-context: ${CLUSTER_NAME}
users:
- name: obliq-sre-agent
  user:
    token: ${TOKEN}
EOF

echo "Kubeconfig created: obliq-sre-agent-kubeconfig.yaml"
```

### **Step 5: Test Kubeconfig**
```bash
# Test the kubeconfig
kubectl --kubeconfig=obliq-sre-agent-kubeconfig.yaml get nodes
kubectl --kubeconfig=obliq-sre-agent-kubeconfig.yaml get pods -n avesha
kubectl --kubeconfig=obliq-sre-agent-kubeconfig.yaml get deployments -n avesha
```
