output "aws_instance_id" {
  description = "ID of the AWS EC2 instance"
  value       = aws_instance.app.id
}

output "aws_instance_ip" {
  description = "Public IP address of AWS EC2 instance"
  value       = aws_instance.app.public_ip
}

output "aws_instance_dns" {
  description = "Public DNS name of AWS EC2 instance"
  value       = aws_instance.app.public_dns
}

output "aws_s3_bucket" {
  description = "Name of the AWS S3 bucket"
  value       = aws_s3_bucket.app.bucket
}

output "azure_vm_ip" {
  description = "Public IP address of Azure VM"
  value       = azurerm_public_ip.main.ip_address
}

output "azure_resource_group" {
  description = "Name of the Azure resource group"
  value       = azurerm_resource_group.main.name
}

output "azure_storage_account" {
  description = "Name of the Azure storage account"
  value       = azurerm_storage_account.main.name
}
