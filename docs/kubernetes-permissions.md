# Kubernetes Permissions Guide

This document outlines the required Kubernetes permissions for the Avesha Agents platform to function properly.

## Overview

The Avesha Agents platform requires specific Kubernetes permissions to monitor, collect metrics, and manage resources across your cluster. These permissions are organized into three main categories:

1. **Cluster-Scoped Permissions** - Access to cluster-wide resources
2. **Namespace-Scoped Permissions** - Access to resources within specific namespaces
3. **Metrics API Permissions** - Access to Kubernetes metrics for monitoring

## Required Permissions

### **Cluster-Scoped Permissions**

These permissions allow access to cluster-wide resources:

```yaml
# ClusterRole permissions
- apiGroups: [""]
  resources: ["nodes", "namespaces"]
  verbs: ["get", "list"]
```

**Resources:**
- **`nodes`**: `get`, `list` - Access to cluster node information
- **`namespaces`**: `get`, `list` - Access to namespace information across the cluster

### **Namespace-Scoped Permissions**

These permissions allow access to resources within specific namespaces:

```yaml
# Namespace-scoped permissions
- apiGroups: [""]
  resources: ["pods", "pods/log", "events", "services"]
  verbs: ["get", "list", "watch"]

- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets", "daemonsets"]
  verbs: ["get", "list", "watch"]
```

**Resources:**
- **`pods`**: `get`, `list`, `watch` - Access to pod information and status
- **`pods/log`**: `get` - Access to pod logs for troubleshooting
- **`events`**: `get`, `list`, `watch` - Access to Kubernetes events
- **`services`**: `get`, `list`, `watch` - Access to service information
- **`deployments`**: `get`, `list`, `watch` - Access to deployment status
- **`replicasets`**: `get`, `list`, `watch` - Access to replica set information
- **`statefulsets`**: `get`, `list`, `watch` - Access to stateful set status
- **`daemonsets`**: `get`, `list`, `watch` - Access to daemon set information

### **Metrics API Permissions**

These permissions allow access to Kubernetes metrics for monitoring and alerting:

```yaml
# Metrics API permissions
- apiGroups: ["metrics.k8s.io"]
  resources: ["pods", "nodes"]
  verbs: ["get", "list"]
```

**Resources:**
- **`pods.metrics.k8s.io`**: `get`, `list` - Access to pod resource metrics (CPU, memory)
- **`nodes.metrics.k8s.io`**: `get`, `list` - Access to node resource metrics

## Implementation

### **Option 1: Create Custom ClusterRole and ClusterRoleBinding**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: avesha-agents-monitoring
rules:
# Cluster-scoped permissions
- apiGroups: [""]
  resources: ["nodes", "namespaces"]
  verbs: ["get", "list"]

# Namespace-scoped permissions
- apiGroups: [""]
  resources: ["pods", "pods/log", "events", "services"]
  verbs: ["get", "list", "watch"]

- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets", "daemonsets"]
  verbs: ["get", "list", "watch"]

# Metrics API permissions
- apiGroups: ["metrics.k8s.io"]
  resources: ["pods", "nodes"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: avesha-agents-monitoring
subjects:
- kind: ServiceAccount
  name: avesha-agents
  namespace: avesha
roleRef:
  kind: ClusterRole
  name: avesha-agents-monitoring
  apiGroup: rbac.authorization.k8s.io
```

### **Option 2: Use Existing Cluster Roles**

If you prefer to use existing cluster roles, you can bind to:

```yaml
# Bind to view cluster role (read-only access)
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: avesha-agents-view
subjects:
- kind: ServiceAccount
  name: avesha-agents
  namespace: avesha
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
```

**Note**: The `view` cluster role provides most of the required permissions but may need additional metrics API permissions.

## Service Account Configuration

Ensure your Avesha Agents deployment uses the correct service account:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: avesha-agents
  namespace: avesha
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: avesha-agents
spec:
  template:
    spec:
      serviceAccountName: avesha-agents
      # ... other configuration
```

## Verification

To verify the permissions are working correctly:

```bash
# Test cluster-scoped access
kubectl auth can-i get nodes --as=system:serviceaccount:avesha:avesha-agents
kubectl auth can-i list namespaces --as=system:serviceaccount:avesha:avesha-agents

# Test namespace-scoped access
kubectl auth can-i get pods --as=system:serviceaccount:avesha:avesha-agents -n avesha
kubectl auth can-i get deployments --as=system:serviceaccount:avesha:avesha-agents -n avesha

# Test metrics API access
kubectl auth can-i get pods.metrics.k8s.io --as=system:serviceaccount:avesha:avesha-agents
kubectl auth can-i get nodes.metrics.k8s.io --as=system:serviceaccount:avesha:avesha-agents
```

## Security Considerations

- **Principle of Least Privilege**: Only grant the minimum permissions necessary
- **Namespace Isolation**: Consider restricting access to specific namespaces if possible
- **Regular Review**: Periodically review and audit permissions
- **Monitoring**: Monitor for any permission-related errors in logs

## Troubleshooting

### **Common Permission Issues**

1. **"Forbidden" errors**: Check if the service account has the required permissions
2. **Metrics API errors**: Ensure metrics-server is installed and the service account has metrics API access
3. **Cross-namespace access**: Verify cluster role bindings are properly configured

### **Debug Commands**

```bash
# Check service account permissions
kubectl auth can-i --list --as=system:serviceaccount:avesha:avesha-agents

# Check cluster role bindings
kubectl get clusterrolebindings | grep avesha

# Check cluster roles
kubectl get clusterroles | grep avesha
```

## References

- [Kubernetes RBAC Documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Kubernetes Metrics API](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-metrics-pipeline/)
- [Service Accounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)

---

**Note**: This document should be reviewed and updated as the Avesha Agents platform evolves and new permission requirements are identified.
