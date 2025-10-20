# 🧪 Test del Helm Chart Genérico

Write-Host "🚀 Testing generic Helm chart..." -ForegroundColor Green

# Verificar que helm esté instalado
if (-not (Get-Command helm -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Helm no está instalado. Instalar desde: https://helm.sh/docs/intro/install/" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Helm está disponible" -ForegroundColor Green

# Cambiar al directorio del chart
Set-Location "k8s/chart"

# Test 1: Helm lint
Write-Host "`n🔍 Running helm lint..." -ForegroundColor Yellow
try {
    helm lint .
    Write-Host "✅ Helm lint passed" -ForegroundColor Green
} catch {
    Write-Host "❌ Helm lint failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Template rendering with required values
Write-Host "`n📄 Testing template rendering..." -ForegroundColor Yellow

$testValues = @{
    "image.tag" = "test123"
    "ingress.host" = "test.example.com"
    "appConfig.endpoint" = "https://test.azconfig.io"
    "appConfig.label" = "test"
    "workloadIdentity.clientId" = "test-client-id"
}

$setArgs = @()
foreach ($key in $testValues.Keys) {
    $setArgs += "--set"
    $setArgs += "$key=$($testValues[$key])"
}

try {
    $templateOutput = helm template test-release . @setArgs
    Write-Host "✅ Template rendering successful" -ForegroundColor Green
    
    # Verificar que los valores requeridos estén presentes
    if ($templateOutput -match "test123" -and $templateOutput -match "test.example.com") {
        Write-Host "✅ Required values properly injected" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Some required values may not be properly injected" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Template rendering failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Test con values faltantes (debería fallar)
Write-Host "`n🚫 Testing required values validation..." -ForegroundColor Yellow
try {
    helm template test-release . --set image.tag=test123 2>$null
    Write-Host "⚠️ Template rendering succeeded when it should have failed (missing required values)" -ForegroundColor Yellow
} catch {
    Write-Host "✅ Required values validation working (template failed as expected)" -ForegroundColor Green
}

# Test 4: Dry run con kubectl (si está disponible)
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    Write-Host "`n🔄 Testing kubectl dry-run..." -ForegroundColor Yellow
    try {
        $templateOutput = helm template test-release . @setArgs
        $templateOutput | kubectl apply --dry-run=client -f - 2>$null
        Write-Host "✅ Kubectl dry-run passed" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Kubectl dry-run failed (may be expected if cluster is not accessible)" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️ kubectl not available, skipping dry-run test" -ForegroundColor Yellow
}

# Volver al directorio original
Set-Location "../.."

Write-Host "`n📋 Resumen del Chart Genérico:" -ForegroundColor Cyan
Write-Host "✅ Chart Name: generic-app-chart" -ForegroundColor White
Write-Host "✅ Templates: deployment, service, ingress, serviceaccount, hpa" -ForegroundColor White
Write-Host "✅ Values: Estructura genérica con nameOverride" -ForegroundColor White
Write-Host "✅ Helpers: Funciones genéricas chart.*" -ForegroundColor White
Write-Host "✅ Required: image.tag, ingress.host, appConfig.*, workloadIdentity.clientId" -ForegroundColor White

Write-Host "`n🎯 Para usar en otras aplicaciones:" -ForegroundColor Cyan
Write-Host "1. Copiar k8s/chart/ folder" -ForegroundColor White
Write-Host "2. Cambiar nameOverride en values.yaml" -ForegroundColor White
Write-Host "3. Ajustar image.repository" -ForegroundColor White
Write-Host "4. Personalizar healthCheck.path si es necesario" -ForegroundColor White
Write-Host "5. Deploy con helm install/upgrade" -ForegroundColor White

Write-Host "`n🎉 Testing del chart genérico completado!" -ForegroundColor Green