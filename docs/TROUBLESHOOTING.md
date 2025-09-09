# Troubleshooting Guide

## Common Issues

### 1. Script Execution Errors

#### Syntax Errors
- **Problem**: Script has syntax errors or heredoc issues
- **Solution**: Ensure you're using the latest script version

#### Permission Denied
```bash
chmod +x setup-final.sh
chmod +x scripts/*.sh
```

### 2. Terraform Issues

#### Backend Configuration
```bash
# If S3 bucket doesn't exist
aws s3 mb s3://your-terraform-state-bucket-$(date +%s) --region us-east-1

# Update backend.tf with correct bucket name
```

#### State Lock
```bash
# If state is locked, force unlock (use carefully)
terraform force-unlock <LOCK_ID>
```

#### Provider Authentication
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Verify Azure credentials
az account show
```

### 3. AWS Issues

#### Credentials
```bash
# Reconfigure AWS credentials
aws configure

# Test access
aws ec2 describe-regions --region us-east-1
```

#### Free Tier Limits
- Monitor usage in AWS Billing Dashboard
- Use only t2.micro instances
- Set up billing alerts

#### SSH Connection
```bash
# Fix SSH key permissions
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Test SSH connection
ssh -i ~/.ssh/id_rsa ubuntu@<aws-instance-ip>
```

### 4. Azure Issues

#### Authentication
```bash
# Re-authenticate if needed
az logout
az login

# Set correct subscription
az account set --subscription <subscription-id>
```

#### Resource Limits
- Use Standard_B1s VM size only
- Monitor usage in Azure portal
- Stay within free tier limits

#### SSH Connection
```bash
# Test SSH connection to Azure VM
ssh -i ~/.ssh/id_rsa adminuser@<azure-vm-ip>
```

### 5. Jenkins Issues

#### macOS Jenkins Problems
```bash
# Restart Jenkins
brew services restart jenkins-lts

# Check logs
tail -f /opt/homebrew/var/log/jenkins-lts/jenkins.log

# If port 8080 is in use
lsof -ti:8080 | xargs kill -9
```

#### Linux Jenkins Problems
```bash
# Check Jenkins status
sudo systemctl status jenkins

# Restart Jenkins
sudo systemctl restart jenkins

# Check logs
sudo journalctl -u jenkins -f
```

#### Plugin Installation Issues
- Update Jenkins through web interface
- Install suggested plugins
- Restart Jenkins after plugin installation

### 6. Docker Issues

#### Permission Denied
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# On macOS, ensure Docker Desktop is running
```

#### Container Build Failures
```bash
# Clean up Docker
docker system prune -f

# Rebuild without cache
docker build --no-cache -t multicloud-app .
```

#### Port Already in Use
```bash
# Kill processes using port 3000 or 80
lsof -ti:3000 | xargs kill -9
lsof -ti:80 | xargs kill -9
```

### 7. Application Issues

#### Health Check Failures
```bash
# Check if application is running
docker-compose ps

# Check application logs
docker-compose logs app

# Restart application
docker-compose restart app
```

#### Build Failures
```bash
# Clear npm cache
npm cache clean --force

# Remove node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### 8. Network Issues

#### Instance Not Accessible
- Verify security groups allow HTTP (port 80) and SSH (port 22)
- Check that instances are running
- Verify public IP addresses are assigned

#### DNS Resolution
```bash
# Test DNS resolution
nslookup <instance-ip>
ping <instance-ip>
```

### 9. Cost Management

#### Unexpected Charges
- Set up billing alerts in AWS and Azure
- Monitor free tier usage regularly
- Stop/deallocate instances when not in use

#### Resource Cleanup
```bash
# Stop AWS instances
aws ec2 stop-instances --instance-ids <instance-id>

# Deallocate Azure VMs  
az vm deallocate --resource-group <rg-name> --name <vm-name>

# Destroy all infrastructure
terraform destroy -auto-approve
```

## Debug Commands

### Terraform Debugging
```bash
export TF_LOG=DEBUG
terraform apply
```

### Application Debugging
```bash
# Local debugging
npm run dev

# Container debugging
docker logs <container-name>
```

### Network Debugging
```bash
# Test connectivity
telnet <ip> <port>
curl -v http://<ip>/health
```

## Getting Help

### Log Locations
- **Jenkins**: 
  - macOS: `/opt/homebrew/var/log/jenkins-lts/jenkins.log`
  - Linux: `/var/log/jenkins/jenkins.log`
- **Terraform**: `.terraform/` directory
- **Docker**: `docker logs <container-name>`
- **Application**: `journalctl -u multicloud-app` (on instances)

### Support Resources
1. [Terraform Documentation](https://terraform.io/docs)
2. [Jenkins Documentation](https://jenkins.io/doc)
3. [AWS Documentation](https://docs.aws.amazon.com)
4. [Azure Documentation](https://docs.microsoft.com/azure)
5. [Docker Documentation](https://docs.docker.com)

### Community Support
- Stack Overflow
- Reddit (r/devops, r/terraform)
- GitHub Issues

Remember: Always backup your state files before making major changes!
