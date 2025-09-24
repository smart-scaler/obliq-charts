# AWS IAM Policies and Roles Guide

This document provides comprehensive IAM resource provisioning for the Obliq SRE Agent platform with three authentication methods and three deployment approaches.

## 📋 Table of Contents

### **1. Core Resources**
- [**Complete IAM Policy**](#complete-iam-policy-ready-to-copy) - Ready-to-copy comprehensive policy
- [**Permission Breakdown**](#permission-breakdown) - Detailed permission explanations
- [**Implementation**](#implementation) - Basic implementation steps

### **2. Authentication Methods**

#### **🔑 Access Keys (Programmatic Access)**
- [**CLI Method**](#approach-a-aws-cli-method) - Command-line provisioning
- [**Console Method**](#approach-b-aws-console-method) - Web interface provisioning
- [**CloudFormation Method**](#approach-c-cloudformation-method) - Infrastructure as code

#### **🖥️ IAM Roles (EC2 Instance Access)**
- [**CLI Method**](#approach-a-aws-cli-method-1) - Command-line role creation
- [**Console Method**](#approach-b-aws-console-method-1) - Web interface role setup
- [**CloudFormation Method**](#approach-c-cloudformation-method-1) - Automated role deployment

#### **☸️ EKS IRSA (Kubernetes Service Account Access)**
- [**CLI Method**](#approach-a-aws-cli-method-2) - Command-line IRSA setup
- [**Console Method**](#approach-b-aws-console-method-2) - Web interface IRSA configuration
- [**CloudFormation Method**](#approach-c-cloudformation-method-2) - Automated IRSA deployment

### **3. Support & Reference**

#### **🛠️ Implementation Support**
- [**Security Best Practices**](#security-best-practices) - Security guidelines and recommendations
- [**Troubleshooting**](#troubleshooting) - Common issues and debugging
- [**Monitoring and Auditing**](#monitoring-and-auditing) - Audit and monitoring setup

#### **📚 Documentation**
- [**References**](#references) - External documentation links
- [**Overview**](#overview) - Platform requirements and permissions

### **4. Quick Start Guide**
1. [**Copy the IAM Policy**](#complete-iam-policy-ready-to-copy) - Get the comprehensive policy
2. [**Choose Authentication Method**](#authentication-methods) - Select access keys, IAM roles, or EKS IRSA
3. [**Select Deployment Approach**](#deployment-approaches) - Choose CLI, Console, or CloudFormation
4. [**Follow Implementation Steps**](#implementation) - Execute the provisioning commands
5. [**Review Security Guidelines**](#security-best-practices) - Ensure secure configuration

## Overview

The Obliq SRE Agent platform requires specific AWS IAM permissions to:
- Monitor EC2 instances and their status
- Collect CloudWatch metrics for monitoring and alerting
- Assume roles for cross-account access
- Manage AWS resources securely

## Complete IAM Policy (Ready to Copy)

**Copy this complete policy for immediate use:**

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
                "ec2:DescribeVolumes",
                "ec2:DescribeTags",
                "ec2:DescribeImages",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeRouteTables",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeNatGateways",
                "ec2:DescribeVpcEndpoints",
                "ec2:DescribeSnapshots",
                "ec2:DescribeVolumesModifications",
                "ec2:DescribeReservedInstances",
                "ec2:DescribeSpotInstances",
                "ec2:DescribeSpotPriceHistory",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTags",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribePolicies",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DescribeScheduledActions",
                "autoscaling:DescribeTags",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricData",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:DescribeAlarmHistory",
                "cloudwatch:GetDashboard",
                "cloudwatch:ListDashboards",
                "cloudwatch:GetInsightRuleReport",
                "cloudwatch:ListInsightRules",
                "cloudwatch:GetMetricWidgetImage",
                "cloudwatch:GetMetricStream",
                "cloudwatch:ListMetricStreams",
                "cloudwatch:DescribeAnomalyDetectors",
                "cloudwatch:ListAnomalyDetectors",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:GetLogEvents",
                "logs:FilterLogEvents",
                "logs:StartQuery",
                "logs:StopQuery",
                "logs:GetQueryResults",
                "logs:DescribeQueries",
                "logs:DescribeResourcePolicies",
                "logs:DescribeDestinations",
                "logs:DescribeExportTasks",
                "logs:DescribeMetricFilters",
                "logs:DescribeSubscriptionFilters",
                "logs:ListTagsLogGroup",
                "sts:AssumeRoleWithWebIdentity",
                "sts:GetCallerIdentity",
                "iam:ListRoles",
                "iam:GetRole",
                "iam:PassRole"
            ],
            "Resource": "*"
        }
    ]
}
```

## Permission Breakdown

The comprehensive policy above includes all necessary permissions for:

### **EC2 Permissions**
- **Instance Management**: DescribeInstances, DescribeRegions, DescribeAccountAttributes
- **Networking**: DescribeVpcs, DescribeSubnets, DescribeSecurityGroups, DescribeRouteTables, DescribeInternetGateways, DescribeNatGateways, DescribeVpcEndpoints
- **Storage**: DescribeVolumes, DescribeSnapshots, DescribeVolumesModifications
- **Images & Types**: DescribeImages, DescribeInstanceTypes, DescribeKeyPairs
- **Advanced Features**: DescribeAvailabilityZones, DescribeNetworkAcls, DescribeReservedInstances, DescribeSpotInstances, DescribeSpotPriceHistory
- **Tagging**: DescribeTags

### **Load Balancing & Auto Scaling**
- **ELB**: DescribeLoadBalancers, DescribeTargetGroups, DescribeTargetHealth, DescribeListeners, DescribeRules, DescribeTags
- **Auto Scaling**: DescribeAutoScalingGroups, DescribeLaunchConfigurations, DescribePolicies, DescribeScalingActivities, DescribeScheduledActions, DescribeTags

### **CloudWatch Permissions**
- **Metrics**: GetMetricStatistics, ListMetrics, GetMetricData
- **Alarms**: DescribeAlarms, DescribeAlarmHistory
- **Dashboards**: GetDashboard, ListDashboards
- **Advanced Features**: GetInsightRuleReport, ListInsightRules, GetMetricWidgetImage, GetMetricStream, ListMetricStreams, DescribeAnomalyDetectors, ListAnomalyDetectors

### **CloudWatch Logs Permissions**
- **Basic Logs**: DescribeLogGroups, DescribeLogStreams, GetLogEvents, FilterLogEvents
- **Log Insights**: StartQuery, StopQuery, GetQueryResults, DescribeQueries
- **Advanced Features**: DescribeResourcePolicies, DescribeDestinations, DescribeExportTasks, DescribeMetricFilters, DescribeSubscriptionFilters, ListTagsLogGroup

### **Security & Identity**
- **STS**: AssumeRoleWithWebIdentity, GetCallerIdentity
- **IAM**: ListRoles, GetRole, PassRole

## Implementation

Save the comprehensive policy above to a file (e.g., `obliq-sre-agents-policy.json`) and create it:

```bash
# Create the policy
aws iam create-policy \
    --policy-name ObliqSREAgentsComprehensive \
    --policy-document file://obliq-sre-agents-policy.json

# Attach to role
aws iam attach-role-policy \
    --role-name your-role-name \
    --policy-arn arn:aws:iam::ACCOUNT-ID:policy/ObliqSREAgentsComprehensive
```

## Access Methods

### **1. Access Keys (Programmatic Access)**

For applications, scripts, and CLI tools that need programmatic access:

#### **Approach A: AWS CLI Method**

**Prerequisites**: Ensure you have AWS CLI installed and configured with admin permissions.

**Step 1: Create IAM User**
```bash
# Create IAM user
aws iam create-user --user-name obliq-sre-agents-user

# Verify user creation
aws iam get-user --user-name obliq-sre-agents-user
```

**Step 2: Attach Policy**
```bash
# First, get your account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Account ID: $ACCOUNT_ID"

# Attach the comprehensive policy to the user
aws iam attach-user-policy \
    --user-name obliq-sre-agents-user \
    --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/ObliqSREAgentsComprehensive

# Verify policy attachment
aws iam list-attached-user-policies --user-name obliq-sre-agents-user
```

**Step 3: Generate Access Keys**
```bash
# Create access keys and save output
aws iam create-access-key --user-name obliq-sre-agents-user > access-keys.json

# Extract and display credentials (SAVE THESE SECURELY!)
echo "=== ACCESS KEYS GENERATED ==="
echo "Access Key ID:"
cat access-keys.json | jq -r '.AccessKey.AccessKeyId'
echo "Secret Access Key:"
cat access-keys.json | jq -r '.AccessKey.SecretAccessKey'
echo "============================="
echo "IMPORTANT: Save these credentials securely!"
```

**Step 4: Configure Credentials**
```bash
# Method 1: Configure AWS CLI
aws configure
# When prompted, enter:
# - AWS Access Key ID: [paste from above]
# - AWS Secret Access Key: [paste from above]
# - Default region name: us-east-1
# - Default output format: json

# Method 2: Set environment variables
export AWS_ACCESS_KEY_ID=$(cat access-keys.json | jq -r '.AccessKey.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(cat access-keys.json | jq -r '.AccessKey.SecretAccessKey')
export AWS_DEFAULT_REGION="us-east-1"

# Verify configuration
aws sts get-caller-identity
```

#### **Approach B: AWS Console Method**

**Prerequisites**: Access to AWS Console with IAM permissions.

**Step 1: Navigate to IAM Console**
1. Open your web browser and go to [AWS IAM Console](https://console.aws.amazon.com/iam/)
2. Sign in with your AWS account credentials
3. In the left navigation panel, click **"Users"**
4. Click the **"Create user"** button (blue button in top-right)

**Step 2: Create User**
1. In the "User name" field, enter: `obliq-sre-agents-user`
2. Under "Select AWS access type", check **"Programmatic access"**
3. Click **"Next: Permissions"**

**Step 3: Attach Policy**
1. Select **"Attach policies directly"**
2. In the search box, type: `ObliqSREAgentsComprehensive`
3. Check the checkbox next to the policy (it should show "ObliqSREAgentsComprehensive")
4. Click **"Next: Tags"** (you can skip this step)
5. Click **"Next: Review"**
6. Review the settings:
   - User name: obliq-sre-agents-user
   - Access type: Programmatic access
   - Permissions: ObliqSREAgentsComprehensive
7. Click **"Create user"**

**Step 4: Generate Access Keys**
1. **CRITICAL**: You will see a success page with access credentials
2. **Copy the Access Key ID** (starts with AKIA...)
3. **Copy the Secret Access Key** (long random string)
4. **Download the CSV file** by clicking "Download .csv" button
5. **Save these credentials securely** - you cannot retrieve the secret key later
6. Click **"Close"**

**Step 5: Verify Configuration**
```bash
# Verify the configuration
aws sts get-caller-identity
```


#### **Approach C: CloudFormation Method**

**Prerequisites**: AWS CLI installed and configured with CloudFormation permissions.

**Step 1: Create CloudFormation Template**
```bash
# Create the CloudFormation template file
cat > obliq-sre-user-template.yaml << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Obliq SRE Agent IAM User with Access Keys'

Resources:
  ObliqSREAgentsUser:
    Type: AWS::IAM::User
    Properties:
      UserName: obliq-sre-agents-user
      Policies:
        - PolicyName: ObliqSREAgentsPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - ec2:DescribeInstances
                  - ec2:DescribeRegions
                  - ec2:DescribeAccountAttributes
                  - ec2:DescribeSecurityGroups
                  - ec2:DescribeVpcs
                  - ec2:DescribeSubnets
                  - ec2:DescribeVolumes
                  - ec2:DescribeTags
                  - ec2:DescribeImages
                  - ec2:DescribeInstanceTypes
                  - ec2:DescribeAvailabilityZones
                  - ec2:DescribeKeyPairs
                  - ec2:DescribeNetworkAcls
                  - ec2:DescribeRouteTables
                  - ec2:DescribeInternetGateways
                  - ec2:DescribeNatGateways
                  - ec2:DescribeVpcEndpoints
                  - ec2:DescribeSnapshots
                  - ec2:DescribeVolumesModifications
                  - ec2:DescribeReservedInstances
                  - ec2:DescribeSpotInstances
                  - ec2:DescribeSpotPriceHistory
                  - elasticloadbalancing:DescribeLoadBalancers
                  - elasticloadbalancing:DescribeTargetGroups
                  - elasticloadbalancing:DescribeTargetHealth
                  - elasticloadbalancing:DescribeListeners
                  - elasticloadbalancing:DescribeRules
                  - elasticloadbalancing:DescribeTags
                  - autoscaling:DescribeAutoScalingGroups
                  - autoscaling:DescribeLaunchConfigurations
                  - autoscaling:DescribePolicies
                  - autoscaling:DescribeScalingActivities
                  - autoscaling:DescribeScheduledActions
                  - autoscaling:DescribeTags
                  - cloudwatch:GetMetricStatistics
                  - cloudwatch:ListMetrics
                  - cloudwatch:GetMetricData
                  - cloudwatch:DescribeAlarms
                  - cloudwatch:DescribeAlarmHistory
                  - cloudwatch:GetDashboard
                  - cloudwatch:ListDashboards
                  - cloudwatch:GetInsightRuleReport
                  - cloudwatch:ListInsightRules
                  - cloudwatch:GetMetricWidgetImage
                  - cloudwatch:GetMetricStream
                  - cloudwatch:ListMetricStreams
                  - cloudwatch:DescribeAnomalyDetectors
                  - cloudwatch:ListAnomalyDetectors
                  - logs:DescribeLogGroups
                  - logs:DescribeLogStreams
                  - logs:GetLogEvents
                  - logs:FilterLogEvents
                  - logs:StartQuery
                  - logs:StopQuery
                  - logs:GetQueryResults
                  - logs:DescribeQueries
                  - logs:DescribeResourcePolicies
                  - logs:DescribeDestinations
                  - logs:DescribeExportTasks
                  - logs:DescribeMetricFilters
                  - logs:DescribeSubscriptionFilters
                  - logs:ListTagsLogGroup
                  - sts:AssumeRoleWithWebIdentity
                  - sts:GetCallerIdentity
                  - iam:ListRoles
                  - iam:GetRole
                  - iam:PassRole
                Resource: '*'

  ObliqSREAgentsAccessKey:
    Type: AWS::IAM::AccessKey
    Properties:
      UserName: !Ref ObliqSREAgentsUser

Outputs:
  AccessKeyId:
    Description: 'Access Key ID'
    Value: !Ref ObliqSREAgentsAccessKey
    Export:
      Name: !Sub '${AWS::StackName}-AccessKeyId'
  
  SecretAccessKey:
    Description: 'Secret Access Key'
    Value: !GetAtt ObliqSREAgentsAccessKey.SecretAccessKey
    Export:
      Name: !Sub '${AWS::StackName}-SecretAccessKey'
EOF

# Verify the template was created
echo "Template created successfully:"
ls -la obliq-sre-user-template.yaml
```

**Step 2: Deploy CloudFormation Stack**
```bash
# Deploy the stack
aws cloudformation create-stack \
    --stack-name obliq-sre-agents-user \
    --template-body file://obliq-sre-user-template.yaml \
    --capabilities CAPABILITY_IAM

# Wait for stack creation to complete
echo "Waiting for stack creation to complete..."
aws cloudformation wait stack-create-complete --stack-name obliq-sre-agents-user

# Check stack status
aws cloudformation describe-stacks \
    --stack-name obliq-sre-agents-user \
    --query 'Stacks[0].StackStatus' \
    --output text
```

**Step 3: Get Access Keys**
```bash
# Get Access Key ID
ACCESS_KEY_ID=$(aws cloudformation describe-stacks \
    --stack-name obliq-sre-agents-user \
    --query 'Stacks[0].Outputs[?OutputKey==`AccessKeyId`].OutputValue' \
    --output text)

# Get Secret Access Key
SECRET_ACCESS_KEY=$(aws cloudformation describe-stacks \
    --stack-name obliq-sre-agents-user \
    --query 'Stacks[0].Outputs[?OutputKey==`SecretAccessKey`].OutputValue' \
    --output text)

# Display credentials (SAVE THESE SECURELY!)
echo "=== ACCESS KEYS GENERATED ==="
echo "Access Key ID: $ACCESS_KEY_ID"
echo "Secret Access Key: $SECRET_ACCESS_KEY"
echo "============================="
echo "IMPORTANT: Save these credentials securely!"

# Save to file for easy access
cat > access-keys.txt << EOF
Access Key ID: $ACCESS_KEY_ID
Secret Access Key: $SECRET_ACCESS_KEY
EOF
echo "Credentials saved to access-keys.txt"
```

**Step 4: Configure Credentials**
```bash
# Method 1: Configure AWS CLI
aws configure
# When prompted, enter:
# - AWS Access Key ID: [paste the Access Key ID from above]
# - AWS Secret Access Key: [paste the Secret Access Key from above]
# - Default region name: us-east-1
# - Default output format: json

# Method 2: Set environment variables
export AWS_ACCESS_KEY_ID="$ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"

# Verify configuration
aws sts get-caller-identity
```

**Step 5: Cleanup (Optional)**
```bash
# To delete the CloudFormation stack and user (if needed)
# aws cloudformation delete-stack --stack-name obliq-sre-agents-user
```


**Use Case**: Perfect for applications, CI/CD pipelines, and automated scripts that need direct AWS API access.

### **2. IAM Roles (EC2 Instance Access)**

For EC2 instances that need to assume roles automatically:

#### **Approach A: AWS CLI Method**

**Prerequisites**: AWS CLI installed and configured with IAM permissions.

**Step 1: Create IAM Role**
```bash
# Create IAM role for EC2 instances
aws iam create-role \
    --role-name obliq-sre-agents-ec2-role \
    --assume-role-policy-document '{
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
    }'

# Verify role creation
aws iam get-role --role-name obliq-sre-agents-ec2-role
```

**Step 2: Attach Policy**
```bash
# Get account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Account ID: $ACCOUNT_ID"

# Attach the comprehensive policy to the role
aws iam attach-role-policy \
    --role-name obliq-sre-agents-ec2-role \
    --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/ObliqSREAgentsComprehensive

# Verify policy attachment
aws iam list-attached-role-policies --role-name obliq-sre-agents-ec2-role
```

**Step 3: Create Instance Profile**
```bash
# Create instance profile
aws iam create-instance-profile \
    --instance-profile-name obliq-sre-agents-instance-profile

# Add role to instance profile
aws iam add-role-to-instance-profile \
    --instance-profile-name obliq-sre-agents-instance-profile \
    --role-name obliq-sre-agents-ec2-role

# Verify instance profile
aws iam get-instance-profile --instance-profile-name obliq-sre-agents-instance-profile
```

**Step 4: Verify IAM Resources**
```bash
# Verify role creation
aws iam get-role --role-name obliq-sre-agents-ec2-role

# Verify instance profile
aws iam get-instance-profile --instance-profile-name obliq-sre-agents-instance-profile

# Verify policy attachment
aws iam list-attached-role-policies --role-name obliq-sre-agents-ec2-role

# Get role ARN for reference
ROLE_ARN=$(aws iam get-role --role-name obliq-sre-agents-ec2-role --query 'Role.Arn' --output text)
echo "Role ARN: $ROLE_ARN"
```

#### **Approach B: AWS Console Method**

**Prerequisites**: Access to AWS Console with IAM permissions.

**Step 1: Create IAM Role**
1. Go to [AWS IAM Console](https://console.aws.amazon.com/iam/)
2. Click **"Roles"** in the left navigation
3. Click **"Create role"**
4. Select **"AWS service"** → **"EC2"**
5. Click **"Next: Permissions"**

**Step 2: Attach Policy**
1. Search for **"ObliqSREAgentsComprehensive"**
2. Check the checkbox next to the policy
3. Click **"Next: Tags"** (optional)
4. Click **"Next: Review"**
5. Enter role name: `obliq-sre-agents-ec2-role`
6. Click **"Create role"**

**Step 3: Create Instance Profile**
1. In the IAM Console, click **"Instance profiles"** in the left navigation
2. Click **"Create instance profile"**
3. Enter name: `obliq-sre-agents-instance-profile`
4. Click **"Create instance profile"**
5. Click on the created instance profile
6. Go to **"Attached roles"** tab
7. Click **"Attach role"**
8. Select **"obliq-sre-agents-ec2-role"**
9. Click **"Attach role"**

**Step 4: Verify Trust Policy**
1. Go back to **"Roles"** in the IAM Console
2. Click on **"obliq-sre-agents-ec2-role"**
3. Go to **"Trust relationships"** tab
4. Verify the trust policy shows:
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

**Step 5: Get Role ARN**
1. In the role details, copy the **"ARN"** value
2. This ARN can be used when launching EC2 instances with this role

#### **Approach C: CloudFormation Method**

**Prerequisites**: AWS CLI installed and configured with CloudFormation permissions.

**Step 1: Create CloudFormation Template**
```bash
# Create the CloudFormation template file
cat > obliq-sre-ec2-role-template.yaml << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Obliq SRE Agent EC2 IAM Role and Instance Profile'

Resources:
  ObliqSREAgentsRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: obliq-sre-agents-ec2-role
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: ec2.amazonaws.com
            Action: sts:AssumeRole
      Policies:
        - PolicyName: ObliqSREAgentsPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - ec2:DescribeInstances
                  - ec2:DescribeRegions
                  - ec2:DescribeAccountAttributes
                  - ec2:DescribeSecurityGroups
                  - ec2:DescribeVpcs
                  - ec2:DescribeSubnets
                  - ec2:DescribeVolumes
                  - ec2:DescribeTags
                  - ec2:DescribeImages
                  - ec2:DescribeInstanceTypes
                  - ec2:DescribeAvailabilityZones
                  - ec2:DescribeKeyPairs
                  - ec2:DescribeNetworkAcls
                  - ec2:DescribeRouteTables
                  - ec2:DescribeInternetGateways
                  - ec2:DescribeNatGateways
                  - ec2:DescribeVpcEndpoints
                  - ec2:DescribeSnapshots
                  - ec2:DescribeVolumesModifications
                  - ec2:DescribeReservedInstances
                  - ec2:DescribeSpotInstances
                  - ec2:DescribeSpotPriceHistory
                  - elasticloadbalancing:DescribeLoadBalancers
                  - elasticloadbalancing:DescribeTargetGroups
                  - elasticloadbalancing:DescribeTargetHealth
                  - elasticloadbalancing:DescribeListeners
                  - elasticloadbalancing:DescribeRules
                  - elasticloadbalancing:DescribeTags
                  - autoscaling:DescribeAutoScalingGroups
                  - autoscaling:DescribeLaunchConfigurations
                  - autoscaling:DescribePolicies
                  - autoscaling:DescribeScalingActivities
                  - autoscaling:DescribeScheduledActions
                  - autoscaling:DescribeTags
                  - cloudwatch:GetMetricStatistics
                  - cloudwatch:ListMetrics
                  - cloudwatch:GetMetricData
                  - cloudwatch:DescribeAlarms
                  - cloudwatch:DescribeAlarmHistory
                  - cloudwatch:GetDashboard
                  - cloudwatch:ListDashboards
                  - cloudwatch:GetInsightRuleReport
                  - cloudwatch:ListInsightRules
                  - cloudwatch:GetMetricWidgetImage
                  - cloudwatch:GetMetricStream
                  - cloudwatch:ListMetricStreams
                  - cloudwatch:DescribeAnomalyDetectors
                  - cloudwatch:ListAnomalyDetectors
                  - logs:DescribeLogGroups
                  - logs:DescribeLogStreams
                  - logs:GetLogEvents
                  - logs:FilterLogEvents
                  - logs:StartQuery
                  - logs:StopQuery
                  - logs:GetQueryResults
                  - logs:DescribeQueries
                  - logs:DescribeResourcePolicies
                  - logs:DescribeDestinations
                  - logs:DescribeExportTasks
                  - logs:DescribeMetricFilters
                  - logs:DescribeSubscriptionFilters
                  - logs:ListTagsLogGroup
                  - sts:AssumeRoleWithWebIdentity
                  - sts:GetCallerIdentity
                  - iam:ListRoles
                  - iam:GetRole
                  - iam:PassRole
                Resource: '*'

  ObliqSREAgentsInstanceProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      InstanceProfileName: obliq-sre-agents-instance-profile
      Roles:
        - !Ref ObliqSREAgentsRole

Outputs:
  RoleArn:
    Description: 'IAM Role ARN'
    Value: !GetAtt ObliqSREAgentsRole.Arn
    Export:
      Name: !Sub '${AWS::StackName}-RoleArn'
  
  InstanceProfileName:
    Description: 'Instance Profile Name'
    Value: !Ref ObliqSREAgentsInstanceProfile
    Export:
      Name: !Sub '${AWS::StackName}-InstanceProfileName'
EOF

# Verify the template was created
echo "Template created successfully:"
ls -la obliq-sre-ec2-role-template.yaml
```

**Step 2: Deploy CloudFormation Stack**
```bash
# Deploy the stack
aws cloudformation create-stack \
    --stack-name obliq-sre-agents-ec2-iam \
    --template-body file://obliq-sre-ec2-role-template.yaml \
    --capabilities CAPABILITY_IAM

# Wait for stack creation to complete
echo "Waiting for stack creation to complete..."
aws cloudformation wait stack-create-complete --stack-name obliq-sre-agents-ec2-iam

# Check stack status
aws cloudformation describe-stacks \
    --stack-name obliq-sre-agents-ec2-iam \
    --query 'Stacks[0].StackStatus' \
    --output text
```

**Step 3: Get IAM Resources**
```bash
# Get role ARN
ROLE_ARN=$(aws cloudformation describe-stacks \
    --stack-name obliq-sre-agents-ec2-iam \
    --query 'Stacks[0].Outputs[?OutputKey==`RoleArn`].OutputValue' \
    --output text)

# Get instance profile name
INSTANCE_PROFILE_NAME=$(aws cloudformation describe-stacks \
    --stack-name obliq-sre-agents-ec2-iam \
    --query 'Stacks[0].Outputs[?OutputKey==`InstanceProfileName`].OutputValue' \
    --output text)

echo "Role ARN: $ROLE_ARN"
echo "Instance Profile Name: $INSTANCE_PROFILE_NAME"
```

**Step 4: Verify IAM Resources**
```bash
# Verify role creation
aws iam get-role --role-name obliq-sre-agents-ec2-role

# Verify instance profile
aws iam get-instance-profile --instance-profile-name obliq-sre-agents-instance-profile

# Verify policy attachment
aws iam list-attached-role-policies --role-name obliq-sre-agents-ec2-role
```

**Use Case**: Perfect for EC2 instances running Obliq SRE agents that need automatic AWS access without storing credentials.

### **3. EKS POD IRSA (Kubernetes Service Account Access)**

For Kubernetes deployments using IAM Roles for Service Accounts (IRSA):

#### **Approach A: AWS CLI Method**

**Prerequisites**: AWS CLI installed, EKS cluster with OIDC provider configured, kubectl configured.

**Step 1: Get EKS Cluster Information**
```bash
# Get cluster information
CLUSTER_NAME="your-eks-cluster"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Get OIDC provider ID
OIDC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION \
    --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

echo "Account ID: $ACCOUNT_ID"
echo "OIDC ID: $OIDC_ID"
```

**Step 2: Create IAM Role for Obliq SRE Agent**
```bash
# Create trust policy for Obliq SRE Agent
cat > obliq-sre-trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/oidc.eks.${REGION}.amazonaws.com/id/${OIDC_ID}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.${REGION}.amazonaws.com/id/${OIDC_ID}:aud": "sts.amazonaws.com",
                    "oidc.eks.${REGION}.amazonaws.com/id/${OIDC_ID}:sub": "system:serviceaccount:avesha:obliq-sre-agent"
                }
            }
        }
    ]
}
EOF

# Create IAM role for Obliq SRE Agent
aws iam create-role \
    --role-name obliq-sre-agents-role \
    --assume-role-policy-document file://obliq-sre-trust-policy.json

# Attach comprehensive policy
aws iam attach-role-policy \
    --role-name obliq-sre-agents-role \
    --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/ObliqSREAgentsComprehensive
```

**Step 3: Create Kubernetes Service Accounts**
```bash
# Create namespace if it doesn't exist
kubectl create namespace avesha --dry-run=client -o yaml | kubectl apply -f -

# Create service account for Obliq SRE Agent
kubectl create serviceaccount obliq-sre-agent -n avesha

# Annotate service account with IAM role ARN
kubectl annotate serviceaccount obliq-sre-agent -n avesha \
    eks.amazonaws.com/role-arn=arn:aws:iam::${ACCOUNT_ID}:role/obliq-sre-agents-role
```


**Use Case**: Perfect for Kubernetes pods running Obliq SRE agents that need automatic AWS access without storing credentials.

#### **Approach B: AWS Console Method**

**Prerequisites**: Access to AWS Console with IAM permissions, EKS cluster with OIDC provider configured, kubectl configured.

**Step 1: Create IAM Role**
1. Go to [AWS IAM Console](https://console.aws.amazon.com/iam/)
2. Click **"Roles"** → **"Create role"**
3. Select **"Web identity"**
4. Choose **"OpenID Connect provider"** → Select your EKS OIDC provider
5. Audience: `sts.amazonaws.com`
6. Click **"Next"**

**Step 2: Attach Policy**
1. Search for **"ObliqSREAgentsComprehensive"**
2. Check the checkbox next to the policy
3. Click **"Next: Tags"** (optional)
4. Click **"Next: Review"**
5. Enter role name: `obliq-sre-agents-role`
6. Click **"Create role"**

**Step 3: Update Trust Policy**
1. Click on the created role
2. Go to **"Trust relationships"** tab
3. Click **"Edit trust policy"**
4. Replace the condition with:
```json
{
    "StringEquals": {
        "oidc.eks.${REGION}.amazonaws.com/id/${OIDC_ID}:aud": "sts.amazonaws.com",
        "oidc.eks.${REGION}.amazonaws.com/id/${OIDC_ID}:sub": "system:serviceaccount:avesha:obliq-sre-agent"
    }
}
```
5. Click **"Update policy"**

**Step 4: Create Kubernetes Resources**
```bash
# Create namespace if it doesn't exist
kubectl create namespace avesha --dry-run=client -o yaml | kubectl apply -f -

# Create service account
kubectl create serviceaccount obliq-sre-agent -n avesha

# Annotate service account with IAM role ARN
kubectl annotate serviceaccount obliq-sre-agent -n avesha \
    eks.amazonaws.com/role-arn=arn:aws:iam::${ACCOUNT_ID}:role/obliq-sre-agents-role
```

#### **Approach C: CloudFormation Method**

**Prerequisites**: AWS CLI installed, EKS cluster with OIDC provider configured, kubectl configured.

**Step 1: Create CloudFormation Template**
```bash
# Create the CloudFormation template file
cat > obliq-sre-irsa-template.yaml << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Obliq SRE Agent EKS IRSA IAM Role'

Parameters:
  OIDCProviderUrl:
    Type: String
    Description: 'OIDC Provider URL for EKS cluster'
    Default: 'oidc.eks.REGION.amazonaws.com/id/OIDC_ID'
  
  OIDCProviderArn:
    Type: String
    Description: 'OIDC Provider ARN for EKS cluster'
    Default: 'arn:aws:iam::ACCOUNT_ID:oidc-provider/oidc.eks.REGION.amazonaws.com/id/OIDC_ID'

Resources:
  ObliqSREAgentsRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: obliq-sre-agents-role
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Federated: !Ref OIDCProviderArn
            Action: sts:AssumeRoleWithWebIdentity
            Condition:
              StringEquals:
                !Sub '${OIDCProviderUrl}:aud': 'sts.amazonaws.com'
                !Sub '${OIDCProviderUrl}:sub': 'system:serviceaccount:avesha:obliq-sre-agent'
      Policies:
        - PolicyName: ObliqSREAgentsPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - ec2:DescribeInstances
                  - ec2:DescribeRegions
                  - ec2:DescribeAccountAttributes
                  - ec2:DescribeSecurityGroups
                  - ec2:DescribeVpcs
                  - ec2:DescribeSubnets
                  - ec2:DescribeVolumes
                  - ec2:DescribeTags
                  - ec2:DescribeImages
                  - ec2:DescribeInstanceTypes
                  - ec2:DescribeAvailabilityZones
                  - ec2:DescribeKeyPairs
                  - ec2:DescribeNetworkAcls
                  - ec2:DescribeRouteTables
                  - ec2:DescribeInternetGateways
                  - ec2:DescribeNatGateways
                  - ec2:DescribeVpcEndpoints
                  - ec2:DescribeSnapshots
                  - ec2:DescribeVolumesModifications
                  - ec2:DescribeReservedInstances
                  - ec2:DescribeSpotInstances
                  - ec2:DescribeSpotPriceHistory
                  - elasticloadbalancing:DescribeLoadBalancers
                  - elasticloadbalancing:DescribeTargetGroups
                  - elasticloadbalancing:DescribeTargetHealth
                  - elasticloadbalancing:DescribeListeners
                  - elasticloadbalancing:DescribeRules
                  - elasticloadbalancing:DescribeTags
                  - autoscaling:DescribeAutoScalingGroups
                  - autoscaling:DescribeLaunchConfigurations
                  - autoscaling:DescribePolicies
                  - autoscaling:DescribeScalingActivities
                  - autoscaling:DescribeScheduledActions
                  - autoscaling:DescribeTags
                  - cloudwatch:GetMetricStatistics
                  - cloudwatch:ListMetrics
                  - cloudwatch:GetMetricData
                  - cloudwatch:DescribeAlarms
                  - cloudwatch:DescribeAlarmHistory
                  - cloudwatch:GetDashboard
                  - cloudwatch:ListDashboards
                  - cloudwatch:GetInsightRuleReport
                  - cloudwatch:ListInsightRules
                  - cloudwatch:GetMetricWidgetImage
                  - cloudwatch:GetMetricStream
                  - cloudwatch:ListMetricStreams
                  - cloudwatch:DescribeAnomalyDetectors
                  - cloudwatch:ListAnomalyDetectors
                  - logs:DescribeLogGroups
                  - logs:DescribeLogStreams
                  - logs:GetLogEvents
                  - logs:FilterLogEvents
                  - logs:StartQuery
                  - logs:StopQuery
                  - logs:GetQueryResults
                  - logs:DescribeQueries
                  - logs:DescribeResourcePolicies
                  - logs:DescribeDestinations
                  - logs:DescribeExportTasks
                  - logs:DescribeMetricFilters
                  - logs:DescribeSubscriptionFilters
                  - logs:ListTagsLogGroup
                  - sts:AssumeRoleWithWebIdentity
                  - sts:GetCallerIdentity
                  - iam:ListRoles
                  - iam:GetRole
                  - iam:PassRole
                Resource: '*'

Outputs:
  RoleArn:
    Description: 'IAM Role ARN'
    Value: !GetAtt ObliqSREAgentsRole.Arn
    Export:
      Name: !Sub '${AWS::StackName}-RoleArn'
EOF

# Verify the template was created
ls -la obliq-sre-irsa-template.yaml
```

**Step 2: Deploy CloudFormation Stack**
```bash
# Deploy the stack
aws cloudformation create-stack \
    --stack-name obliq-sre-agents-irsa \
    --template-body file://obliq-sre-irsa-template.yaml \
    --parameters ParameterKey=OIDCProviderUrl,ParameterValue=oidc.eks.${REGION}.amazonaws.com/id/${OIDC_ID} \
                 ParameterKey=OIDCProviderArn,ParameterValue=arn:aws:iam::${ACCOUNT_ID}:oidc-provider/oidc.eks.${REGION}.amazonaws.com/id/${OIDC_ID}

# Wait for stack creation
aws cloudformation wait stack-create-complete --stack-name obliq-sre-agents-irsa

# Get the role ARN
ROLE_ARN=$(aws cloudformation describe-stacks \
    --stack-name obliq-sre-agents-irsa \
    --query 'Stacks[0].Outputs[?OutputKey==`RoleArn`].OutputValue' \
    --output text)

echo "Role ARN: $ROLE_ARN"
```

**Step 3: Create Kubernetes Resources**
```bash
# Create namespace if it doesn't exist
kubectl create namespace avesha --dry-run=client -o yaml | kubectl apply -f -

# Create service account
kubectl create serviceaccount obliq-sre-agent -n avesha

# Annotate service account with IAM role ARN
kubectl annotate serviceaccount obliq-sre-agent -n avesha \
    eks.amazonaws.com/role-arn=$ROLE_ARN
```

## Security Best Practices

- **Principle of Least Privilege**: Only grant the minimum permissions necessary
- **Regular Audits**: Review and update permissions based on actual usage patterns
- **Resource Restrictions**: Consider limiting access to specific instances, regions, or accounts
- **Conditional Access**: Use IP restrictions, time-based access, or tag-based conditions when needed

## Troubleshooting

**Common Issues:**
- **"Access Denied" errors**: Check if the IAM policy is properly attached
- **Missing metrics**: Verify CloudWatch permissions are granted
- **Cross-account access**: Ensure proper role assumption permissions

**Debug Commands:**
```bash
# Check policy attachments
aws iam list-attached-role-policies --role-name your-role-name
```

**IAM Policy Simulator**: Use [AWS IAM Policy Simulator](https://policysim.aws.amazon.com/) to test permissions.

## Monitoring and Auditing

**CloudTrail**: Enable CloudTrail to monitor API calls and track IAM policy usage.

**IAM Access Analyzer**: Use IAM Access Analyzer to identify unused permissions and optimize your policy.

## References

- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [IAM Policy Examples](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_examples.html)
- [CloudWatch Permissions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/permissions-reference-cw.html)
- [EC2 API Permissions](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/ec2-api-permissions.html)

---

**Note**: This document should be reviewed and updated as the Obliq SRE Agent platform evolves and new AWS permission requirements are identified.
