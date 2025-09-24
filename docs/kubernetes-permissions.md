# Kubernetes Permissions Guide

This document provides step-by-step instructions for setting up Kubernetes permissions and kubeconfig for the Obliq SRE Agent platform.

## 📋 Table of Contents

### **1. Core Resources**
- [**Complete RBAC Configuration**](#complete-rbac-configuration) - Ready-to-copy RBAC manifests
- [**Permission Breakdown**](#permission-breakdown) - Detailed permission explanations

### **2. Setup Methods**

#### **🔧 Kubeconfig Generation**
- [**Method A: Admin Kubeconfig**](#method-a-admin-kubeconfig) - Generate admin kubeconfig
- [**Method B: Service Account Kubeconfig**](#method-b-service-account-kubeconfig) - Generate service account kubeconfig
- [**Method C: User Kubeconfig**](#method-c-user-kubeconfig) - Generate user kubeconfig

#### **🛡️ RBAC Configuration**
- [**Method A: ClusterRole + ClusterRoleBinding**](#method-a-clusterrole--clusterrolebinding) - Full cluster access
- [**Method B: Role + RoleBinding**](#method-b-role--rolebinding) - Namespace-scoped access
- [**Method C: Existing Roles**](#method-c-existing-roles) - Use built-in roles

## Overview

The Obliq SRE Agent platform requires specific Kubernetes permissions to monitor cluster resources and collect metrics.

## Complete RBAC Configuration

**Copy this complete RBAC configuration for immediate use:**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kubernetes-mcp
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
  name: kubernetes-mcp
subjects:
- kind: ServiceAccount
  name: obliq-sre-agent
  namespace: avesha
roleRef:
  kind: ClusterRole
  name: kubernetes-mcp
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

## Setup Methods

### **🔧 Kubeconfig Generation**

#### **Method A: Admin Kubeconfig**

**Prerequisites**: Cluster admin access, kubectl configured.

**Step 1: Generate Admin Kubeconfig**
```bash
# Get cluster information
CLUSTER_NAME="your-cluster-name"
REGION="us-east-1"

# Get cluster endpoint
CLUSTER_ENDPOINT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

# Get cluster CA certificate
CLUSTER_CA=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

# Create kubeconfig file
cat > obliq-sre-kubeconfig.yaml << EOF
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
    user: admin
  name: ${CLUSTER_NAME}
current-context: ${CLUSTER_NAME}
users:
- name: admin
  user:
    client-certificate-data: $(kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}')
    client-key-data: $(kubectl config view --raw -o jsonpath='{.users[0].user.client-key-data}')
EOF

echo "Kubeconfig created: obliq-sre-kubeconfig.yaml"
```

**Step 2: Test Kubeconfig**
```bash
# Test the kubeconfig
kubectl --kubeconfig=obliq-sre-kubeconfig.yaml get nodes
kubectl --kubeconfig=obliq-sre-kubeconfig.yaml get namespaces
```

#### **Method B: Service Account Kubeconfig**

**Prerequisites**: Cluster admin access, kubectl configured.

**Step 1: Create Service Account and RBAC**
```bash
# Create namespace
kubectl create namespace avesha

# Create service account
kubectl create serviceaccount obliq-sre-agent -n avesha

# Apply the RBAC configuration
kubectl apply -f - << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kubernetes-mcp
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
  name: kubernetes-mcp
subjects:
- kind: ServiceAccount
  name: obliq-sre-agent
  namespace: avesha
roleRef:
  kind: ClusterRole
  name: kubernetes-mcp
  apiGroup: rbac.authorization.k8s.io
EOF
```

**Step 2: Generate Service Account Token**
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

**Step 3: Create Service Account Kubeconfig**
```bash
# Create kubeconfig file
cat > obliq-sre-serviceaccount-kubeconfig.yaml << EOF
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

echo "Service Account Kubeconfig created: obliq-sre-serviceaccount-kubeconfig.yaml"
```

**Step 4: Test Service Account Kubeconfig**
```bash
# Test the kubeconfig
kubectl --kubeconfig=obliq-sre-serviceaccount-kubeconfig.yaml get nodes
kubectl --kubeconfig=obliq-sre-serviceaccount-kubeconfig.yaml get pods -n avesha
```

#### **Method C: User Kubeconfig**

**Prerequisites**: Cluster admin access, kubectl configured.

**Step 1: Create User and RBAC**
```bash
# Create user
USER_NAME="obliq-sre-user"

# Create ClusterRole for user
kubectl apply -f - << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kubernetes-mcp-user
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
  name: kubernetes-mcp-user
subjects:
- kind: User
  name: ${USER_NAME}
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: kubernetes-mcp-user
  apiGroup: rbac.authorization.k8s.io
EOF
```

**Step 2: Generate User Certificate**
```bash
# Create private key
openssl genrsa -out obliq-sre-user.key 2048

# Create certificate signing request
openssl req -new -key obliq-sre-user.key -out obliq-sre-user.csr -subj "/CN=${USER_NAME}/O=obliq-sre"

# Get cluster CA certificate
kubectl get secret -n kube-system | grep cluster-ca
CLUSTER_CA_SECRET=$(kubectl get secret -n kube-system | grep cluster-ca | awk '{print $1}')

# Sign the certificate
kubectl certificate approve $(kubectl get csr | grep ${USER_NAME} | awk '{print $1}') || \
kubectl create csr obliq-sre-user --cert=obliq-sre-user.crt --key=obliq-sre-user.key --user=${USER_NAME}
```

**Step 3: Create User Kubeconfig**
```bash
# Get cluster information
CLUSTER_NAME="your-cluster-name"
CLUSTER_ENDPOINT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CLUSTER_CA=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

# Create kubeconfig file
cat > obliq-sre-user-kubeconfig.yaml << EOF
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
    user: ${USER_NAME}
  name: ${CLUSTER_NAME}
current-context: ${CLUSTER_NAME}
users:
- name: ${USER_NAME}
  user:
    client-certificate-data: $(cat obliq-sre-user.crt | base64 -w 0)
    client-key-data: $(cat obliq-sre-user.key | base64 -w 0)
EOF

echo "User Kubeconfig created: obliq-sre-user-kubeconfig.yaml"
```

### **🛡️ RBAC Configuration**

#### **Method A: ClusterRole + ClusterRoleBinding**

**Prerequisites**: Cluster admin access, kubectl configured.

**Step 1: Create Namespace and Service Account**
```bash
# Create namespace
kubectl create namespace avesha

# Create service account
kubectl create serviceaccount obliq-sre-agent -n avesha
```

**Step 2: Apply RBAC Configuration**
```bash
# Apply the complete RBAC configuration
kubectl apply -f - << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kubernetes-mcp
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
  name: kubernetes-mcp
subjects:
- kind: ServiceAccount
  name: obliq-sre-agent
  namespace: avesha
roleRef:
  kind: ClusterRole
  name: kubernetes-mcp
  apiGroup: rbac.authorization.k8s.io
EOF
```

**Step 3: Verify RBAC Configuration**
```bash
# Verify cluster role
kubectl get clusterrole kubernetes-mcp

# Verify cluster role binding
kubectl get clusterrolebinding kubernetes-mcp

# Test permissions
kubectl auth can-i get pods --as=system:serviceaccount:avesha:obliq-sre-agent
kubectl auth can-i get nodes --as=system:serviceaccount:avesha:obliq-sre-agent
```

#### **Method B: Role + RoleBinding**

**Prerequisites**: Cluster admin access, kubectl configured.

**Step 1: Create Namespace and Service Account**
```bash
# Create namespace
kubectl create namespace avesha

# Create service account
kubectl create serviceaccount obliq-sre-agent -n avesha
```

**Step 2: Apply Namespace-Scoped RBAC**
```bash
# Apply namespace-scoped RBAC configuration
kubectl apply -f - << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kubernetes-mcp
  namespace: avesha
rules:
- apiGroups: [""]
  resources:
  - pods
  - pods/log
  - services
  - endpoints
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
- apiGroups: ["networking.k8s.io"]
  resources:
  - ingresses
  - networkpolicies
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kubernetes-mcp
  namespace: avesha
subjects:
- kind: ServiceAccount
  name: obliq-sre-agent
  namespace: avesha
roleRef:
  kind: Role
  name: kubernetes-mcp
  apiGroup: rbac.authorization.k8s.io
EOF
```

**Step 3: Add Cluster-Level Permissions**
```bash
# Add cluster-level permissions for nodes and namespaces
kubectl apply -f - << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kubernetes-mcp-cluster
rules:
- apiGroups: [""]
  resources:
  - nodes
  - namespaces
  verbs: ["get", "list", "watch"]
- apiGroups: ["metrics.k8s.io"]
  resources:
  - pods
  - nodes
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-mcp-cluster
subjects:
- kind: ServiceAccount
  name: obliq-sre-agent
  namespace: avesha
roleRef:
  kind: ClusterRole
  name: kubernetes-mcp-cluster
  apiGroup: rbac.authorization.k8s.io
EOF
```

#### **Method C: Existing Roles**

**Prerequisites**: Cluster admin access, kubectl configured.

**Step 1: Create Namespace and Service Account**
```bash
# Create namespace
kubectl create namespace avesha

# Create service account
kubectl create serviceaccount obliq-sre-agent -n avesha
```

**Step 2: Bind to Existing Cluster Roles**
```bash
# Bind to view cluster role (read-only access)
kubectl create clusterrolebinding obliq-sre-view \
  --clusterrole=view \
  --serviceaccount=avesha:obliq-sre-agent

# Add metrics API permissions
kubectl apply -f - << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kubernetes-mcp-metrics
rules:
- apiGroups: ["metrics.k8s.io"]
  resources:
  - pods
  - nodes
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-mcp-metrics
subjects:
- kind: ServiceAccount
  name: obliq-sre-agent
  namespace: avesha
roleRef:
  kind: ClusterRole
  name: kubernetes-mcp-metrics
  apiGroup: rbac.authorization.k8s.io
EOF
```

## Verification

### **Test Permissions**
```bash
# Test cluster-scoped access
kubectl auth can-i get nodes --as=system:serviceaccount:avesha:obliq-sre-agent
kubectl auth can-i list namespaces --as=system:serviceaccount:avesha:obliq-sre-agent

# Test namespace-scoped access
kubectl auth can-i get pods --as=system:serviceaccount:avesha:obliq-sre-agent -n avesha
kubectl auth can-i get deployments --as=system:serviceaccount:avesha:obliq-sre-agent -n avesha

# Test metrics API access
kubectl auth can-i get pods.metrics.k8s.io --as=system:serviceaccount:avesha:obliq-sre-agent
kubectl auth can-i get nodes.metrics.k8s.io --as=system:serviceaccount:avesha:obliq-sre-agent
```

### **Debug Commands**
```bash
# Check service account permissions
kubectl auth can-i --list --as=system:serviceaccount:avesha:obliq-sre-agent

# Check cluster role bindings
kubectl get clusterrolebindings | grep kubernetes-mcp

# Check cluster roles
kubectl get clusterroles | grep kubernetes-mcp
```

## Security Considerations

- **Principle of Least Privilege**: Only grant the minimum permissions necessary
- **Namespace Isolation**: Consider restricting access to specific namespaces if possible
- **Regular Review**: Periodically review and audit permissions
- **Monitoring**: Monitor for any permission-related errors in logs

## Troubleshooting

### **Common Issues**

1. **"Forbidden" errors**: Check if the service account has the required permissions
2. **Metrics API errors**: Ensure metrics-server is installed and the service account has metrics API access
3. **Cross-namespace access**: Verify cluster role bindings are properly configured

### **Debug Steps**

```bash
# Check service account exists
kubectl get serviceaccount obliq-sre-agent -n avesha

# Check cluster role binding
kubectl get clusterrolebinding kubernetes-mcp

# Check permissions
kubectl auth can-i --list --as=system:serviceaccount:avesha:obliq-sre-agent
```

---

**Note**: This document provides comprehensive Kubernetes permission setup for the Obliq SRE Agent platform. Choose the method that best fits your security requirements and operational needs.