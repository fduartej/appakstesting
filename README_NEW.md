# Database Test API 🗄️

Una API REST moderna para probar la conectividad a SQL Server (on-premise o Azure SQL) con interfaz web interactiva, Swagger UI integrado y deployment automatizado a Azure Kubernetes Service (AKS).

## 🚀 Características Principales

- ✅ **API REST completa** para testing de conectividad a bases de datos
- ✅ **Formulario web interactivo** con interfaz moderna y responsive
- ✅ **Soporte completo** para SQL Server on-premise y Azure SQL Database
- ✅ **Swagger UI integrado** para documentación y testing de API
- ✅ **Consulta automática** de fecha actual desde la base de datos
- ✅ **Ejecución de consultas SQL personalizadas**
- ✅ **Containerización Docker** optimizada para producción
- ✅ **CI/CD completo** con GitHub Actions
- ✅ **Deployment automático** a Azure Kubernetes Service (AKS)
- ✅ **Health checks** y monitoreo integrado
- ✅ **Manejo de errores** detallado y user-friendly

## 🛠️ Tecnologías Utilizadas

- **Backend**: ASP.NET Core 9.0
- **Base de datos**: Microsoft SQL Server / Azure SQL
- **Frontend**: Bootstrap 5, Font Awesome, JavaScript
- **Containerización**: Docker
- **Orquestación**: Kubernetes
- **CI/CD**: GitHub Actions
- **Cloud**: Azure (ACR + AKS)

## 📋 Requisitos Previos

- .NET 9.0 SDK
- Docker Desktop
- Azure CLI
- kubectl
- Git
- Acceso a Azure Container Registry (ACR)
- Acceso a Azure Kubernetes Service (AKS)

## 🏃‍♂️ Ejecución Local

### 1. Clonar el repositorio

```bash
git clone <your-repo-url>
cd appakstesting
```

### 2. Restaurar dependencias

```powershell
dotnet restore
```

### 3. Ejecutar la aplicación

```powershell
dotnet run
```

### 4. Acceder a la aplicación

- **🌐 Interfaz web**: `http://localhost:5174`
- **📚 Swagger UI**: `http://localhost:5174/swagger`

## 📱 Interfaz Web - Formulario Interactivo

La aplicación incluye una interfaz web moderna con:

### ✨ Características del Formulario:

- **Campo de cadena de conexión** con ejemplos
- **Campo opcional** para consultas SQL personalizadas
- **Botón "Cargar Ejemplo"** con conexión de prueba
- **Spinner de carga** durante la ejecución
- **Resultados en tiempo real** con:
  - ✅ Estado de conexión exitosa/fallida
  - 🖥️ Información del servidor
  - 📅 Fecha actual de la base de datos
  - 📊 Resultado de consulta personalizada
  - ❌ Mensajes de error detallados

### 🎨 Interfaz:

- Design moderno con Bootstrap 5
- Iconos Font Awesome
- Responsive design
- Animaciones CSS
- Estados de carga visual

## 🔗 API Endpoints

### `POST /api/DatabaseTest/test-connection`

Prueba la conectividad y ejecuta consultas en la base de datos.

**Request:**

```json
{
  "connectionString": "Server=localhost;Database=TestDB;User Id=user;Password=pass;TrustServerCertificate=true;",
  "customQuery": "SELECT COUNT(*) FROM Users" // Opcional
}
```

**Response:**

```json
{
  "isConnected": true,
  "currentDate": "2025-09-04 15:30:45",
  "customQueryResult": "150",
  "errorMessage": null,
  "testTimestamp": "2025-09-04T15:30:45Z",
  "serverInfo": "localhost",
  "databaseName": "TestDB"
}
```

### `GET /api/DatabaseTest/health`

Health check del servicio.

### `GET /api/DatabaseTest/connection-examples`

Ejemplos de cadenas de conexión para diferentes escenarios.

## 🔐 Ejemplos de Cadenas de Conexión

### SQL Server On-Premise (Autenticación SQL)

```
Server=localhost;Database=TestDB;User Id=testuser;Password=testpass;TrustServerCertificate=true;
```

### SQL Server On-Premise (Windows Authentication)

```
Server=localhost;Database=TestDB;Integrated Security=true;TrustServerCertificate=true;
```

### Azure SQL Database

```
Server=tcp:myserver.database.windows.net,1433;Database=mydatabase;User ID=myuser;Password=mypassword;Encrypt=true;Connection Timeout=30;
```

## 🐳 Containerización

### Dockerfile Optimizado

- Multi-stage build para tamaño mínimo
- Non-root user para seguridad
- Puerto 8080 optimizado para contenedores

### Build Manual

```bash
docker build -t database-test-api .
docker run -p 8080:8080 database-test-api
```

### Docker Compose (con SQL Server de prueba)

```bash
docker-compose up -d
```

## ☸️ Kubernetes (AKS)

### Estructura de Manifiestos

```
k8s/
├── deployment.yaml    # Deployment de la aplicación
├── service.yaml      # Service ClusterIP
├── ingress.yaml      # Ingress con nginx
└── configmap.yaml    # ConfigMap opcional
```

### Deployment Manual

```bash
# Aplicar manifiestos
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml

# Verificar deployment
kubectl get deployments
kubectl get pods -l app=database-test-api
kubectl get services
```

### Port Forward para Testing

```bash
kubectl port-forward service/database-test-api 8080:80
# Acceder en http://localhost:8080
```

## 🔄 CI/CD con GitHub Actions

### Workflow Automatizado (`.github/workflows/build-push-deploy.yml`)

**Trigger**: Push a rama `main`

**Proceso**:

1. ✅ **Build** - Compilación de .NET 9.0
2. 🐳 **Docker Build & Push** - Construcción y subida a ACR
3. ☸️ **AKS Deploy** - Deployment automático a Kubernetes
4. ✔️ **Verification** - Validación del deployment

### Configuración de Secrets

En GitHub: `Settings > Secrets and variables > Actions`

```
AZURE_ACR_SERVER=myacr.azurecr.io
AZURE_ACR_USERNAME=myacr
AZURE_ACR_PASSWORD=<password>
AZURE_RESOURCE_GROUP=my-rg
AZURE_AKS_CLUSTER=my-aks
AZURE_CREDENTIALS={"clientId":"...","clientSecret":"..."}
```

### Setup Automatizado

```powershell
.\scripts\setup-github-actions.ps1 `
  -SubscriptionId "your-sub-id" `
  -ResourceGroupName "your-rg" `
  -AcrName "your-acr" `
  -AksClusterName "your-aks"
```

## 📜 Scripts Disponibles

| Script                             | Descripción                       |
| ---------------------------------- | --------------------------------- |
| `scripts/setup-github-actions.ps1` | Configurar Azure y GitHub Actions |
| `scripts/build-and-push.ps1`       | Build y push manual a ACR         |
| `scripts/deploy-to-aks.ps1`        | Deploy manual a AKS               |
| `scripts/test-api.ps1`             | Testing automatizado de la API    |

## 🏗️ Estructura del Proyecto

```
appakstesting/
├── 📁 .github/workflows/          # GitHub Actions
│   └── build-push-deploy.yml
├── 📁 Controllers/                # API Controllers
│   ├── DatabaseTestController.cs  # API principal
│   └── HomeController.cs          # Web UI
├── 📁 Models/                     # Data models
│   └── DatabaseTestModels.cs      # Request/Response models
├── 📁 Services/                   # Business logic
│   └── DatabaseTestService.cs     # Database service
├── 📁 Views/                      # Razor views
│   └── Home/Index.cshtml          # Formulario interactivo
├── 📁 k8s/                       # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── configmap.yaml
├── 📁 scripts/                   # PowerShell scripts
│   ├── setup-github-actions.ps1
│   ├── build-and-push.ps1
│   ├── deploy-to-aks.ps1
│   └── test-api.ps1
├── 🐳 Dockerfile                 # Container configuration
├── 🐙 docker-compose.yml         # Local development
└── 📋 README.md                  # Este archivo
```

## 🚀 Deployment Workflow

### Desarrollo Local

```bash
git checkout -b feature/nueva-funcionalidad
# ... desarrollar ...
git commit -m "Add nueva funcionalidad"
git push origin feature/nueva-funcionalidad
```

### Deploy a Producción

```bash
# Crear Pull Request hacia main
# Una vez aprobado y merged:
git checkout main
git pull origin main

# 🤖 GitHub Actions automáticamente:
# 1. Build de .NET
# 2. Build y push de Docker image a ACR
# 3. Deploy a AKS
# 4. Verificación de health checks
```

## 🔍 Monitoreo y Troubleshooting

### Verificar Deployment

```bash
# Status general
kubectl get all -l app=database-test-api

# Logs de la aplicación
kubectl logs -l app=database-test-api -f

# Describir recursos
kubectl describe deployment database-test-api
kubectl describe pod -l app=database-test-api
```

### Health Checks

- **API Health**: `GET /api/DatabaseTest/health`
- **Kubernetes Liveness**: Configurado automáticamente
- **Database Connectivity**: A través del formulario o API

### Troubleshooting Común

| Problema             | Solución                              |
| -------------------- | ------------------------------------- |
| Error SSL/TLS        | Agregar `TrustServerCertificate=true` |
| Connection Timeout   | Ajustar `Connection Timeout=30`       |
| Auth Failed          | Verificar credenciales y permisos     |
| Pod CrashLoopBackOff | Revisar logs con `kubectl logs`       |
| Service Unavailable  | Verificar service y endpoints         |

## 📚 Recursos Adicionales

- [Documentación ASP.NET Core](https://docs.microsoft.com/aspnet/core/)
- [Azure Kubernetes Service](https://docs.microsoft.com/azure/aks/)
- [GitHub Actions](https://docs.github.com/actions)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## 🤝 Contribuir

1. Fork el proyecto
2. Crear branch feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push al branch (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

---

**¡Disfruta probando conectividad a bases de datos! 🎉**
