@echo off
setlocal enabledelayedexpansion

echo --- EmployeeApi203 Build and Push ---

set PROJECT_NAME=EmployeeApi203
set BUILD_FILE=Dockerfile

echo Select target registry:
echo 1) AWS ECR
echo 2) Docker Hub
set /p REGISTRY_CHOICE="Choice [1-2]: "

if "%REGISTRY_CHOICE%"=="1" (
    echo Configuring AWS ECR...
    set /p AWS_REGION="AWS Region (e.g. us-east-1): "
    set /p ECR_REPO="ECR Repository Name: "
    
    echo Logging into Amazon ECR...
    aws ecr get-login-password --region !AWS_REGION! | docker login --username AWS --password-stdin !AWS_ACCOUNT_ID!.dkr.ecr.!AWS_REGION!.amazonaws.com
    
    echo Checking if repository !ECR_REPO! exists...
    aws ecr describe-repositories --repository-names !ECR_REPO! --region !AWS_REGION! >nul 2>&1
    if !ERRORLEVEL! neq 0 (
        aws ecr create-repository --repository-name !ECR_REPO! --region !AWS_REGION!
    )
    
    set REGISTRY_URL=!AWS_ACCOUNT_ID!.dkr.ecr.!AWS_REGION!.amazonaws.com
    set FULL_REPO_NAME=!ECR_REPO!
) else (
    echo Configuring Docker Hub...
    set /p DOCKER_USER="Docker Hub Username: "
    set REGISTRY_URL=docker.io
    set FULL_REPO_NAME=!DOCKER_USER!/employeeapi
    
    echo Logging into Docker Hub...
    docker login -u !DOCKER_USER!
)

set /p IMAGE_TAG="Enter image tag [latest]: "
if "!IMAGE_TAG!"=="" set IMAGE_TAG=latest

set IMAGE_NAME=%PROJECT_NAME%
set IMAGE_NAME=%IMAGE_NAME: =-%
:: Simple lowercase conversion for Windows
for %%i in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set IMAGE_NAME=!IMAGE_NAME:%%i=%%i!

set FULL_IMAGE_URI=%REGISTRY_URL%/%IMAGE_NAME%:%IMAGE_TAG%

echo Building Docker image using %BUILD_FILE%...
docker build -f %BUILD_FILE% -t %FULL_IMAGE_URI% .

echo Pushing image to registry...
docker push %FULL_IMAGE_URI%

echo -------------------------------------------------------
echo SUCCESS: Image pushed to %FULL_IMAGE_URI%
echo Use this URI as the image value when running deploy-image.sh
echo -------------------------------------------------------
