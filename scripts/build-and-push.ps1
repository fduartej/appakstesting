# PowerShell script to build and push Docker image to ACR
param(
    [Parameter(Mandatory=$true)]
    [string]$AcrName,
    
    [Parameter(Mandatory=$false)]
    [string]$ImageTag = "latest",
    
    [Parameter(Mandatory=$false)]
    [string]$ImageName = "database-test-api"
)

# Colors for output
$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Cyan"

Write-Host "Starting Docker build and ACR push process..." -ForegroundColor $InfoColor

try {
    # Login to ACR
    Write-Host "Logging in to Azure Container Registry..." -ForegroundColor $InfoColor
    az acr login --name $AcrName
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to login to ACR"
    }

    # Build Docker image
    Write-Host "Building Docker image..." -ForegroundColor $InfoColor
    $FullImageName = "$AcrName.azurecr.io/$ImageName`:$ImageTag"
    docker build -t $FullImageName .
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to build Docker image"
    }

    # Push image to ACR
    Write-Host "Pushing image to ACR..." -ForegroundColor $InfoColor
    docker push $FullImageName
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push image to ACR"
    }

    Write-Host "Successfully built and pushed image: $FullImageName" -ForegroundColor $SuccessColor
    
    # Update Kubernetes deployment file with new image name
    Write-Host "Updating Kubernetes deployment file..." -ForegroundColor $InfoColor
    $DeploymentFile = "k8s\deployment.yaml"
    $DeploymentContent = Get-Content $DeploymentFile -Raw
    $UpdatedContent = $DeploymentContent -replace "YOUR_ACR_NAME\.azurecr\.io/database-test-api:latest", $FullImageName
    Set-Content -Path $DeploymentFile -Value $UpdatedContent
    
    Write-Host "Kubernetes deployment file updated successfully!" -ForegroundColor $SuccessColor
    Write-Host "You can now deploy to AKS using:" -ForegroundColor $InfoColor
    Write-Host "  kubectl apply -f k8s/deployment.yaml" -ForegroundColor $InfoColor
    Write-Host "  kubectl apply -f k8s/service.yaml" -ForegroundColor $InfoColor
    Write-Host "  kubectl apply -f k8s/ingress.yaml" -ForegroundColor $InfoColor
    Write-Host "Or use the deploy script: .\scripts\deploy-to-aks.ps1" -ForegroundColor $InfoColor

} catch {
    Write-Host "Error: $_" -ForegroundColor $ErrorColor
    exit 1
}
