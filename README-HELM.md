# 🚀 Configuración Multi-Ambiente con Helm

## 📁 Estructura Completa

```
appakstesting/
├── .github/
│   └── workflows/
│       ├── build-push-deploy.yml          # Legacy workflow (deprecated)
│       └── helm-multi-env.yml              # New multi-environment workflow ✅
├── k8s/
│   ├── chart/                              # Helm Chart para DEV ✅
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   ├── templates/
│   │   │   ├── _helpers.tpl
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   ├── ingress.yaml
│   │   │   ├── serviceaccount.yaml
│   │   │   └── hpa.yaml
│   │   └── values-dev.yaml               # Valores específicos para DEV
│   ├── deployment.yaml                   # Kubectl manifests para QA/UAT/PROD
│   ├── service.yaml
│   ├── ingress.yaml
│   └── hpa.yaml
└── README-HELM.md                        # Este archivo
```

## 🎯 Estrategia de Deployment

### Build Once, Deploy Many

- **1 Job de Build**: Genera imagen Docker una sola vez con tag SHA
- **5 Jobs de Deploy**: Diferentes estrategias según ambiente

### Ambientes y Estrategias

| Ambiente | Branch  | Herramienta | Justificación                         |
| -------- | ------- | ----------- | ------------------------------------- |
| DEV      | develop | Helm        | Máxima flexibilidad, iteración rápida |
| DEV      | helm    | Helm        | Testing de Helm chart                 |
| QA       | qa      | kubectl     | Estabilidad, manifests probados       |
| UAT      | uat     | kubectl     | Pre-producción, sin cambios           |
| PROD     | main    | kubectl     | Máxima estabilidad                    |

## ⚙️ Configuración GitHub Environments

### 1. Crear Environments en GitHub

Ve a tu repositorio → Settings → Environments → New environment

Crear estos environments:

- `dev`
- `qa`
- `uat`
- `prod`

### 2. Variables por Environment

#### Environment: `dev`

**Variables (Environment variables):**

```
AZURE_RESOURCE_GROUP=rg-integration-apps-noprod
AZURE_AKS_CLUSTER=aks-noprod-02
KUBERNETES_NAMESPACE=dev-database-test
INGRESS_HOST=database-test-dev.yourdomain.com
APP_ENVIRONMENT=Development
AZURE_APP_CONFIG_ENDPOINT=https://appconfig-dev.azconfig.io
AZURE_APP_CONFIG_LABEL=dev
```

#### Environment: `qa`

**Variables (Environment variables):**

```
AZURE_RESOURCE_GROUP=rg-integration-apps-noprod
AZURE_AKS_CLUSTER=aks-noprod-02
KUBERNETES_NAMESPACE=qa-database-test
INGRESS_HOST=database-test-qa.yourdomain.com
APP_ENVIRONMENT=Staging
AZURE_APP_CONFIG_ENDPOINT=https://appconfig-qa.azconfig.io
AZURE_APP_CONFIG_LABEL=qa
```

#### Environment: `uat`

**Variables (Environment variables):**

```
AZURE_RESOURCE_GROUP=rg-integration-apps-noprod
AZURE_AKS_CLUSTER=aks-noprod-02
KUBERNETES_NAMESPACE=uat-database-test
INGRESS_HOST=database-test-uat.yourdomain.com
APP_ENVIRONMENT=Staging
AZURE_APP_CONFIG_ENDPOINT=https://appconfig-uat.azconfig.io
AZURE_APP_CONFIG_LABEL=uat
```

#### Environment: `prod`

**Variables (Environment variables):**

```
AZURE_RESOURCE_GROUP=rg-integration-apps-prod
AZURE_AKS_CLUSTER=aks-prod-01
KUBERNETES_NAMESPACE=prod-database-test
INGRESS_HOST=database-test.yourdomain.com
APP_ENVIRONMENT=Production
AZURE_APP_CONFIG_ENDPOINT=https://appconfig-prod.azconfig.io
AZURE_APP_CONFIG_LABEL=prod
```

### 3. Repository Secrets (Global)

En Settings → Secrets and variables → Actions → New repository secret:

```
AZURE_CREDENTIALS={"clientId":"xxx","clientSecret":"xxx","subscriptionId":"xxx","tenantId":"xxx"}
AZURE_ACR_SERVER=crintegrationappsnoprod01.azurecr.io
AZURE_ACR_USERNAME=crintegrationappsnoprod01
AZURE_ACR_PASSWORD=xxx
```

## 🔄 Flujo de Trabajo

### Branch Strategy

```
main (prod) ← merge ← uat ← merge ← qa ← merge ← develop
     ↓                ↓             ↓             ↓
   kubectl          kubectl       kubectl       helm
```

### Comandos de Deploy

#### DEV (Helm)

```bash
# Crear tarball del chart
tar -czf chart.tar.gz k8s/chart/

# Deploy con Helm
az aks command invoke \
  --resource-group rg-integration-apps-noprod \
  --name aks-noprod-02 \
  --file chart.tar.gz \
  --command "tar -xzf chart.tar.gz && helm upgrade --install database-test-api ./k8s/chart \
    --set image.repository=crintegrationappsnoprod01.azurecr.io/database-test-api \
    --set image.tag=abc123def \
    --set ingress.host=database-test-dev.yourdomain.com \
    --namespace dev-database-test \
    --create-namespace \
    --wait"
```

#### QA/UAT/PROD (kubectl)

```bash
# Reemplazar valores en manifests
sed -i "s|{{IMAGE_TAG}}|abc123def|g" k8s/deployment.yaml
sed -i "s|{{INGRESS_HOST}}|database-test-qa.yourdomain.com|g" k8s/ingress.yaml

# Aplicar manifests
az aks command invoke \
  --resource-group rg-integration-apps-noprod \
  --name aks-noprod-02 \
  --file k8s/ \
  --command "kubectl apply -f . -n qa-database-test"
```

## 🧪 Testing del Setup

### 1. Test Helm Chart Localmente

```bash
# Validar sintaxis
helm lint k8s/chart/

# Dry run
helm template database-test-api k8s/chart/ \
  --set image.tag=test123 \
  --set ingress.host=test.example.com

# Deploy a un cluster local (opcional)
helm upgrade --install database-test-api k8s/chart/ \
  --set image.tag=test123 \
  --dry-run
```

### 2. Test GitHub Actions

```bash
# Push a branch helm para testing
git checkout -b helm
git push origin helm

# Verificar workflow en GitHub Actions
```

### 3. Verificar Deployment

```bash
# Ver status de Helm (DEV)
az aks command invoke \
  --resource-group rg-integration-apps-noprod \
  --name aks-noprod-02 \
  --command "helm status database-test-api -n dev-database-test"

# Ver pods
az aks command invoke \
  --resource-group rg-integration-apps-noprod \
  --name aks-noprod-02 \
  --command "kubectl get pods -n dev-database-test"
```

## 🔧 Customización por Ambiente

### DEV (values.yaml overrides)

```yaml
# k8s/chart/values-dev.yaml
replicaCount: 1
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### QA/UAT/PROD (kubectl manifests)

Los manifests en `k8s/` utilizan placeholders que se reemplazan con `sed`:

- `{{IMAGE_TAG}}` → SHA del commit
- `{{INGRESS_HOST}}` → hostname específico del ambiente
- `{{ENVIRONMENT}}` → Development/Staging/Production
- `{{AZURE_APP_CONFIG_ENDPOINT}}` → endpoint de App Configuration
- `{{AZURE_APP_CONFIG_LABEL}}` → label del ambiente

## 🚀 Siguiente Pasos

1. **Configurar Environments en GitHub** ⭐ IMPORTANTE
2. **Configurar Variables y Secrets** ⭐ IMPORTANTE
3. **Push al branch helm para testing**
4. **Verificar deployment DEV**
5. **Crear branches qa, uat si no existen**
6. **Configurar promotion flow**

## 📞 Troubleshooting

### Error: "Context access might be invalid"

**Solución**: Las variables `vars.*` deben configurarse en GitHub Environments

### Error: "Environment 'dev' not found"

**Solución**: Crear environment en GitHub Settings → Environments

### Error: "az aks command invoke failed"

**Solución**: Verificar que el cluster AKS existe y los credentials son correctos

### Error Helm: "chart not found"

**Solución**: Verificar que el tarball se crea correctamente y contiene k8s/chart/

## 🎉 Beneficios de esta Configuración

✅ **Build Once, Deploy Many**: Una imagen, múltiples ambientes  
✅ **Helm para DEV**: Flexibilidad máxima para desarrollo  
✅ **kubectl para PROD**: Estabilidad y control  
✅ **Environment Variables**: Configuración específica por ambiente  
✅ **Azure App Configuration**: Configuración centralizada  
✅ **Horizontal Pod Autoscaler**: Escalado automático  
✅ **Health Checks**: Monitoreo de aplicación  
✅ **Ingress**: Exposición controlada  
✅ **Managed Identity**: Seguridad Azure nativa

¡Tu aplicación está lista para multi-ambiente con la mejor estrategia de deployment! 🎯
