# 1. Configure credentials (if not done)
aws configure
az login

# 2. Generate SSH keys (if not done)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# 3. Create backend resources
BUCKET_NAME="multicloud-terraform-state-$(date +%s)"
aws s3 mb s3://$BUCKET_NAME --region us-east-1
echo "Remember this bucket name: $BUCKET_NAME"

aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1

# 4. Update configurations
cd terraform
# Edit backend.tf with your bucket name
# Edit terraform.tfvars with your IP

# 5. Install and deploy
cd ..
make install
make deploy