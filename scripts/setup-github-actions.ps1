# Script de configuración inicial para el repositorio
# Ejecutar después de hacer push del código a GitHub

param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$AcrName,
    
    [Parameter(Mandatory=$true)]
    [string]$AksClusterName,
    
    [Parameter(Mandatory=$false)]
    [string]$ServicePrincipalName = "github-actions-database-test-api"
)

$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Cyan"
$WarningColor = "Yellow"

Write-Host "=== Configuración de Azure y GitHub Actions ===" -ForegroundColor $InfoColor
Write-Host ""

try {
    # 1. Login a Azure
    Write-Host "1. Verificando login en Azure..." -ForegroundColor $InfoColor
    $context = az account show --query "id" -o tsv 2>$null
    if (-not $context) {
        Write-Host "Necesitas hacer login en Azure primero:" -ForegroundColor $WarningColor
        Write-Host "az login" -ForegroundColor $InfoColor
        exit 1
    }
    Write-Host "✓ Conectado a Azure" -ForegroundColor $SuccessColor

    # 2. Configurar suscripción
    Write-Host "2. Configurando suscripción..." -ForegroundColor $InfoColor
    az account set --subscription $SubscriptionId
    Write-Host "✓ Suscripción configurada: $SubscriptionId" -ForegroundColor $SuccessColor

    # 3. Habilitar admin user en ACR
    Write-Host "3. Configurando Azure Container Registry..." -ForegroundColor $InfoColor
    az acr update --name $AcrName --admin-enabled true --resource-group $ResourceGroupName
    
    # Obtener credenciales de ACR
    $acrCreds = az acr credential show --name $AcrName --resource-group $ResourceGroupName | ConvertFrom-Json
    $acrServer = "$AcrName.azurecr.io"
    $acrUsername = $acrCreds.username
    $acrPassword = $acrCreds.passwords[0].value
    
    Write-Host "✓ ACR configurado:" -ForegroundColor $SuccessColor
    Write-Host "  Server: $acrServer" -ForegroundColor $InfoColor
    Write-Host "  Username: $acrUsername" -ForegroundColor $InfoColor

    # 4. Crear Service Principal
    Write-Host "4. Creando Service Principal..." -ForegroundColor $InfoColor
    
    # Obtener scope del resource group
    $scope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName"
    
    # Crear service principal
    $spJson = az ad sp create-for-rbac --name $ServicePrincipalName --role contributor --scopes $scope --sdk-auth
    $spData = $spJson | ConvertFrom-Json
    
    Write-Host "✓ Service Principal creado: $ServicePrincipalName" -ForegroundColor $SuccessColor

    # 5. Asignar permisos adicionales
    Write-Host "5. Asignando permisos adicionales..." -ForegroundColor $InfoColor
    
    # Permisos para ACR
    $acrScope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.ContainerRegistry/registries/$AcrName"
    az role assignment create --assignee $spData.clientId --role "AcrPush" --scope $acrScope
    
    # Permisos para AKS
    $aksScope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.ContainerService/managedClusters/$AksClusterName"
    az role assignment create --assignee $spData.clientId --role "Azure Kubernetes Service Cluster User Role" --scope $aksScope
    
    Write-Host "✓ Permisos asignados" -ForegroundColor $SuccessColor

    # 6. Mostrar secrets para GitHub
    Write-Host ""
    Write-Host "=== SECRETS PARA GITHUB ACTIONS ===" -ForegroundColor $InfoColor
    Write-Host ""
    Write-Host "Configura estos secrets en tu repositorio GitHub:" -ForegroundColor $WarningColor
    Write-Host "(Settings > Secrets and variables > Actions > New repository secret)" -ForegroundColor $InfoColor
    Write-Host ""
    
    Write-Host "AZURE_ACR_SERVER=" -NoNewline -ForegroundColor $InfoColor
    Write-Host $acrServer -ForegroundColor $SuccessColor
    
    Write-Host "AZURE_ACR_USERNAME=" -NoNewline -ForegroundColor $InfoColor
    Write-Host $acrUsername -ForegroundColor $SuccessColor
    
    Write-Host "AZURE_ACR_PASSWORD=" -NoNewline -ForegroundColor $InfoColor
    Write-Host $acrPassword -ForegroundColor $SuccessColor
    
    Write-Host "AZURE_RESOURCE_GROUP=" -NoNewline -ForegroundColor $InfoColor
    Write-Host $ResourceGroupName -ForegroundColor $SuccessColor
    
    Write-Host "AZURE_AKS_CLUSTER=" -NoNewline -ForegroundColor $InfoColor
    Write-Host $AksClusterName -ForegroundColor $SuccessColor
    
    Write-Host "AZURE_CREDENTIALS=" -NoNewline -ForegroundColor $InfoColor
    Write-Host $spJson -ForegroundColor $SuccessColor
    
    Write-Host ""
    Write-Host "=== COMANDOS DE VERIFICACIÓN ===" -ForegroundColor $InfoColor
    Write-Host ""
    Write-Host "# Test ACR login:" -ForegroundColor $InfoColor
    Write-Host "docker login $acrServer -u $acrUsername -p $acrPassword" -ForegroundColor $WarningColor
    Write-Host ""
    Write-Host "# Test AKS access:" -ForegroundColor $InfoColor
    Write-Host "az aks get-credentials --resource-group $ResourceGroupName --name $AksClusterName" -ForegroundColor $WarningColor
    Write-Host "kubectl get nodes" -ForegroundColor $WarningColor
    Write-Host ""
    
    Write-Host "=== PRÓXIMOS PASOS ===" -ForegroundColor $InfoColor
    Write-Host "1. Configura los secrets en GitHub" -ForegroundColor $WarningColor
    Write-Host "2. Haz push del código a la rama main" -ForegroundColor $WarningColor
    Write-Host "3. El workflow se ejecutará automáticamente" -ForegroundColor $WarningColor
    Write-Host "4. Verifica el deployment en AKS" -ForegroundColor $WarningColor
    
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor $ErrorColor
    Write-Host ""
    Write-Host "Verifica que:" -ForegroundColor $WarningColor
    Write-Host "- Tienes permisos de Contributor en la suscripción" -ForegroundColor $WarningColor
    Write-Host "- Los recursos existen (ACR, AKS)" -ForegroundColor $WarningColor
    Write-Host "- Azure CLI está instalado y actualizado" -ForegroundColor $WarningColor
    exit 1
}

Write-Host ""
Write-Host "✅ Configuración completada exitosamente!" -ForegroundColor $SuccessColor
