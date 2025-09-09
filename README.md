# Multi-Cloud CI/CD Pipeline

A comprehensive CI/CD pipeline using Jenkins and Terraform that deploys applications to both AWS and Azure free tier resources.

## 🚀 Features

- **Multi-cloud deployment** to AWS and Azure
- **Jenkins CI/CD pipeline** with automated testing
- **Terraform Infrastructure as Code**
- **Docker containerization**
- **Free tier optimized** configurations
- **Cross-platform support** (macOS, Linux, Windows WSL)

## 📦 Project Structure

```
multicloud-cicd-pipeline/
├── terraform/           # Infrastructure as Code
├── scripts/            # Deployment scripts
├── jenkins/            # CI/CD pipeline
├── docker/             # Container configs
├── src/                # Application code
├── docs/               # Documentation
├── monitoring/         # Monitoring setup
├── .github/workflows/  # GitHub Actions
├── Dockerfile          # Container definition
├── docker-compose.yml  # Local development
├── package.json        # Node.js dependencies
├── Makefile           # Automation commands
└── README.md          # This file
```

## 🛠️ Quick Start

1. **Configure cloud credentials:**
   ```bash
   aws configure
   az login
   ```

2. **Generate SSH keys:**
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
   ```

3. **Configure Terraform:**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

4. **Deploy infrastructure:**
   ```bash
   terraform init
   terraform apply
   ```

5. **Set up Jenkins:**
   ```bash
   ./scripts/setup-jenkins.sh
   ```

6. **Test locally:**
   ```bash
   make install
   make test
   make dev
   curl http://localhost/health
   ```

## 📋 Prerequisites

- AWS Account with free tier access
- Azure Account with free tier access
- Terraform >= 1.0
- Docker
- Node.js 18+
- Git

## 🧪 Testing

```bash
make test              # Run all tests
npm test              # Run unit tests only
make dev              # Start development environment
curl http://localhost/health  # Test health endpoint
```

## 🚀 Deployment Options

### Using Terraform directly
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Using Docker locally
```bash
docker-compose up -d
```

### Using Make commands
```bash
make deploy           # Deploy infrastructure
make destroy          # Clean up resources
```

### Using Jenkins
1. Run `./scripts/setup-jenkins.sh`
2. Access Jenkins at http://localhost:8080
3. Configure credentials and create pipeline job
4. Run the pipeline

## 🔧 Configuration

### AWS Resources (Free Tier)
- EC2 t2.micro instance
- VPC with public subnet
- S3 bucket for storage
- Security groups

### Azure Resources (Free Tier)
- Standard_B1s VM
- Virtual Network
- Storage Account
- Network Security Group

## 📊 Monitoring

- Health checks at `/health` endpoint
- Application info at `/api/info`
- Prometheus monitoring (optional)

## 🔒 Security

- Security scanning with Checkov
- Proper credential management
- Network security groups
- Least privilege access

## 🗑️ Cleanup

```bash
# Destroy infrastructure
make destroy

# Clean up Docker
make clean

# Or manually
terraform destroy
docker-compose down --volumes
```

## 📚 Available Commands

```bash
make help             # Show all commands
make install          # Install dependencies
make build            # Build Docker image
make test             # Run tests
make dev              # Start development environment
make deploy           # Deploy infrastructure
make destroy          # Destroy infrastructure
make clean            # Clean up resources
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `make test`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For issues and questions:
1. Check the documentation
2. Search existing GitHub issues
3. Create a new issue with detailed description

---

**Made with ❤️ for multi-cloud deployments**
