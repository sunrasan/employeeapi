# Deployment Guide: EmployeeApi203 (OpenShift to AWS EKS)

## What changed in this migration
The application has been migrated from OpenShift to AWS EKS. The following changes were made to the deployment manifests:
- **OpenShift Resources Removed**: `DeploymentConfig`, `Route`, `ImageStream`, and OpenShift-specific `ServiceAccount` and `Secret` (found in `openshift/` directory) were removed.
- **EKS Resources Implemented**: 
    - `K8s/deployment.yaml`: Replaces `DeploymentConfig` with a standard Kubernetes `Deployment`.
    - `K8s/service.yaml`: Standard Kubernetes `Service` (ClusterIP).
    - `K8s/ingress.yaml`: Replaces OpenShift `Route` with an AWS ALB Ingress using `ingressClassName: alb`.
    - `K8s/namespace.yaml`: Defines the `employee` namespace.

## Prerequisites
- AWS CLI installed and configured.
- `kubectl` installed.
- An active AWS EKS Cluster.
- **AWS Load Balancer Controller** must be installed on the EKS cluster for the Ingress to be provisioned.
- IAM permissions to create ECR repositories and manage EKS resources.

## Build and Push
The application uses the existing `Dockerfile` at the root of the repository.

1. Run the build script:
   - Linux/macOS: `./scripts/build-push.sh`
   - Windows: `scripts\\build-push.bat`
2. Follow the prompts to select your registry (AWS ECR or Docker Hub).
3. The script will build the image and push it to the registry.
4. **Note the final Image URI** printed at the end of the script.

## Deployment Walkthrough
1. Run the deployment script:
   - Linux/macOS: `./scripts/deploy-image.sh`
   - Windows: `scripts\\deploy-image.bat`
2. Provide the AWS Region, EKS Cluster Name, and the **Full Image URI** from the build step.
3. The script applies manifests in the following order:
   - `K8s/namespace.yaml`
   - `K8s/service.yaml`
   - `K8s/deployment.yaml` (Image URI is substituted here)
   - `K8s/ingress.yaml`

## EKS vs OpenShift: Key Differences
- **No Routes**: OpenShift `Route` is replaced by Kubernetes `Ingress`. We use the AWS Load Balancer Controller to create an Application Load Balancer (ALB).
- **No DeploymentConfigs**: Standard `Deployment` is used for rollout management.
- **No ImageStreams**: Images are pulled directly from ECR/Docker Hub.
- **No In-Cluster Builds**: Images must be built and pushed via the provided scripts.
- **Security**: OpenShift SCCs are replaced by Kubernetes Pod Security Admission (PSA) labels on the namespace.

## Troubleshooting
- **InvalidImageName**: Ensure the Image URI provided to `deploy-image.sh` is correct and accessible.
- **Ingress ADDRESS is empty**: This usually means the AWS Load Balancer Controller is not installed or is misconfigured.
- **No matches for kind**: If you see this error, ensure you are not applying old OpenShift manifests (e.g., from the `openshift/` directory).
- **Pods rejected**: Check if the namespace has the required Pod Security Admission labels.

## Rollback and Scaling
- **Rollback**: `kubectl rollout undo deployment/employeeapi -n employee`
- **Scaling**: `kubectl scale deployment/employeeapi --replicas=3 -n employee`

## Java/JVM Configuration
The application runs on Java 17 using the `eclipse-temurin:17-jre` base image. Memory and CPU limits should be adjusted in `K8s/deployment.yaml` based on production load.
