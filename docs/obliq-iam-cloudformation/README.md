# Obliq IAM CloudFormation Templates

This repository contains production-ready CloudFormation templates for provisioning IAM resources required by the Obliq AI SRE Agent Platform, supporting **all three access methods** from the [official Obliq documentation](https://repo.obliq.avesha.io/docs/aws-iam-policies.html).

## Overview

The Obliq AI SRE Agent Platform requires specific AWS IAM permissions to monitor EC2 instances, collect CloudWatch metrics, and manage AWS resources securely. This project provides:

1. Production-ready CloudFormation templates supporting all three official access methods
2. Complete IAM access coverage for user access keys, IAM roles, and EKS IRSA
3. Parameter files for easy deployment configuration
4. Customer-specific resource tagging and segregation

## Complete Access Method Coverage

This template supports all three access methods specified in the [official Obliq AWS IAM Policies Guide](https://repo.obliq.avesha.io/docs/aws-iam-policies.html):

| Access Method | Description | Use Case | CFT Support |
|---------------|-------------|----------|-------------|
| **🔑 IAM User + Access Keys** | Programmatic access with access keys | Applications, scripts, CLI tools | Supported |
| **🖥️ IAM Roles (EC2)** | Instance-based access via IAM roles | EC2 instances running Obliq agents | Supported |
| **☸️ EKS IRSA** | Kubernetes service account integration | EKS pods and containers | Supported |

## Available Templates

### 1. obliq-iam-template.yaml
- Complete production template with all three access methods
- Customer-specific tagging for resource segregation
- IAM User + Access Keys support for programmatic access
- EC2 IAM Roles with instance profiles  
- EKS IRSA integration with service account roles
- Enhanced outputs with deployment summary and resource information
- Parameterized configuration for maximum flexibility
- Conditional resources with feature toggles (only one access method at a time)
- Comprehensive validation with cfn-lint and AWS CloudFormation

### 2. Ready-to-Deploy Parameter Files
- **parameters-ec2-role.json** - EC2 IAM Role deployment
- **parameters-eks-irsa.json** - EKS IRSA deployment
- **parameters-iam-user.json** - IAM User with Access Keys deployment

## Customer Resource Segregation

All resources are tagged with customer-specific information for clear segregation:

| Tag Key | Description | Example Value |
|---------|-------------|---------------|
| `Customer` | Customer name for resource segregation | `acme-corp` |
| `Purpose` | Obliq component purpose | `Obliq-EC2-Agent` |
| `ManagedBy` | Resource management method | `CloudFormation` |
| `Component` | IAM resource type | `IAM-Role`, `IAM-Policy`, `IAM-User` |

## Repository Structure

```
obliq-iam-cloudformation/
├── obliq-iam-template.yaml          # Main CloudFormation template
├── parameters-ec2-role.json         # EC2 IAM Role parameters
├── parameters-eks-irsa.json         # EKS IRSA parameters
├── parameters-iam-user.json         # IAM User + Access Keys parameters
└── README.md                        # Complete documentation
```

**5 files total** - Clean, focused, and production-ready.

## Quick Start

### Option 1: IAM User with Access Keys

For programmatic access (applications, CLI tools, scripts):

```bash
# Deploy IAM User with access keys using parameter file
aws cloudformation create-stack \
  --stack-name obliq-iam-user-access \
  --template-body file://obliq-iam-template.yaml \
  --parameters file://parameters-iam-user.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --tags Key=Customer,Value=acme-corp Key=AccessMethod,Value=IAM-User
```

### Option 2: EC2 IAM Roles

For EC2 instances running Obliq agents:

```bash
# Deploy EC2 IAM roles using parameter file
aws cloudformation create-stack \
  --stack-name obliq-iam-ec2-roles \
  --template-body file://obliq-iam-template.yaml \
  --parameters file://parameters-ec2-role.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --tags Key=Customer,Value=acme-corp Key=AccessMethod,Value=EC2-Role
```

### Option 3: EKS IRSA

For Kubernetes service accounts in EKS:

```bash
# Deploy EKS IRSA roles using parameter file (update OIDC ID in parameters-eks-irsa.json first)
aws cloudformation create-stack \
  --stack-name obliq-iam-eks-irsa \
  --template-body file://obliq-iam-template.yaml \
  --parameters file://parameters-eks-irsa.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --tags Key=Customer,Value=acme-corp Key=AccessMethod,Value=EKS-IRSA
```

## Important: Single Access Method Policy

Only one access method can be used per deployment. The three access methods are mutually exclusive:

- IAM User + Access Keys: For programmatic access
- EC2 IAM Roles: For EC2 instances  
- EKS IRSA: For Kubernetes service accounts

Use the appropriate parameter file for your specific access method.

## Validation & Testing

All templates and parameter files have been thoroughly validated and tested with cfn-lint and AWS CloudFormation service.

## 📁 **Parameter Files**

Three ready-to-use parameter files are provided for immediate deployment:

### parameters-ec2-role.json
```json
[
  {
    "ParameterKey": "CustomerName",
    "ParameterValue": "acme-corp"
  },
  {
    "ParameterKey": "ResourcePrefix", 
    "ParameterValue": "AcmeObliq"
  },
  {
    "ParameterKey": "CreateEC2Role",
    "ParameterValue": "true"
  },
  {
    "ParameterKey": "CreateIRSARoles",
    "ParameterValue": "false"
  },
  {
    "ParameterKey": "CreateIAMUser",
    "ParameterValue": "false"
  }
]
```

### parameters-eks-irsa.json  
```json
[
  {
    "ParameterKey": "CustomerName",
    "ParameterValue": "acme-corp"
  },
  {
    "ParameterKey": "ResourcePrefix",
    "ParameterValue": "AcmeObliq"
  },
  {
    "ParameterKey": "CreateEC2Role",
    "ParameterValue": "false"
  },
  {
    "ParameterKey": "CreateIRSARoles",
    "ParameterValue": "true"
  },
  {
    "ParameterKey": "EKSOIDCProviderID",
    "ParameterValue": "ABCDEF1234567890ABCDEF1234567890ABCDEF12"
  }
]
```

### parameters-iam-user.json
```json
[
  {
    "ParameterKey": "CustomerName",
    "ParameterValue": "acme-corp"
  },
  {
    "ParameterKey": "ResourcePrefix",
    "ParameterValue": "AcmeObliq"
  },
  {
    "ParameterKey": "CreateEC2Role",
    "ParameterValue": "false"
  },
  {
    "ParameterKey": "CreateIRSARoles",
    "ParameterValue": "false"
  },
  {
    "ParameterKey": "CreateIAMUser",
    "ParameterValue": "true"
  },
  {
    "ParameterKey": "CreateAccessKeys",
    "ParameterValue": "true"
  }
]
```

**To customize for your environment:**
1. Update `CustomerName` with your customer identifier
2. Update `ResourcePrefix` with your preferred naming
3. For EKS IRSA: Update `EKSOIDCProviderID` with your actual EKS OIDC provider ID

## Template Features

### IAM Resources Created

#### Policies
1. **Core Monitoring Policy**
   - `ec2:DescribeInstances`, `ec2:DescribeRegions`, `ec2:DescribeAccountAttributes`
   - `cloudwatch:GetMetricStatistics`, `cloudwatch:ListMetrics`, `cloudwatch:GetMetricData`
   - `sts:AssumeRoleWithWebIdentity`

2. **AWS MCP Policy** (optional)
   - Enhanced EC2 permissions (VPCs, Security Groups, Subnets)
   - CloudWatch alarm permissions
   - Additional monitoring capabilities

3. **CloudWatch MCP Policy** (optional)
   - Advanced CloudWatch permissions
   - CloudWatch Logs access
   - Alarm history and management

#### Roles
1. **EC2 Instance Role** - For running Obliq agents on EC2 instances
2. **CloudWatch Alarms IRSA Role** - For `aws-ec2-cloudwatch-alarms` service account
3. **AWS MCP IRSA Role** - For `aws-mcp` service account

#### Users & Access Keys
1. **IAM User** - For programmatic access to AWS APIs
2. **Access Keys** - AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY for authentication
3. **Policy Attachments** - Core monitoring and enhanced policies attached to user

### Key Capabilities

- **Parameterized**: Configurable account IDs, role names, policy ARNs
- **Conditional Resources**: Feature toggles to enable/disable components
- **Least Privilege**: Follows AWS security best practices
- **Cross-Account Support**: Ready for multi-account deployments
- **EKS Integration**: Full IRSA (IAM Roles for Service Accounts) support

## Template Parameters

### Core Parameters

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `CustomerName` | Customer name for resource tagging and segregation | `customer-demo` | No |
| `ResourcePrefix` | Prefix for resource names | `Obliq` | No |
| `AccountId` | AWS Account ID | (empty - uses current account) | No |
| `Region` | AWS Region | (empty - uses current region) | No |

### EKS Parameters (for IRSA)

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `EKSOIDCProviderID` | EKS OIDC provider ID | (empty) | For IRSA |
| `KubernetesNamespace` | K8s namespace | `avesha` | No |
| `CloudWatchServiceAccount` | CloudWatch service account | `aws-ec2-cloudwatch-alarms` | No |
| `AWSMCPServiceAccount` | AWS MCP service account | `aws-mcp` | No |

### Feature Toggles

| Parameter | Description | Default |
|-----------|-------------|---------|
| `CreateEC2Role` | Create EC2 instance role | `true` |
| `CreateIRSARoles` | Create EKS IRSA roles | `true` |
| `CreateEnhancedPolicies` | Create enhanced policies | `true` |
| `CreateIAMUser` | Create IAM user for programmatic access | `false` |
| `CreateAccessKeys` | Create access keys for IAM user | `false` |



## Validation Steps

### 1. Install Prerequisites

```bash
# Install cfn-lint for CloudFormation validation
pip install cfn-lint

# Ensure AWS CLI is installed and configured
aws configure
```

### 2. Validate Templates

```bash
# Validate with cfn-lint
cfn-lint obliq-iam-template-simple.yaml
cfn-lint obliq-iam-template.yaml

# Validate with AWS CloudFormation
aws cloudformation validate-template --template-body file://obliq-iam-template.yaml
```

## Deployment Steps

### 1. Prepare for Deployment

#### Get EKS OIDC Provider ID (for IRSA)
```bash
# List EKS clusters
aws eks list-clusters --region us-east-1

# Get OIDC issuer URL
aws eks describe-cluster --name your-cluster-name --region us-east-1 --query "cluster.identity.oidc.issuer" --output text

# Extract the OIDC provider ID from the URL (the part after /id/)
```

### 2. Deploy CloudFormation Stack

Choose **ONE** access method and deploy using the corresponding parameter file:

#### Option A: EC2 IAM Role Deployment
```bash
aws cloudformation create-stack \
  --stack-name obliq-iam-ec2 \
  --template-body file://obliq-iam-template.yaml \
  --parameters file://parameters-ec2-role.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --tags Key=Customer,Value=acme-corp Key=AccessMethod,Value=EC2-Role
```

#### Option B: EKS IRSA Deployment
```bash
# First, update the OIDC Provider ID in parameters-eks-irsa.json
aws cloudformation create-stack \
  --stack-name obliq-iam-eks \
  --template-body file://obliq-iam-template.yaml \
  --parameters file://parameters-eks-irsa.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --tags Key=Customer,Value=acme-corp Key=AccessMethod,Value=EKS-IRSA
```

#### Option C: IAM User + Access Keys Deployment
```bash
aws cloudformation create-stack \
  --stack-name obliq-iam-user \
  --template-body file://obliq-iam-template.yaml \
  --parameters file://parameters-iam-user.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --tags Key=Customer,Value=acme-corp Key=AccessMethod,Value=IAM-User
```

### 3. Monitor Stack Creation

```bash
# Check stack creation status
aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $AWS_REGION \
  --query 'Stacks[0].StackStatus' \
  --output text

# Monitor stack events
aws cloudformation describe-stack-events \
  --stack-name $STACK_NAME \
  --region $AWS_REGION \
  --query 'StackEvents[*].[Timestamp,ResourceStatus,ResourceType,LogicalResourceId]' \
  --output table

# Wait for stack creation to complete
aws cloudformation wait stack-create-complete \
  --stack-name $STACK_NAME \
  --region $AWS_REGION
```

### 4. Get Stack Outputs

```bash
# Get stack outputs
aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $AWS_REGION \
  --query 'Stacks[0].Outputs[*].{Key:OutputKey,Value:OutputValue,Description:Description}' \
  --output table
```

## Post-Deployment Configuration

### 1. EKS Service Account Configuration

If you deployed IRSA roles, configure your Kubernetes service accounts:

```bash
# Get role ARNs from stack outputs
export CLOUDWATCH_ROLE_ARN=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $AWS_REGION \
  --query 'Stacks[0].Outputs[?OutputKey==`CloudWatchAlarmsRoleArn`].OutputValue' \
  --output text)

export AWSMCP_ROLE_ARN=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $AWS_REGION \
  --query 'Stacks[0].Outputs[?OutputKey==`AWSMCPRoleArn`].OutputValue' \
  --output text)

# Annotate service accounts
kubectl annotate serviceaccount aws-ec2-cloudwatch-alarms \
  -n $K8S_NAMESPACE \
  eks.amazonaws.com/role-arn=$CLOUDWATCH_ROLE_ARN

kubectl annotate serviceaccount aws-mcp \
  -n $K8S_NAMESPACE \
  eks.amazonaws.com/role-arn=$AWSMCP_ROLE_ARN
```

### 2. EC2 Instance Profile Configuration

If you deployed EC2 roles, attach the instance profile to your EC2 instances:

```bash
# Get instance profile ARN
export EC2_PROFILE_ARN=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $AWS_REGION \
  --query 'Stacks[0].Outputs[?OutputKey==`EC2InstanceProfileArn`].OutputValue' \
  --output text)

# Get instance profile name (extract from ARN)
export EC2_PROFILE_NAME=$(echo $EC2_PROFILE_ARN | cut -d'/' -f2)

# Attach to existing EC2 instance
aws ec2 associate-iam-instance-profile \
  --instance-id i-1234567890abcdef0 \
  --iam-instance-profile Name=$EC2_PROFILE_NAME \
  --region $AWS_REGION
```

## Template Outputs

The templates provide the following outputs:

### Policy ARNs
- `CoreMonitoringPolicyArn` - Core monitoring policy
- `AWSMCPPolicyArn` - AWS MCP policy (if enabled)
- `CloudWatchMCPPolicyArn` - CloudWatch MCP policy (if enabled)

### Role ARNs
- `EC2RoleArn` - EC2 instance role (if enabled)
- `EC2InstanceProfileArn` - EC2 instance profile (if enabled)
- `CloudWatchAlarmsRoleArn` - CloudWatch IRSA role (if enabled)
- `AWSMCPRoleArn` - AWS MCP IRSA role (if enabled)

### IAM User Resources
- `IAMUserArn` - IAM user ARN (if enabled)
- `AccessKeyId` - AWS Access Key ID for programmatic access (if enabled)
- `SecretAccessKey` - AWS Secret Access Key for programmatic access (if enabled)

### Configuration Info
- `KubernetesServiceAccountAnnotations` - Service account annotation examples

### Stack Information
- `StackInformation` - Complete CloudFormation stack deployment details
- `CustomerName` - Customer name used for tagging  
- `ResourcePrefix` - Resource prefix used for naming
- `DeploymentSummary` - Summary of created resources with customer information

## Troubleshooting

### Common Issues

1. **IRSA Role Creation Fails**
   - Verify EKS OIDC provider ID is correct
   - Ensure OIDC provider is associated with the EKS cluster
   - Check that the EKS cluster exists in the specified region

2. **Permission Denied Errors**
   - Verify IAM permissions for CloudFormation deployment
   - Ensure `CAPABILITY_NAMED_IAM` is specified
   - Check that role names don't conflict with existing roles

3. **Template Validation Errors**
   - Use `obliq-iam-template-simple.yaml` for cfn-lint compatibility
   - Verify all required parameters are provided
   - Check parameter values match allowed patterns

### Debug Commands

```bash
# Check stack events for errors
aws cloudformation describe-stack-events --stack-name $STACK_NAME

# Get detailed stack information
aws cloudformation describe-stacks --stack-name $STACK_NAME

# List stack resources
aws cloudformation describe-stack-resources --stack-name $STACK_NAME

# Test role assumptions
aws sts assume-role \
  --role-arn "arn:aws:iam::123456789012:role/Obliq-EC2-Role" \
  --role-session-name "test-session"
```

## Stack Updates

### Update Existing Stack

```bash
# Update stack with new parameters
aws cloudformation update-stack \
  --stack-name $STACK_NAME \
  --template-body file://$TEMPLATE_FILE \
  --parameters \
    ParameterKey=ResourcePrefix,ParameterValue=$RESOURCE_PREFIX \
    ParameterKey=EKSOIDCProviderID,ParameterValue=$OIDC_PROVIDER_ID \
    ParameterKey=CreateEnhancedPolicies,ParameterValue=false \
  --capabilities CAPABILITY_NAMED_IAM \
  --region $AWS_REGION
```

### Create Change Set (Dry Run)

```bash
# Create change set to preview changes
aws cloudformation create-change-set \
  --stack-name $STACK_NAME \
  --template-body file://$TEMPLATE_FILE \
  --change-set-name obliq-update-$(date +%s) \
  --parameters \
    ParameterKey=ResourcePrefix,ParameterValue=$RESOURCE_PREFIX \
    ParameterKey=EKSOIDCProviderID,ParameterValue=$OIDC_PROVIDER_ID \
  --capabilities CAPABILITY_NAMED_IAM \
  --region $AWS_REGION

# Review change set
export CHANGE_SET_NAME="obliq-update-$(date +%s)"
aws cloudformation describe-change-set \
  --stack-name $STACK_NAME \
  --change-set-name $CHANGE_SET_NAME \
  --region $AWS_REGION
```

## Security Best Practices

1. **Least Privilege**: Templates implement minimal required permissions
2. **Access Key Security** (Important): 
   - Store access keys securely (AWS Secrets Manager, environment variables)
   - Rotate access keys regularly
   - Never commit access keys to version control
   - Use IAM roles instead of access keys when possible
3. **Resource Restrictions**: Consider adding resource-level restrictions for production
4. **Regular Audits**: Use AWS IAM Access Analyzer to review permissions
5. **CloudTrail**: Enable CloudTrail for API monitoring
6. **Cross-Account Access**: Use proper role assumption for multi-account setups

### Access Key Management

When using the IAM User + Access Keys option:

```bash
# Retrieve access keys from stack outputs
export ACCESS_KEY_ID=$(aws cloudformation describe-stacks \
  --stack-name your-stack-name \
  --query 'Stacks[0].Outputs[?OutputKey==`AccessKeyId`].OutputValue' \
  --output text)

export SECRET_ACCESS_KEY=$(aws cloudformation describe-stacks \
  --stack-name your-stack-name \
  --query 'Stacks[0].Outputs[?OutputKey==`SecretAccessKey`].OutputValue' \
  --output text)

# Store in environment variables or secure credential store
echo "AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID" >> ~/.env
echo "AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY" >> ~/.env
```

## Requirements

- AWS CLI v2+
- cfn-lint (for validation)
- kubectl (for EKS integration)

## References

- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [EKS IRSA Documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [CloudFormation IAM Template Reference](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/AWS_IAM.html)
- [Obliq AWS IAM Policies Guide](https://repo.obliq.avesha.io/docs/aws-iam-policies.html)