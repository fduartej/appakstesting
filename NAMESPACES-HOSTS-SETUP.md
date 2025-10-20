# 🎯 CONFIGURACIÓN MULTI-AMBIENTE: Namespaces y Hosts

## 📋 Estrategia de Namespaces y Hosts

### 🏗️ **Namespaces por Ambiente**

Cada ambiente tiene su **propio namespace** para aislamiento completo:

```
Cluster AKS:
├── dev-database-test/     # Namespace DEV
├── qa-database-test/      # Namespace QA
├── uat-database-test/     # Namespace UAT
└── prod-database-test/    # Namespace PROD
```

### 🌐 **Hosts por Ambiente**

Cada ambiente tiene su **propio subdominio** para acceso separado:

```
DEV:  dev-database-test-api.calidda.com.pe
QA:   qa-database-test-api.calidda.com.pe
UAT:  uat-database-test-api.calidda.com.pe
PROD: database-test-api.calidda.com.pe
```

## ⚙️ **Configuración GitHub Environments**

### 🔧 **Environment: `dev`**

```
AZURE_RESOURCE_GROUP=rg-integration-apps-noprod
AZURE_AKS_CLUSTER=aks-noprod-02
KUBERNETES_NAMESPACE=dev-database-test           # ⭐ Namespace específico
INGRESS_HOST=dev-database-test-api.calidda.com.pe # ⭐ Host específico
APP_ENVIRONMENT=Development
AZURE_APP_CONFIG_ENDPOINT=https://appconfig-dev.azconfig.io
AZURE_APP_CONFIG_LABEL=dev
AZURE_MANAGED_IDENTITY_CLIENT_ID=client-id-dev
```

### 🔧 **Environment: `qa`**

```
AZURE_RESOURCE_GROUP=rg-integration-apps-noprod
AZURE_AKS_CLUSTER=aks-noprod-02
KUBERNETES_NAMESPACE=qa-database-test            # ⭐ Namespace específico
INGRESS_HOST=qa-database-test-api.calidda.com.pe  # ⭐ Host específico
APP_ENVIRONMENT=Staging
AZURE_APP_CONFIG_ENDPOINT=https://appconfig-qa.azconfig.io
AZURE_APP_CONFIG_LABEL=qa
AZURE_MANAGED_IDENTITY_CLIENT_ID=client-id-qa
```

### 🔧 **Environment: `uat`**

```
AZURE_RESOURCE_GROUP=rg-integration-apps-noprod
AZURE_AKS_CLUSTER=aks-noprod-02
KUBERNETES_NAMESPACE=uat-database-test           # ⭐ Namespace específico
INGRESS_HOST=uat-database-test-api.calidda.com.pe # ⭐ Host específico
APP_ENVIRONMENT=Staging
AZURE_APP_CONFIG_ENDPOINT=https://appconfig-uat.azconfig.io
AZURE_APP_CONFIG_LABEL=uat
AZURE_MANAGED_IDENTITY_CLIENT_ID=client-id-uat
```

### 🔧 **Environment: `prod`**

```
AZURE_RESOURCE_GROUP=rg-integration-apps-prod
AZURE_AKS_CLUSTER=aks-prod-01
KUBERNETES_NAMESPACE=prod-database-test          # ⭐ Namespace específico
INGRESS_HOST=database-test-api.calidda.com.pe    # ⭐ Host específico (sin prefijo)
APP_ENVIRONMENT=Production
AZURE_APP_CONFIG_ENDPOINT=https://appconfig-prod.azconfig.io
AZURE_APP_CONFIG_LABEL=prod
AZURE_MANAGED_IDENTITY_CLIENT_ID=client-id-prod
```

## 🔄 **Cómo Funciona el Deployment**

### 🎯 **Para DEV (Helm)**

```bash
helm upgrade --install database-test-api ./k8s/chart \
  --set image.repository=crintegrationappsnoprod01.azurecr.io/database-test-api \
  --set image.tag=abc123 \
  --set ingress.host=dev-database-test-api.calidda.com.pe \     # ⭐ Host específico
  --set environment=Development \
  --set appConfig.endpoint=https://appconfig-dev.azconfig.io \
  --set appConfig.label=dev \
  --set workloadIdentity.clientId=client-id-dev \
  --namespace dev-database-test \                              # ⭐ Namespace específico
  --create-namespace
```

### 🎯 **Para QA/UAT/PROD (kubectl)**

```bash
# Los placeholders se reemplazan con sed:
sed -i "s|{{INGRESS_HOST}}|qa-database-test-api.calidda.com.pe|g" k8s/ingress.yaml
sed -i "s|{{NAMESPACE}}|qa-database-test|g" k8s/*.yaml
sed -i "s|{{AZURE_MANAGED_IDENTITY_CLIENT_ID}}|client-id-qa|g" k8s/serviceaccount.yaml

kubectl apply -f k8s/ -n qa-database-test
```

## 🔀 **Migración de Aplicaciones Entre Namespaces**

### 📦 **Usar Mismo Chart, Diferente Namespace**

```bash
# Aplicación A en namespace A
helm upgrade --install app-a ./k8s/chart \
  --set nameOverride=application-a \
  --set image.repository=crintegrationappsnoprod01.azurecr.io/app-a \
  --set ingress.host=dev-app-a.calidda.com.pe \
  --namespace dev-app-a

# Aplicación B en namespace B
helm upgrade --install app-b ./k8s/chart \
  --set nameOverride=application-b \
  --set image.repository=crintegrationappsnoprod01.azurecr.io/app-b \
  --set ingress.host=dev-app-b.calidda.com.pe \
  --namespace dev-app-b
```

### 🔄 **Mover Aplicación de Namespace**

```bash
# 1. Deploy en nuevo namespace
helm upgrade --install database-test-api ./k8s/chart \
  --set image.tag=abc123 \
  --set ingress.host=dev-database-test-api.calidda.com.pe \
  --namespace new-namespace \
  --create-namespace

# 2. Verificar que funciona
kubectl get pods -n new-namespace

# 3. Eliminar del namespace anterior
helm uninstall database-test-api -n old-namespace
```

## 📊 **Verificación Multi-Ambiente**

### 🔍 **Ver Todos los Deployments**

```bash
# Ver namespaces
kubectl get namespaces | grep database-test

# Ver pods en todos los ambientes
kubectl get pods -n dev-database-test
kubectl get pods -n qa-database-test
kubectl get pods -n uat-database-test
kubectl get pods -n prod-database-test

# Ver ingress en todos los ambientes
kubectl get ingress -A | grep database-test
```

### 🌐 **Test de Conectividad**

```bash
# Test de cada host
curl -k https://dev-database-test-api.calidda.com.pe/api/DatabaseTest/health
curl -k https://qa-database-test-api.calidda.com.pe/api/DatabaseTest/health
curl -k https://uat-database-test-api.calidda.com.pe/api/DatabaseTest/health
curl -k https://database-test-api.calidda.com.pe/api/DatabaseTest/health
```

## 🎯 **Ventajas de esta Estrategia**

### ✅ **Aislamiento Completo**

- **Namespaces separados** = no hay conflictos de recursos
- **Hosts diferentes** = acceso independiente por ambiente
- **Configuración específica** = cada ambiente con sus propios valores

### ✅ **Flexibilidad de Migración**

- **Mismo chart genérico** para cualquier aplicación
- **Easy namespace switching** cambiendo variables
- **Host patterns predictibles** para automatización

### ✅ **Build Once, Deploy Many**

- **Imagen idéntica** promovida a través de ambientes
- **Configuración diferente** via Environment Variables
- **Validation per environment** via required values

## 🚀 **Correcciones Implementadas**

### ✅ **GitHub Actions Fixed**

- **Indentación corregida** en todos los jobs
- **Namespace dinámico** via `${{ vars.KUBERNETES_NAMESPACE }}`
- **Host específico** via `${{ vars.INGRESS_HOST }}`
- **Service account placeholder** agregado para kubectl

### ✅ **Helm Chart Updates**

- **Release name dinámico** usando `${{ env.IMAGE_NAME }}`
- **Selector labels** actualizados a `app=${{ env.IMAGE_NAME }}`
- **Required values validation** mantenida

### ✅ **kubectl Manifests**

- **Placeholder para Managed Identity** agregado
- **Namespace placeholder** en todos los manifests
- **Host placeholder** para ingress específico por ambiente

**🎉 ¡Configuración multi-ambiente con namespaces y hosts separados completada!**

**Ahora cada ambiente tiene su propio namespace y host, pero usa la misma imagen Docker.** 🎯
