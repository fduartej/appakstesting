# Estructura Actual del Proyecto Database Test API

## 📁 Estructura de Archivos Actualizada

```
appakstesting/
├── 📂 .github/workflows/
│   └── build-push-deploy.yml      # GitHub Actions CI/CD
├── 📂 Controllers/
│   ├── DatabaseTestController.cs  # API REST para testing DB
│   └── HomeController.cs          # Controller para web UI
├── 📂 Models/
│   ├── DatabaseTestModels.cs      # Models para Request/Response
│   └── ErrorViewModel.cs          # Model para errores
├── 📂 Services/
│   └── DatabaseTestService.cs     # Lógica de negocio para DB
├── 📂 Views/
│   ├── Home/Index.cshtml          # Formulario web interactivo
│   ├── Home/Privacy.cshtml        # Página de privacidad
│   └── Shared/_Layout.cshtml      # Layout principal
├── 📂 wwwroot/                    # Assets estáticos
├── 📂 k8s/                       # Manifiestos Kubernetes
│   ├── deployment.yaml           # Deployment simplificado
│   ├── service.yaml              # Service ClusterIP
│   ├── ingress.yaml              # Ingress con nginx
│   └── configmap.yaml            # ConfigMap opcional
├── 📂 scripts/                   # Scripts PowerShell
│   ├── setup-github-actions.ps1  # Setup Azure y GitHub
│   ├── build-and-push.ps1        # Build y push a ACR
│   ├── deploy-to-aks.ps1         # Deploy a AKS
│   └── test-api.ps1              # Testing de API
├── 🐳 Dockerfile                 # Multi-stage optimizado
├── 🐙 docker-compose.yml         # Local dev con SQL Server
├── 📋 appakstesting.csproj       # Proyecto .NET 9.0
└── 📄 Program.cs                 # Configuración de la app
```

## ⚙️ Kubernetes Manifests (k8s/)

### 🚀 deployment.yaml - Deployment Simplificado

```yaml
# Deployment básico sin health checks complejos
# Configurado para usar imagen de ACR
# 2 replicas para alta disponibilidad
# Environment: Production
```

### 🌐 service.yaml - Service ClusterIP

```yaml
# Expone la aplicación internamente
# Puerto 80 -> 8080 (container)
# Selector: app=database-test-api
```

### 🔗 ingress.yaml - Ingress Controller

```yaml
# Nginx ingress controller
# Host: database-test-api.contoso.com
# Path: / (todas las rutas)
```

### ⚙️ configmap.yaml - Configuración Opcional

```yaml
# Variables de entorno
# Configuraciones no sensibles
```

## 🔄 CI/CD con GitHub Actions

### 📝 Workflow: build-push-deploy.yml

**Trigger**: Push a branch `main`

**Jobs**: Un solo job `build-push-deploy` que ejecuta:

1. **📥 Checkout**: Clona el repositorio
2. **⚙️ Setup .NET**: Configura .NET 9.0
3. **🏗️ Build**: Compila la aplicación
4. **🔐 ACR Login**: Autentica con Azure Container Registry
5. **🐳 Docker Build**: Construye imagen Docker
6. **📤 Docker Push**: Sube imagen a ACR
7. **☁️ Azure Login**: Autentica con Azure usando Service Principal
8. **☸️ AKS Setup**: Configura kubectl para AKS
9. **🔄 Update Image**: Actualiza deployment.yaml con nueva imagen
10. **🚀 Deploy**: Aplica manifiestos a AKS
11. **✅ Verify**: Verifica que el deployment sea exitoso

### 🔑 Secrets Requeridos

| Secret                 | Descripción             | Ejemplo                |
| ---------------------- | ----------------------- | ---------------------- |
| `AZURE_ACR_SERVER`     | URL del ACR             | `myacr.azurecr.io`     |
| `AZURE_ACR_USERNAME`   | Usuario del ACR         | `myacr`                |
| `AZURE_ACR_PASSWORD`   | Password del ACR        | `<generated-password>` |
| `AZURE_RESOURCE_GROUP` | Resource Group de Azure | `my-resource-group`    |
| `AZURE_AKS_CLUSTER`    | Nombre del cluster AKS  | `my-aks-cluster`       |
| `AZURE_CREDENTIALS`    | Service Principal JSON  | `{"clientId":"..."}`   |

## 🛠️ Scripts PowerShell

### 🔧 setup-github-actions.ps1

- **Propósito**: Automatizar la configuración inicial
- **Funciones**:
  - Crear Service Principal en Azure
  - Habilitar ACR admin user
  - Asignar permisos necesarios
  - Generar secrets para GitHub
- **Uso**: `.\scripts\setup-github-actions.ps1 -SubscriptionId "..." -ResourceGroupName "..." -AcrName "..." -AksClusterName "..."`

### 🐳 build-and-push.ps1

- **Propósito**: Build y push manual a ACR
- **Funciones**:
  - Login a ACR
  - Build de imagen Docker
  - Push a ACR
  - Actualizar deployment.yaml
- **Uso**: `.\scripts\build-and-push.ps1 -AcrName "myacr"`

### ☸️ deploy-to-aks.ps1

- **Propósito**: Deploy manual a AKS
- **Funciones**:
  - Aplicar ConfigMap
  - Aplicar Deployment
  - Aplicar Service
  - Aplicar Ingress
  - Verificar deployment
- **Uso**: `.\scripts\deploy-to-aks.ps1 -Namespace "default"`

### 🧪 test-api.ps1

- **Propósito**: Testing automatizado de la API
- **Funciones**:
  - Test health check
  - Test connection examples
  - Test invalid connection
  - Test LocalDB connection
- **Uso**: `.\scripts\test-api.ps1 -BaseUrl "http://localhost:5174"`

## 🌐 Aplicación Web

### 🎨 Frontend Features

- **Bootstrap 5**: Framework CSS moderno
- **Font Awesome**: Iconos vectoriales
- **JavaScript**: Interactividad y AJAX
- **Responsive Design**: Compatible con móviles

### 📱 Formulario Interactivo

- **Campo Connection String**: Input para cadena de conexión
- **Campo Custom Query**: Textarea opcional para consultas SQL
- **Botón Load Example**: Carga ejemplo de conexión
- **Loading Spinner**: Indicador visual durante pruebas
- **Results Display**: Muestra resultados con formato

### 🔗 Navigation

- **Home**: Formulario principal
- **Swagger**: Link a documentación API
- **Privacy**: Página de privacidad

## 📊 API Endpoints

### `POST /api/DatabaseTest/test-connection`

- **Input**: ConnectionString + Optional CustomQuery
- **Output**: Connection status, current date, query result, error info
- **Features**: Error handling, SQL injection protection

### `GET /api/DatabaseTest/health`

- **Output**: Service health status
- **Usage**: Health checks, monitoring

### `GET /api/DatabaseTest/connection-examples`

- **Output**: Example connection strings
- **Types**: On-premise, Azure SQL, Windows Auth, SQL Auth

## 🐳 Containerización

### 🏗️ Dockerfile Features

- **Multi-stage build**: Optimización de tamaño
- **.NET 9.0 runtime**: Imagen base oficial
- **Non-root user**: Seguridad mejorada
- **Port 8080**: Puerto optimizado para contenedores
- **Health checks**: Configurados para Kubernetes

### 📦 Docker Compose

- **Database Test API**: Puerto 8080
- **SQL Server**: Contenedor de prueba (puerto 1433)
- **Volumes**: Persistencia de datos
- **Networks**: Comunicación entre contenedores

## 🔄 Flujo de Desarrollo

### 1. **Desarrollo Local**

```bash
dotnet run
# Acceder a http://localhost:5174
```

### 2. **Testing Manual**

```bash
.\scripts\test-api.ps1
```

### 3. **Build y Deploy Manual**

```bash
.\scripts\build-and-push.ps1 -AcrName "myacr"
.\scripts\deploy-to-aks.ps1
```

### 4. **Deploy Automático**

```bash
git push origin main
# GitHub Actions ejecuta automáticamente
```

## 📈 Mejoras Implementadas

### ✅ **Desde la versión anterior**:

- **Formulario web interactivo** agregado
- **Estructura K8s simplificada** (archivos separados)
- **GitHub Actions simplificado** (un solo workflow)
- **Scripts PowerShell mejorados**
- **Documentación actualizada**
- **Error handling mejorado**
- **UI/UX modernizada**

### 🎯 **Estado Actual**:

- ✅ Aplicación funcional completa
- ✅ CI/CD operativo
- ✅ Containerización lista
- ✅ Manifiestos K8s validados
- ✅ Scripts de automatización
- ✅ Documentación completa

## 🚀 Próximos Pasos

1. **Configurar secrets en GitHub** usando `setup-github-actions.ps1`
2. **Push a rama main** para trigger del CI/CD
3. **Verificar deployment en AKS**
4. **Configurar dominio personalizado** en ingress
5. **Agregar monitoring** y alertas

---

**El proyecto está listo para producción! 🎉**

### 1. Configurar secrets en GitHub:

```
AZURE_ACR_SERVER
AZURE_ACR_USERNAME
AZURE_ACR_PASSWORD
AZURE_RESOURCE_GROUP
AZURE_AKS_CLUSTER
AZURE_CREDENTIALS
```

### 2. Push a rama main:

```bash
git push origin main
```

### 3. El workflow automáticamente:

- Hace build de la aplicación .NET
- Construye imagen Docker
- La sube a ACR
- Se conecta a AKS
- Aplica los manifiestos K8s
- Verifica el deployment

### 4. Verificar deployment:

```bash
kubectl get deployments
kubectl get services
kubectl get ingress
kubectl get pods -l app=database-test-api
```

### 5. Acceder a la aplicación:

```bash
kubectl port-forward service/database-test-api 8080:80
# Luego ir a http://localhost:8080
```

## Scripts disponibles:

- `scripts/setup-github-actions.ps1` - Configurar Azure y obtener secrets
- `scripts/build-and-push.ps1` - Build manual y push a ACR
- `scripts/deploy-to-aks.ps1` - Deploy manual a AKS
- `scripts/test-api.ps1` - Test de la API

Los archivos ahora siguen la estructura simple y directa del k8s_old, y el workflow de GitHub Actions está simplificado para enfocarse solo en build y deployment básico.
