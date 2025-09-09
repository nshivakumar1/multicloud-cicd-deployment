# terraform/variables.tf

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "cloud_provider" {
  description = "Cloud provider to deploy to (aws, azure, both)"
  type        = string
  default     = "both"
  
  validation {
    condition     = contains(["aws", "azure", "both"], var.cloud_provider)
    error_message = "Cloud provider must be aws, azure, or both."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "multicloud-app"
}

variable "region" {
  description = "Default region for resources"
  type        = string
  default     = "us-east-1"
}

variable "azure_location" {
  description = "Azure location for resources"
  type        = string
  default     = "East US"
}

variable "instance_type" {
  description = "Instance type for compute resources"
  type        = string
  default     = "t2.micro"  # AWS free tier
}

variable "vm_size" {
  description = "VM size for Azure resources"
  type        = string
  default     = "Standard_B1s"  # Azure free tier
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the application"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Allow from anywhere (restrict in production)
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "app_port" {
  description = "Port the application runs on"
  type        = number
  default     = 3000
}

variable "tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Project     = "multicloud-cicd"
    ManagedBy   = "terraform"
    Environment = "dev"
  }
}