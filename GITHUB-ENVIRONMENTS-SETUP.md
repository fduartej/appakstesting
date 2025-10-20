# Configuración de GitHub Environments - Variables Requeridas

## 🚨 **Variables Faltantes Detectadas**

### **Error en el log:**
```
📁 Namespace: default  ← Debería ser "database-test-dev" 
--resource-group   ← Variable vacía
--name   ← Variable vacía
```

## 📋 **Configuración Requerida por Environment**

### **Ir a: Settings > Environments > [environment] > Add Variable**

### **Environment: `dev`**
```
AZURE_RESOURCE_GROUP = rg-integration-apps-dev
AZURE_AKS_CLUSTER = aks-dev-01
KUBERNETES_NAMESPACE = database-test-dev
INGRESS_HOST = dev-database-test-api.calidda.com.pe
APP_ENVIRONMENT = Development
AZURE_APP_CONFIG_ENDPOINT = https://appconfig-noprod-01.azconfig.io
AZURE_APP_CONFIG_LABEL = dev
AZURE_MANAGED_IDENTITY_CLIENT_ID = e7207547-8e1e-4095-8b41-6c8827a9e1f5
```

### **Environment: `qa`**
```
AZURE_RESOURCE_GROUP = rg-integration-apps-qa
AZURE_AKS_CLUSTER = aks-qa-01
KUBERNETES_NAMESPACE = database-test-qa
INGRESS_HOST = qa-database-test-api.calidda.com.pe
APP_ENVIRONMENT = QA
AZURE_APP_CONFIG_ENDPOINT = https://appconfig-qa-01.azconfig.io
AZURE_APP_CONFIG_LABEL = qa
AZURE_MANAGED_IDENTITY_CLIENT_ID = qa-client-id-here
```

### **Environment: `uat`**
```
AZURE_RESOURCE_GROUP = rg-integration-apps-uat
AZURE_AKS_CLUSTER = aks-uat-01
KUBERNETES_NAMESPACE = database-test-uat
INGRESS_HOST = uat-database-test-api.calidda.com.pe
APP_ENVIRONMENT = UAT
AZURE_APP_CONFIG_ENDPOINT = https://appconfig-uat-01.azconfig.io
AZURE_APP_CONFIG_LABEL = uat
AZURE_MANAGED_IDENTITY_CLIENT_ID = uat-client-id-here
```

### **Environment: `prod`**
```
AZURE_RESOURCE_GROUP = rg-integration-apps-prod
AZURE_AKS_CLUSTER = aks-prod-01
KUBERNETES_NAMESPACE = database-test-prod
INGRESS_HOST = database-test-api.calidda.com.pe
APP_ENVIRONMENT = Production
AZURE_APP_CONFIG_ENDPOINT = https://appconfig-prod-01.azconfig.io
AZURE_APP_CONFIG_LABEL = prod
AZURE_MANAGED_IDENTITY_CLIENT_ID = prod-client-id-here
```

## 🎯 **Pasos para configurar:**

### **1. Ir a GitHub Repository Settings**
```
Tu Repositorio → Settings → Environments
```

### **2. Crear/Editar Environment `dev`**
```
Environments → dev (o "New environment")
```

### **3. Agregar Variables**
```
En el environment "dev":
- Click "Add variable"
- Agregar cada variable de la lista de arriba
- Usar los valores reales de tu Azure subscription
```

### **4. Repetir para otros environments**
```
- qa environment con valores de QA
- uat environment con valores de UAT  
- prod environment con valores de PROD
```

## ✅ **Después de configurar:**

El output debería ser:
```
📁 Namespace: database-test-dev  ✅
--resource-group rg-integration-apps-dev  ✅
--name aks-dev-01  ✅
```

## 🔍 **Verificación:**

Una vez configuradas las variables, el deployment debería:
1. Crear namespace `database-test-dev` (no `default`)
2. Usar el resource group correcto
3. Conectar al cluster AKS correcto
4. Aplicar el manifest sin errores

## 📝 **Nota importante:**

Reemplaza estos valores con los reales de tu Azure environment:
- `rg-integration-apps-dev` → Tu resource group real
- `aks-dev-01` → Tu cluster AKS real
- `e7207547-8e1e-4095-8b41-6c8827a9e1f5` → Tu Managed Identity Client ID real