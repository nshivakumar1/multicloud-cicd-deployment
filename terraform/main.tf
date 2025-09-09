# terraform/main.tf

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  
  # Backend configuration is in backend.tf - do not duplicate here
}

# Configure AWS Provider
provider "aws" {
  region = var.region
  
  default_tags {
    tags = merge(var.tags, {
      Environment = var.environment
    })
  }
}

# Configure Azure Provider
provider "azurerm" {
  features {}
}

# Random suffix for unique resource names
resource "random_id" "suffix" {
  byte_length = 4
}

# Local values for conditional deployment
locals {
  deploy_aws   = var.cloud_provider == "aws" || var.cloud_provider == "both"
  deploy_azure = var.cloud_provider == "azure" || var.cloud_provider == "both"
  
  common_tags = merge(var.tags, {
    Environment = var.environment
    Deployment  = var.cloud_provider
  })
}

# Data source for SSH public key
data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_public_key_path)
}

# ================================
# AWS Resources
# ================================

# AWS VPC
resource "aws_vpc" "main" {
  count = local.deploy_aws ? 1 : 0
  
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc-${var.environment}"
  })
}

# AWS Internet Gateway
resource "aws_internet_gateway" "main" {
  count = local.deploy_aws ? 1 : 0
  
  vpc_id = aws_vpc.main[0].id
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-igw-${var.environment}"
  })
}

# AWS Public Subnet
resource "aws_subnet" "public" {
  count = local.deploy_aws ? 1 : 0
  
  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available[0].names[0]
  map_public_ip_on_launch = true
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-subnet-${var.environment}"
  })
}

# AWS Availability Zones data
data "aws_availability_zones" "available" {
  count = local.deploy_aws ? 1 : 0
  state = "available"
}

# AWS Route Table
resource "aws_route_table" "public" {
  count = local.deploy_aws ? 1 : 0
  
  vpc_id = aws_vpc.main[0].id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-rt-${var.environment}"
  })
}

# AWS Route Table Association
resource "aws_route_table_association" "public" {
  count = local.deploy_aws ? 1 : 0
  
  subnet_id      = aws_subnet.public[0].id
  route_table_id = aws_route_table.public[0].id
}

# AWS Security Group
resource "aws_security_group" "web" {
  count = local.deploy_aws ? 1 : 0
  
  name        = "${var.project_name}-web-sg-${var.environment}"
  description = "Security group for web application"
  vpc_id      = aws_vpc.main[0].id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-web-sg-${var.environment}"
  })
}

# AWS Key Pair
resource "aws_key_pair" "main" {
  count = local.deploy_aws ? 1 : 0
  
  key_name   = "${var.project_name}-key-${var.environment}"
  public_key = data.local_file.ssh_public_key.content
  
  tags = local.common_tags
}

# AWS AMI data
data "aws_ami" "ubuntu" {
  count = local.deploy_aws ? 1 : 0
  
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# AWS EC2 Instance
resource "aws_instance" "web" {
  count = local.deploy_aws ? 1 : 0
  
  ami                    = data.aws_ami.ubuntu[0].id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.main[0].key_name
  vpc_security_group_ids = [aws_security_group.web[0].id]
  subnet_id              = aws_subnet.public[0].id
  
  user_data = base64encode(templatefile("${path.module}/scripts/user-data.sh", {
    app_port = var.app_port
  }))
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-web-${var.environment}"
  })
}

# ================================
# Azure Resources
# ================================

# Azure Resource Group
resource "azurerm_resource_group" "main" {
  count = local.deploy_azure ? 1 : 0
  
  name     = "${var.project_name}-rg-${var.environment}"
  location = var.azure_location
  
  tags = local.common_tags
}

# Azure Virtual Network
resource "azurerm_virtual_network" "main" {
  count = local.deploy_azure ? 1 : 0
  
  name                = "${var.project_name}-vnet-${var.environment}"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
  
  tags = local.common_tags
}

# Azure Subnet
resource "azurerm_subnet" "public" {
  count = local.deploy_azure ? 1 : 0
  
  name                 = "${var.project_name}-subnet-${var.environment}"
  resource_group_name  = azurerm_resource_group.main[0].name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = ["10.1.1.0/24"]
}

# Azure Public IP
resource "azurerm_public_ip" "main" {
  count = local.deploy_azure ? 1 : 0
  
  name                = "${var.project_name}-pip-${var.environment}"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = local.common_tags
}

# Azure Network Security Group
resource "azurerm_network_security_group" "main" {
  count = local.deploy_azure ? 1 : 0
  
  name                = "${var.project_name}-nsg-${var.environment}"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
  
  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  tags = local.common_tags
}

# Azure Network Interface
resource "azurerm_network_interface" "main" {
  count = local.deploy_azure ? 1 : 0
  
  name                = "${var.project_name}-nic-${var.environment}"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main[0].id
  }
  
  tags = local.common_tags
}

# Azure Network Security Group Association
resource "azurerm_network_interface_security_group_association" "main" {
  count = local.deploy_azure ? 1 : 0
  
  network_interface_id      = azurerm_network_interface.main[0].id
  network_security_group_id = azurerm_network_security_group.main[0].id
}

# Azure Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  count = local.deploy_azure ? 1 : 0
  
  name                = "${var.project_name}-vm-${var.environment}"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
  size                = var.vm_size
  admin_username      = "adminuser"
  
  disable_password_authentication = true
  
  network_interface_ids = [
    azurerm_network_interface.main[0].id,
  ]
  
  admin_ssh_key {
    username   = "adminuser"
    public_key = data.local_file.ssh_public_key.content
  }
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  
  custom_data = base64encode(templatefile("${path.module}/scripts/user-data.sh", {
    app_port = var.app_port
  }))
  
  tags = local.common_tags
}