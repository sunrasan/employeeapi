@echo off
setlocal enabledelayedexpansion

echo --- EmployeeApi203 EKS Deployment ---

set /p AWS_REGION="AWS Region (e.g. us-east-1): "
set /p CLUSTER_NAME="EKS Cluster Name: "
set /p IMAGE_URI="Full Image URI (from build-push.sh): "

echo Updating kubeconfig...
aws eks update-kubeconfig --region !AWS_REGION! --name !CLUSTER_NAME!

echo Verifying cluster connectivity...
kubectl cluster-info

set MANIFEST_NS=K8s/namespace.yaml
set MANIFEST_SVC=K8s/service.yaml
set MANIFEST_DEP=K8s/deployment.yaml
set MANIFEST_ING=K8s/ingress.yaml

echo Updating image reference in deployment manifest...
:: Using powershell for sed-like replacement on Windows
powershell -Command "(Get-Content %MANIFEST_DEP%) -replace '<AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/employeeapi:latest', '%IMAGE_URI%' | Set-Content %MANIFEST_DEP%"

echo Applying Namespace...
kubectl apply -f %MANIFEST_NS%

echo Applying Service...
kubectl apply -f %MANIFEST_SVC%

echo Applying Deployment...
kubectl apply -f %MANIFEST_DEP%

echo Applying Ingress...
kubectl apply -f %MANIFEST_ING%

echo Waiting for rollout...
kubectl rollout status deployment/employeeapi -n employee

echo Fetching resources...
kubectl get pods,svc,ingress -n employee

echo -------------------------------------------------------
echo DEPLOYMENT COMPLETE
echo Check the Ingress ADDRESS above for the application URL.
echo If the ADDRESS is empty, ensure the AWS Load Balancer Controller is installed.
echo -------------------------------------------------------
echo Rollback command: kubectl rollout undo deployment/employeeapi -n employee
