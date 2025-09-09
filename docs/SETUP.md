# Detailed Setup Guide

## Prerequisites

### System Requirements
- macOS, Linux, or Windows with WSL2
- 4GB+ RAM, 20GB+ disk space
- Internet connection

### Required Accounts
- **AWS Account**: https://aws.amazon.com/free/
- **Azure Account**: https://azure.microsoft.com/free/
- **GitHub Account**: https://github.com/

## Step 1: Cloud Account Setup

### AWS Setup
```bash
# Install AWS CLI (if not installed)
# macOS: brew install awscli
# Linux: curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Configure AWS
aws configure
# Enter: Access Key ID, Secret Access Key, Region (us-east-1), Output format (json)
```

### Azure Setup
```bash
# Install Azure CLI (if not installed)
# macOS: brew install azure-cli
# Linux: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login
# Follow browser authentication
```

## Step 2: SSH Key Setup

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

## Step 3: Terraform Backend Setup

```bash
# Create S3 bucket for Terraform state
aws s3 mb s3://your-terraform-state-bucket-$(date +%s) --region us-east-1

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1

# Update backend.tf with your bucket name
```

## Step 4: Project Configuration

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values:
# - Replace "your-ip" with your actual IP address
# - Adjust regions if needed
# - Customize app_name if desired
```

## Step 5: Infrastructure Deployment

```bash
# Initialize Terraform
terraform init

# Plan deployment (review what will be created)
terraform plan

# Apply configuration (deploy infrastructure)
terraform apply
```

## Step 6: Jenkins Setup

```bash
# Run Jenkins setup script
./scripts/setup-jenkins.sh

# Access Jenkins web interface
# - macOS: http://localhost:8080
# - Linux: http://localhost:8080

# Get initial admin password:
# - macOS: cat /opt/homebrew/var/lib/jenkins/secrets/initialAdminPassword
# - Linux: sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

## Step 7: Verification

```bash
# Check Terraform outputs
terraform output

# Test AWS instance
AWS_IP=$(terraform output -raw aws_instance_ip)
curl http://$AWS_IP/health

# Test Azure instance  
AZURE_IP=$(terraform output -raw azure_vm_ip)
curl http://$AZURE_IP/health

# Test local development
make dev
curl http://localhost/health
```

## Troubleshooting

See TROUBLESHOOTING.md for common issues and solutions.
