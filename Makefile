.PHONY: help install build test dev deploy destroy clean

help:
	@echo 'Available commands:'
	@echo '  install   - Install dependencies'
	@echo '  build     - Build Docker image'
	@echo '  test      - Run tests'
	@echo '  dev       - Start development environment'
	@echo '  deploy    - Deploy infrastructure'
	@echo '  destroy   - Destroy infrastructure'
	@echo '  clean     - Clean up resources'

install:
	@echo "🔧 Installing dependencies..."
	npm install
	terraform -chdir=terraform init

build:
	@echo "🏗️ Building application..."
	docker build -t multicloud-app:latest .

test:
	@echo "🧪 Running tests..."
	npm test
	terraform -chdir=terraform validate

dev:
	@echo "🚀 Starting development environment..."
	docker-compose up -d

deploy:
	@echo "🚀 Deploying infrastructure..."
	terraform -chdir=terraform apply -auto-approve

destroy:
	@echo "💥 Destroying infrastructure..."
	terraform -chdir=terraform destroy -auto-approve

clean:
	@echo "🧹 Cleaning up..."
	docker-compose down --volumes --remove-orphans || true
	docker system prune -f || true
