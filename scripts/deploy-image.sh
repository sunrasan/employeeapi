#!/bin/bash
set -e
set -o pipefail

echo "--- EmployeeApi203 EKS Deployment ---"

# 1. Inputs
read -p "AWS Region (e.g. us-east-1): " AWS_REGION
read -p "EKS Cluster Name: " CLUSTER_NAME
read -p "Full Image URI (from build-push.sh): " IMAGE_URI

# 2. Configure kubectl
echo "Updating kubeconfig..."
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

echo "Verifying cluster connectivity..."
kubectl cluster-info

# 3. Manifest Paths
MANIFEST_NS="K8s/namespace.yaml"
MANIFEST_SVC="K8s/service.yaml"
MANIFEST_DEP="K8s/deployment.yaml"
MANIFEST_ING="K8s/ingress.yaml"

# 4. Image Substitution
echo "Updating image reference in deployment manifest..."
sed -i 's|<AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/employeeapi:latest|'$IMAGE_URI'|g' $MANIFEST_DEP

# 5. Apply Manifests in Order
echo "Applying Namespace..."
kubectl apply -f $MANIFEST_NS

echo "Applying Service..."
kubectl apply -f $MANIFEST_SVC

echo "Applying Deployment..."
kubectl apply -f $MANIFEST_DEP

echo "Applying Ingress..."
kubectl apply -f $MANIFEST_ING

# 6. Verification
echo "Waiting for rollout..."
kubectl rollout status deployment/employeeapi -n employee

echo "Fetching resources..."
kubectl get pods,svc,ingress -n employee

echo "-------------------------------------------------------"
echo "DEPLOYMENT COMPLETE"
echo "Check the Ingress ADDRESS above for the application URL."
echo "If the ADDRESS is empty, ensure the AWS Load Balancer Controller is installed."
echo "-------------------------------------------------------"
echo "Rollback command: kubectl rollout undo deployment/employeeapi -n employee"
