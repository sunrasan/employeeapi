#!/bin/bash
set -e

echo "--- EmployeeApi203 Build and Push ---"

# Project configuration
PROJECT_NAME="EmployeeApi203"
BUILD_FILE="Dockerfile"

# 1. Registry Selection
echo "Select target registry:"
echo "1) AWS ECR"
echo "2) Docker Hub"
read -p "Choice [1-2]: " REGISTRY_CHOICE

if [ "$REGISTRY_CHOICE" == "1" ]; then
    echo "Configuring AWS ECR..."
    read -p "AWS Region (e.g. us-east-1): " AWS_REGION
    read -p "ECR Repository Name: " ECR_REPO
    
    # Login to ECR
    echo "Logging into Amazon ECR..."
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
    
    # Ensure repository exists
    echo "Checking if repository $ECR_REPO exists..."
    aws ecr describe-repositories --repository-names $ECR_REPO --region $AWS_REGION >/dev/null 2>&1 || \
    aws ecr create-repository --repository-name $ECR_REPO --region $AWS_REGION
    
    REGISTRY_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
    FULL_REPO_NAME="$ECR_REPO"
else
    echo "Configuring Docker Hub..."
    read -p "Docker Hub Username: " DOCKER_USER
    REGISTRY_URL="docker.io"
    FULL_REPO_NAME="$DOCKER_USER/employeeapi"
    
    echo "Logging into Docker Hub..."
    docker login -u $DOCKER_USER
fi

# 2. Tagging
read -p "Enter image tag [latest]: " IMAGE_TAG
IMAGE_TAG=${IMAGE_TAG:-latest}

# Sanitize image name
IMAGE_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-*//;s/-*$//')
FULL_IMAGE_URI="$REGISTRY_URL/$IMAGE_NAME:$IMAGE_TAG"

# 3. Build
echo "Building Docker image using $BUILD_FILE..."
docker build -f $BUILD_FILE -t $FULL_IMAGE_URI .

# 4. Push
echo "Pushing image to registry..."
docker push $FULL_IMAGE_URI

echo "-------------------------------------------------------"
echo "SUCCESS: Image pushed to $FULL_IMAGE_URI"
echo "Use this URI as the image value when running deploy-image.sh"
echo "-------------------------------------------------------"
