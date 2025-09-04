# Configuración de Secrets para GitHub Actions

Este documento describe todos los secrets que necesitas configurar en GitHub para que el workflow de CI/CD funcione correctamente.

## Secrets Requeridos

### Azure Container Registry (ACR)

- **`AZURE_ACR_SERVER`**: URL del servidor ACR (ej: `myacr.azurecr.io`)
- **`AZURE_ACR_USERNAME`**: Nombre de usuario del ACR (generalmente el nombre del ACR)
- **`AZURE_ACR_PASSWORD`**: Password o access token del ACR

### Azure Kubernetes Service (AKS)

- **`AZURE_RESOURCE_GROUP`**: Nombre del resource group que contiene el cluster AKS
- **`AZURE_AKS_CLUSTER`**: Nombre del cluster de AKS

### Azure Authentication

- **`AZURE_CREDENTIALS`**: JSON con las credenciales del service principal de Azure

### Notificaciones (Opcional)

- **`SLACK_WEBHOOK_URL`**: URL del webhook de Slack para notificaciones

## Cómo configurar los secrets

### 1. Configurar Azure Service Principal

```bash
# Crear service principal
az ad sp create-for-rbac --name "github-actions-sp" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group-name} \
  --sdk-auth

# El output será algo así (guárdalo como AZURE_CREDENTIALS):
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret",
  "subscriptionId": "your-subscription-id",
  "tenantId": "your-tenant-id",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### 2. Obtener credenciales de ACR

```bash
# Habilitar admin user en ACR
az acr update --name myacr --admin-enabled true

# Obtener credenciales
az acr credential show --name myacr

# Output:
# {
#   "passwords": [
#     {
#       "name": "password",
#       "value": "your-password-here"  # <- Este es AZURE_ACR_PASSWORD
#     }
#   ],
#   "username": "myacr"  # <- Este es AZURE_ACR_USERNAME
# }
```

### 3. Configurar secrets en GitHub

1. Ve a tu repositorio en GitHub
2. Navega a **Settings** > **Secrets and variables** > **Actions**
3. Haz clic en **New repository secret**
4. Agrega cada secret con su valor correspondiente:

```
AZURE_ACR_SERVER=myacr.azurecr.io
AZURE_ACR_USERNAME=myacr
AZURE_ACR_PASSWORD=your-acr-password
AZURE_RESOURCE_GROUP=my-resource-group
AZURE_AKS_CLUSTER=my-aks-cluster
AZURE_CREDENTIALS={"clientId":"...","clientSecret":"..."}
```

## Verificar la configuración

### 1. Test de ACR

```bash
# Test login to ACR
docker login $AZURE_ACR_SERVER -u $AZURE_ACR_USERNAME -p $AZURE_ACR_PASSWORD
```

### 2. Test de AKS

```bash
# Test AKS access
az login --service-principal -u $CLIENT_ID -p $CLIENT_SECRET --tenant $TENANT_ID
az aks get-credentials --resource-group $AZURE_RESOURCE_GROUP --name $AZURE_AKS_CLUSTER
kubectl get nodes
```

## Environments de GitHub

El workflow utiliza environments de GitHub para deployment:

### Production Environment

- **Nombre**: `production`
- **Branch**: `main`
- **Reviewers**: Configurar reviewers requeridos antes de deployment

### Staging Environment

- **Nombre**: `staging`
- **Branch**: `develop`
- **Auto-deploy**: Habilitado

### Configurar Environments

1. Ve a **Settings** > **Environments**
2. Crea `production` y `staging`
3. Configura branch protection rules
4. Agrega reviewers para production

## Permisos necesarios

El Service Principal necesita los siguientes permisos:

- **Container Registry**: `AcrPush`, `AcrPull`
- **Kubernetes Service**: `Azure Kubernetes Service Cluster User Role`
- **Resource Group**: `Contributor`

```bash
# Asignar permisos específicos
az role assignment create \
  --assignee $CLIENT_ID \
  --role "AcrPush" \
  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ContainerRegistry/registries/$ACR_NAME

az role assignment create \
  --assignee $CLIENT_ID \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ContainerService/managedClusters/$AKS_NAME
```

## Troubleshooting

### Error: "unauthorized: authentication required"

- Verificar AZURE_ACR_USERNAME y AZURE_ACR_PASSWORD
- Verificar que admin user esté habilitado en ACR

### Error: "az: command not found"

- El workflow usa ubuntu-latest que tiene Azure CLI preinstalado

### Error: "kubectl: connection refused"

- Verificar AZURE_RESOURCE_GROUP y AZURE_AKS_CLUSTER
- Verificar permisos del service principal

### Error: "deployment not found"

- Verificar que los archivos k8s/ estén en el repositorio
- Verificar sintaxis de los manifiestos YAML
