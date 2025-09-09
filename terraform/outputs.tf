# terraform/outputs.tf

# AWS Outputs
output "aws_public_ip" {
  description = "Public IP of AWS EC2 instance"
  value       = local.deploy_aws ? aws_instance.web[0].public_ip : null
}

output "aws_instance_id" {
  description = "ID of AWS EC2 instance"
  value       = local.deploy_aws ? aws_instance.web[0].id : null
}

output "aws_public_dns" {
  description = "Public DNS of AWS EC2 instance"
  value       = local.deploy_aws ? aws_instance.web[0].public_dns : null
}

# Azure Outputs
output "azure_public_ip" {
  description = "Public IP of Azure VM"
  value       = local.deploy_azure ? azurerm_public_ip.main[0].ip_address : null
}

output "azure_vm_name" {
  description = "Name of Azure VM"
  value       = local.deploy_azure ? azurerm_linux_virtual_machine.main[0].name : null
}

output "azure_resource_group" {
  description = "Name of Azure Resource Group"
  value       = local.deploy_azure ? azurerm_resource_group.main[0].name : null
}

# Application URLs
output "application_urls" {
  description = "URLs to access the deployed applications"
  value = {
    aws   = local.deploy_aws ? "http://${aws_instance.web[0].public_ip}" : null
    azure = local.deploy_azure ? "http://${azurerm_public_ip.main[0].ip_address}" : null
  }
}

output "health_check_urls" {
  description = "Health check URLs for the deployed applications"
  value = {
    aws   = local.deploy_aws ? "http://${aws_instance.web[0].public_ip}/health" : null
    azure = local.deploy_azure ? "http://${azurerm_public_ip.main[0].ip_address}/health" : null
  }
}

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    environment     = var.environment
    cloud_provider  = var.cloud_provider
    aws_deployed    = local.deploy_aws
    azure_deployed  = local.deploy_azure
    project_name    = var.project_name
  }
}