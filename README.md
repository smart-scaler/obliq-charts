# Obliq AI SRE Agent Platform

A comprehensive AI-powered Site Reliability Engineering platform deployed as a single Helm chart.

## 📖 Documentation

- **[🚀 Getting Started](#-quick-install)** - Installation guide
- **[⚙️ Services Configuration](./docs/services.md)** - Enable/disable services and integrations
- **[📋 Parameters Reference](./docs/parameters.md)** - Complete configuration options and examples
- **[🔐 Secret Management](./docs/secret-management.md)** - Kubernetes secrets and credentials
- **[📋 Prerequisites](./docs/prerequisites.md)** - System requirements and integrations

## ⚡ Quick Install

### Prerequisites
- **Kubernetes cluster** (v1.19+)
- **Helm** (v3.8+) 
- **OpenAI API Key** - Get your own from https://platform.openai.com/api-keys
- **Container Registry Access** - Contact support@aveshasystems.com for ACR credentials
- **kubeconfig** file for cluster access

💡 **For local development**: Run `./scripts/update-dependencies.sh` to ensure all chart dependencies are resolved before local installation.

📋 **Note**: The `--set-file global.kubeconfig.content=./kubeconfig` parameter expects a kubeconfig file in the current directory. Make sure to:
- Place your kubeconfig file in the same directory where you run the helm command, OR
- Update the path to match your kubeconfig location (e.g., `--set-file global.kubeconfig.content=/path/to/your/kubeconfig`)

### 1. Add Helm Repository
```bash
# Add the Obliq Charts Helm repository
helm repo add obliq-charts https://smart-scaler.github.io/obliq-charts/
helm repo update
```

### 2. Create Registry Secret
```bash
# Get credentials from support@aveshasystems.com
kubectl create namespace avesha --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret docker-registry registry \
  --docker-username=YOUR_USERNAME_FROM_AVESHA \
  --docker-password=YOUR_PASSWORD_FROM_AVESHA \
  --docker-email=your-email@company.com \
  --docker-server=https://avesha.azurecr.io/ \
  -n avesha
```

📚 **For advanced secret management:** See [docs/secret-management.md](./docs/secret-management.md)

### 3. Install Options

💡 **Optional: For easier environment variable management, see [.env file setup](./docs/prerequisites.md#environment-variables-with-env-file).**

📋 **Note:** If you need to create a custom kubeconfig file, you can download it from your Kubernetes cluster or cloud provider.

#### Minimal (Core AI Services)
```bash
# Set your OpenAI API key (get from https://platform.openai.com/api-keys)
export OPENAI_API_KEY="sk-your-openai-api-key"

# Install with LoadBalancer for external UI access
helm install obliq-sre-agent obliq-charts/obliq-sre-agent \
  --namespace avesha \
  --create-namespace \
  --set-file global.kubeconfig.content=./kubeconfig `# Path to your kubeconfig file` \
  --set global.env.openai.OPENAI_API_KEY="${OPENAI_API_KEY}" `# Required for AI services` \
  --set avesha-unified-ui.service.type=LoadBalancer `# Expose UI externally` \
  --timeout 15m
```

#### AWS Integration
```bash
# Core credentials
export OPENAI_API_KEY="sk-your-openai-api-key"  # Get from OpenAI platform
export AWS_ACCESS_KEY_ID="your-aws-access-key"  # AWS IAM user access key
export AWS_SECRET_ACCESS_KEY="your-aws-secret-key"  # AWS IAM user secret
export AWS_ROLE_ARN_AWS_MCP="arn:aws:iam::123456789012:role/your-aws-mcp-role"  # IAM role for AWS MCP
export AWS_REGION="us-west-2"  # AWS region for resources

# Install with AWS integration and LoadBalancer UI access
helm install obliq-sre-agent obliq-charts/obliq-sre-agent \
  --namespace avesha \
  --create-namespace \
  --set-file global.kubeconfig.content=./kubeconfig `# Path to your kubeconfig` \
  --set global.env.openai.OPENAI_API_KEY="${OPENAI_API_KEY}" `# Required for AI services` \
  --set aws-mcp.enabled=true `# Enable AWS MCP service` \
  --set global.env.aws.AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" `# AWS API access` \
  --set global.env.aws.AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" `# AWS API secret` \
  --set global.env.aws.AWS_ROLE_ARN_AWS_MCP="${AWS_ROLE_ARN_AWS_MCP}" `# AWS MCP role ARN` \
  --set global.env.aws.AWS_REGION="${AWS_REGION}" `# AWS region` \
  --set avesha-unified-ui.service.type=LoadBalancer `# Expose UI externally` \
  --timeout 15m
```

📋 **For full integration with all services:** See [Full Integration Example](./docs/parameters.md#-complete-deployment-examples)

### 4. Verify Installation
```bash
# Check pod status (all should be Running)
kubectl get pods -n avesha

# Check deployment status and notes
helm status obliq-sre-agent -n avesha

# Verify core services are ready
kubectl get deployments -n avesha

# Check for any issues
kubectl get events -n avesha --sort-by='.lastTimestamp' | tail -10
```

### 5. Access the UI
```bash
# Get the external IP (may take a few minutes to provision)
kubectl get service -n avesha avesha-unified-ui

# Access at: http://<EXTERNAL-IP>:80
```

🔐 **Default Login Credentials:**
- **Username**: `admin@aveshasystems.com`
- **Password**: `admin123`

**Alternative access methods:**
- **NodePort**: Add `--set avesha-unified-ui.service.type=NodePort` instead of LoadBalancer
- **Port Forward** (ClusterIP): `kubectl port-forward -n avesha service/avesha-unified-ui 8080:80`

## 🗑️ Uninstall

```bash
# Uninstall the application
helm uninstall obliq-sre-agent -n avesha

# Remove the namespace (optional)
kubectl delete namespace avesha
```

📋 **For complete configuration options:** See [docs/parameters.md](./docs/parameters.md)

## 🆘 Troubleshooting

### Common Issues
- **ImagePullBackOff**: Get ACR credentials from support@aveshasystems.com
- **Pod failures**: Check logs with `kubectl logs -n avesha <pod-name>`
- **External access**: External HTTP/HTTPS access requires separate ingress controller installation

### Basic Debugging
```bash
# Check pod status
kubectl get pods -n avesha

# View logs
kubectl logs -n avesha deployment/backend -f

# Check events
kubectl get events -n avesha --sort-by='.lastTimestamp' | tail -10
```

## 📞 Support

- **Email**: support@aveshasystems.com
- **Documentation**: See linked guides above
- **Issues**: Include pod logs and deployment details

---

📊 **For detailed service configuration:** See [docs/services.md](./docs/services.md)
