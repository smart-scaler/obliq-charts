# AWS IAM Policies and Roles Guide

This document outlines the required AWS IAM policies and roles for the Avesha Agents platform to function properly.

## Overview

The Avesha Agents platform requires specific AWS permissions to:
- Monitor EC2 instances and their status
- Collect CloudWatch metrics for monitoring and alerting
- Assume roles for cross-account access
- Manage AWS resources securely

## Required IAM Policy

### **Core Monitoring Policy**

The following IAM policy provides the minimum required permissions for the Avesha Agents platform:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeRegions",
                "ec2:DescribeAccountAttributes",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricData",
                "sts:AssumeRoleWithWebIdentity"
            ],
            "Resource": "*"
        }
    ]
}
```

### **Permission Breakdown**

#### **EC2 Permissions**
- **`ec2:DescribeInstances`**: Access to instance information, status, and metadata
- **`ec2:DescribeRegions`**: List available AWS regions for multi-region monitoring
- **`ec2:DescribeAccountAttributes`**: Access to account-level information and limits

#### **CloudWatch Permissions**
- **`cloudwatch:GetMetricStatistics`**: Retrieve historical metric data for analysis
- **`cloudwatch:ListMetrics`**: Discover available metrics for monitoring
- **`cloudwatch:GetMetricData`**: Get real-time and batch metric data

#### **Security Token Service (STS)**
- **`sts:AssumeRoleWithWebIdentity`**: Assume IAM roles using web identity tokens (for EKS integration)

## Implementation Options

### **Option 1: Create Custom IAM Policy**

1. **Create the Policy:**
```bash
aws iam create-policy \
    --policy-name AveshaAgentsMonitoring \
    --policy-document file://avesha-agents-policy.json
```

2. **Attach to User/Role:**
```bash
# For IAM User
aws iam attach-user-policy \
    --user-name your-username \
    --policy-arn arn:aws:iam::ACCOUNT-ID:policy/AveshaAgentsMonitoring

# For IAM Role
aws iam attach-role-policy \
    --role-name your-role-name \
    --policy-arn arn:aws:iam::ACCOUNT-ID:policy/AveshaAgentsMonitoring
```

### **Option 2: Use AWS Managed Policies**

If you prefer to use AWS managed policies, you can combine:

```bash
# Attach CloudWatch ReadOnly policy
aws iam attach-role-policy \
    --role-name your-role-name \
    --policy-arn arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess

# Attach EC2 ReadOnly policy
aws iam attach-role-policy \
    --role-name your-role-name \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess
```

**Note**: Managed policies may include additional permissions beyond what's required.

### **Option 3: Inline Policy**

You can also attach the policy directly to a role or user:

```bash
aws iam put-role-policy \
    --role-name your-role-name \
    --policy-name AveshaAgentsInline \
    --policy-document file://avesha-agents-policy.json
```

## IAM Role Configuration

### **For EC2 Instances (EC2 Role)**

If running Avesha Agents on EC2 instances:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

### **For EKS Service Accounts (IRSA)**

For Kubernetes deployments using IAM Roles for Service Accounts:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::ACCOUNT-ID:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
                    "token.actions.githubusercontent.com:sub": "repo:your-org/your-repo:ref:refs/heads/main"
                }
            }
        }
    ]
}
```

## Service-Specific Permissions

### **AWS MCP Service**

The AWS MCP service requires additional permissions for enhanced monitoring:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeRegions",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricData",
                "cloudwatch:DescribeAlarms",
                "sts:AssumeRoleWithWebIdentity"
            ],
            "Resource": "*"
        }
    ]
}
```

### **CloudWatch MCP Service**

For CloudWatch-specific monitoring:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricData",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:DescribeAlarmHistory",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:GetLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
```

## Security Best Practices

### **Principle of Least Privilege**

- Only grant the minimum permissions necessary
- Regularly review and audit IAM policies
- Use resource-level permissions when possible
- Implement temporary credentials for short-term access

### **Resource Restrictions**

Consider restricting access to specific resources:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "cloudwatch:GetMetricStatistics"
            ],
            "Resource": [
                "arn:aws:ec2:us-east-1:ACCOUNT-ID:instance/*",
                "arn:aws:cloudwatch:us-east-1:ACCOUNT-ID:metric/*"
            ]
        }
    ]
}
```

### **Conditional Access**

Implement conditions for additional security:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "cloudwatch:GetMetricStatistics"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/Environment": "production"
                },
                "IpAddress": {
                    "aws:SourceIp": "YOUR-IP-RANGE"
                }
            }
        }
    ]
}
```

## Troubleshooting

### **Common Permission Issues**

1. **"Access Denied" errors**: Check if the IAM policy is properly attached
2. **Missing metrics**: Verify CloudWatch permissions are granted
3. **Cross-account access**: Ensure proper role assumption permissions

### **Debug Commands**

```bash
# Test EC2 permissions
aws ec2 describe-instances --region us-east-1

# Test CloudWatch permissions
aws cloudwatch list-metrics --namespace AWS/EC2

# Check IAM policy attachments
aws iam list-attached-role-policies --role-name your-role-name

# Verify policy content
aws iam get-policy-version \
    --policy-arn arn:aws:iam::ACCOUNT-ID:policy/AveshaAgentsMonitoring \
    --version-id v1
```

### **IAM Policy Simulator**

Use the AWS IAM Policy Simulator to test permissions:
1. Go to [IAM Policy Simulator](https://policysim.aws.amazon.com/)
2. Select the user/role to test
3. Choose the actions to simulate
4. Review the results

## Monitoring and Auditing

### **CloudTrail Integration**

Enable CloudTrail to monitor API calls:

```bash
aws cloudtrail create-trail \
    --name avesha-agents-trail \
    --s3-bucket-name your-log-bucket \
    --include-global-service-events
```

### **IAM Access Analyzer**

Use IAM Access Analyzer to identify unused permissions:

```bash
aws accessanalyzer create-analyzer \
    --analyzer-name avesha-agents-analyzer \
    --type ACCOUNT
```

## References

- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [IAM Policy Examples](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_examples.html)
- [CloudWatch Permissions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/permissions-reference-cw.html)
- [EC2 API Permissions](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/ec2-api-permissions.html)

---

**Note**: This document should be reviewed and updated as the Avesha Agents platform evolves and new AWS permission requirements are identified.
