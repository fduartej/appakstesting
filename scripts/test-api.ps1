# Script de prueba para la API de Database Test
# Ejecutar desde PowerShell

param(
    [Parameter(Mandatory=$false)]
    [string]$BaseUrl = "http://localhost:5174"
)

$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Cyan"

Write-Host "=== Database Test API - Script de Prueba ===" -ForegroundColor $InfoColor
Write-Host "Base URL: $BaseUrl" -ForegroundColor $InfoColor
Write-Host ""

# Función para hacer peticiones HTTP
function Invoke-ApiRequest {
    param(
        [string]$Method,
        [string]$Endpoint,
        [hashtable]$Body = $null
    )
    
    try {
        $uri = "$BaseUrl$Endpoint"
        Write-Host "[$Method] $uri" -ForegroundColor $InfoColor
        
        $params = @{
            Uri = $uri
            Method = $Method
            ContentType = "application/json"
        }
        
        if ($Body) {
            $params.Body = $Body | ConvertTo-Json
        }
        
        $response = Invoke-RestMethod @params
        Write-Host "✓ Success" -ForegroundColor $SuccessColor
        return $response
    }
    catch {
        Write-Host "✗ Error: $($_.Exception.Message)" -ForegroundColor $ErrorColor
        return $null
    }
}

# Test 1: Health Check
Write-Host "1. Testing Health Check..." -ForegroundColor $InfoColor
$health = Invoke-ApiRequest -Method "GET" -Endpoint "/api/DatabaseTest/health"
if ($health) {
    Write-Host "   Status: $($health.status)" -ForegroundColor $SuccessColor
    Write-Host "   Service: $($health.service)" -ForegroundColor $SuccessColor
}
Write-Host ""

# Test 2: Connection Examples
Write-Host "2. Getting Connection Examples..." -ForegroundColor $InfoColor
$examples = Invoke-ApiRequest -Method "GET" -Endpoint "/api/DatabaseTest/connection-examples"
if ($examples) {
    Write-Host "   Available examples:" -ForegroundColor $SuccessColor
    Write-Host "   - On-Premise SQL Server" -ForegroundColor $SuccessColor
    Write-Host "   - Azure SQL Database" -ForegroundColor $SuccessColor
}
Write-Host ""

# Test 3: Test Database Connection (with invalid connection)
Write-Host "3. Testing Invalid Database Connection..." -ForegroundColor $InfoColor
$invalidTest = @{
    connectionString = "Server=invalid-server;Database=test;User Id=test;Password=test;"
    customQuery = "SELECT GETDATE()"
}
$result = Invoke-ApiRequest -Method "POST" -Endpoint "/api/DatabaseTest/test-connection" -Body $invalidTest
if ($result) {
    Write-Host "   Connected: $($result.isConnected)" -ForegroundColor $(if($result.isConnected) { $SuccessColor } else { $InfoColor })
    if ($result.errorMessage) {
        Write-Host "   Error: $($result.errorMessage)" -ForegroundColor $InfoColor
    }
}
Write-Host ""

# Test 4: Test with LocalDB (if available)
Write-Host "4. Testing LocalDB Connection..." -ForegroundColor $InfoColor
$localDbTest = @{
    connectionString = "Server=(localdb)\mssqllocaldb;Database=tempdb;Trusted_Connection=true;"
    customQuery = "SELECT @@VERSION"
}
$localResult = Invoke-ApiRequest -Method "POST" -Endpoint "/api/DatabaseTest/test-connection" -Body $localDbTest
if ($localResult) {
    Write-Host "   Connected: $($localResult.isConnected)" -ForegroundColor $(if($localResult.isConnected) { $SuccessColor } else { $InfoColor })
    if ($localResult.isConnected) {
        Write-Host "   Current Date: $($localResult.currentDate)" -ForegroundColor $SuccessColor
        Write-Host "   Server: $($localResult.serverInfo)" -ForegroundColor $SuccessColor
        Write-Host "   Database: $($localResult.databaseName)" -ForegroundColor $SuccessColor
    }
    if ($localResult.errorMessage) {
        Write-Host "   Error: $($localResult.errorMessage)" -ForegroundColor $InfoColor
    }
}
Write-Host ""

Write-Host "=== Pruebas Completadas ===" -ForegroundColor $InfoColor
Write-Host ""
Write-Host "Para usar la interfaz web, visita: $BaseUrl" -ForegroundColor $InfoColor
Write-Host "Para usar Swagger UI, visita: $BaseUrl/swagger" -ForegroundColor $InfoColor
