# Configuración Dinámica de Azure App Configuration

## 🔧 Problema Identificado

El código en `Program.cs` tenía el `labelFilter: "dev"` hardcodeado, lo que significa que **todos los ambientes** (DEV, QA, UAT, PROD) usarían siempre la configuración de DEV.

## ✅ Solución Implementada

### 1. Código C# Actualizado

```csharp
// Antes (hardcodeado):
.Select("app:db-testapi:*", labelFilter: "dev")

// Después (dinámico):
var appConfigLabel = Environment.GetEnvironmentVariable("AzureAppConfigLabel") ?? "dev";
.Select("app:db-testapi:*", labelFilter: appConfigLabel)
```

### 2. Nuevo Endpoint de Diagnóstico

Se agregó `/config-info` que muestra:

- Environment actual (ASPNETCORE_ENVIRONMENT)
- Azure App Config Endpoint
- Azure App Config Label
- Azure Client ID
- Timestamp

## 🌍 Configuración por Ambiente

### Variables de Entorno Requeridas

Cada ambiente debe configurar estas variables:

```bash
# DEV
ASPNETCORE_ENVIRONMENT=Development
AzureAppConfigEndpoint=https://your-dev-appconfig.azconfig.io
AzureAppConfigLabel=dev
AZURE_CLIENT_ID=dev-managed-identity-client-id

# QA
ASPNETCORE_ENVIRONMENT=Staging
AzureAppConfigEndpoint=https://your-qa-appconfig.azconfig.io
AzureAppConfigLabel=qa
AZURE_CLIENT_ID=qa-managed-identity-client-id

# UAT
ASPNETCORE_ENVIRONMENT=Staging
AzureAppConfigEndpoint=https://your-uat-appconfig.azconfig.io
AzureAppConfigLabel=uat
AZURE_CLIENT_ID=uat-managed-identity-client-id

# PROD
ASPNETCORE_ENVIRONMENT=Production
AzureAppConfigEndpoint=https://your-prod-appconfig.azconfig.io
AzureAppConfigLabel=prod
AZURE_CLIENT_ID=prod-managed-identity-client-id
```

## 🔍 Verificación

Una vez desplegado, puedes verificar la configuración visitando:

- `https://dev-database-test-api.calidda.com.pe/config-info`
- `https://qa-database-test-api.calidda.com.pe/config-info`
- `https://uat-database-test-api.calidda.com.pe/config-info`
- `https://database-test-api.calidda.com.pe/config-info`

## 📋 Configuración Actual del Deployment

### Helm Chart (DEV)

Ya configurado en `k8s/chart/templates/deployment.yaml`:

```yaml
- name: AzureAppConfigLabel
  value: { { required "label requerido" .Values.appConfig.label | quote } }
```

### Kubectl Manifests (QA/UAT/PROD)

Ya configurado en `k8s/deployment.yaml`:

```yaml
- name: AzureAppConfigLabel
  value: "{{AZURE_APP_CONFIG_LABEL}}"
```

## ✅ Estado Actual

- ✅ Código C# actualizado para usar configuración dinámica
- ✅ Endpoint de diagnóstico agregado
- ✅ Helm chart ya configurado correctamente
- ✅ Kubectl manifests ya configurados correctamente
- ✅ GitHub Actions workflow configurado para pasar variables

## 🚀 Próximos Pasos

1. Configurar las variables de ambiente en GitHub Environments
2. Configurar Azure App Configuration con labels por ambiente
3. Desplegar y verificar usando el endpoint `/config-info`
