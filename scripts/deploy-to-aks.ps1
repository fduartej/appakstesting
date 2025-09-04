# PowerShell script to deploy to AKS
param(
    [Parameter(Mandatory=$false)]
    [string]$Namespace = "default",
    
    [Parameter(Mandatory=$false)]
    [switch]$CreateNamespace
)

# Colors for output
$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Cyan"

Write-Host "Starting AKS deployment process..." -ForegroundColor $InfoColor

try {
    # Create namespace if requested
    if ($CreateNamespace) {
        Write-Host "Creating namespace '$Namespace'..." -ForegroundColor $InfoColor
        kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f -
    }

    # Apply ConfigMap and Secrets (if they exist)
    if (Test-Path "k8s\configmap.yaml") {
        Write-Host "Applying ConfigMap and Secrets..." -ForegroundColor $InfoColor
        kubectl apply -f k8s\configmap.yaml -n $Namespace
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Warning: Failed to apply ConfigMap" -ForegroundColor $WarningColor
        }
    }

    # Apply Deployment, Service, and Ingress
    Write-Host "Applying Kubernetes manifests..." -ForegroundColor $InfoColor
    kubectl apply -f k8s\deployment.yaml -n $Namespace
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to apply Deployment"
    }
    
    kubectl apply -f k8s\service.yaml -n $Namespace
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to apply Service"
    }
    
    kubectl apply -f k8s\ingress.yaml -n $Namespace
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to apply Ingress"
    }

    # Wait for deployment to be ready
    Write-Host "Waiting for deployment to be ready..." -ForegroundColor $InfoColor
    kubectl wait --for=condition=available --timeout=300s deployment/database-test-api -n $Namespace

    # Get deployment status
    Write-Host "Deployment status:" -ForegroundColor $InfoColor
    kubectl get deployment database-test-api -n $Namespace
    kubectl get pods -l app=database-test-api -n $Namespace
    kubectl get service database-test-api -n $Namespace
    kubectl get ingress database-test-api-ingress -n $Namespace

    Write-Host "Deployment completed successfully!" -ForegroundColor $SuccessColor
    Write-Host "You can access the API using port-forwarding:" -ForegroundColor $InfoColor
    Write-Host "kubectl port-forward service/database-test-api 8080:80 -n $Namespace" -ForegroundColor $InfoColor

} catch {
    Write-Host "Error: $_" -ForegroundColor $ErrorColor
    exit 1
}
