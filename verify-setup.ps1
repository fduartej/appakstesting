# 🔍 Verificación de Setup Multi-Ambiente

Write-Host "🚀 Verificando configuración Multi-Ambiente con Helm..." -ForegroundColor Green

# Verificar estructura de archivos
Write-Host "`n📁 Verificando estructura de archivos..." -ForegroundColor Yellow

$requiredFiles = @(
    ".github\workflows\helm-multi-env.yml",
    "k8s\chart\Chart.yaml",
    "k8s\chart\values.yaml", 
    "k8s\chart\templates\_helpers.tpl",
    "k8s\chart\templates\deployment.yaml",
    "k8s\chart\templates\service.yaml",
    "k8s\chart\templates\ingress.yaml",
    "k8s\chart\templates\serviceaccount.yaml",
    "k8s\chart\templates\hpa.yaml",
    "k8s\deployment.yaml",
    "k8s\service.yaml",
    "k8s\ingress.yaml",
    "k8s\hpa.yaml",
    "k8s\serviceaccount.yaml",
    "README-HELM.md"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ $file" -ForegroundColor Red
    }
}

# Verificar Helm Chart
Write-Host "`n🎯 Verificando Helm Chart..." -ForegroundColor Yellow

if (Get-Command helm -ErrorAction SilentlyContinue) {
    Write-Host "✅ Helm está instalado" -ForegroundColor Green
    
    try {
        helm lint k8s\chart\
        Write-Host "✅ Helm chart syntax OK" -ForegroundColor Green
    } catch {
        Write-Host "❌ Helm chart tiene errores: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️ Helm no está instalado. Instalar desde: https://helm.sh/docs/intro/install/" -ForegroundColor Yellow
}

# Verificar placeholders en kubectl manifests
Write-Host "`n🔧 Verificando placeholders en kubectl manifests..." -ForegroundColor Yellow

$kubectlFiles = @("k8s\deployment.yaml", "k8s\service.yaml", "k8s\ingress.yaml", "k8s\hpa.yaml", "k8s\serviceaccount.yaml")
$placeholders = @("{{NAMESPACE}}", "{{IMAGE_TAG}}", "{{INGRESS_HOST}}", "{{ENVIRONMENT}}", "{{AZURE_APP_CONFIG_ENDPOINT}}", "{{AZURE_APP_CONFIG_LABEL}}")

foreach ($file in $kubectlFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        $foundPlaceholders = @()
        
        foreach ($placeholder in $placeholders) {
            if ($content -match [regex]::Escape($placeholder)) {
                $foundPlaceholders += $placeholder
            }
        }
        
        if ($foundPlaceholders.Count -gt 0) {
            Write-Host "✅ $file tiene placeholders: $($foundPlaceholders -join ', ')" -ForegroundColor Green
        } else {
            Write-Host "⚠️ $file no tiene placeholders" -ForegroundColor Yellow
        }
    }
}

# Verificar configuración Docker
Write-Host "`n🐳 Verificando Docker..." -ForegroundColor Yellow

if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "✅ Docker está disponible" -ForegroundColor Green
    
    try {
        docker --version
        Write-Host "✅ Docker version OK" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error al verificar Docker: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Docker no está instalado" -ForegroundColor Red
}

# Verificar .NET
Write-Host "`n📦 Verificando .NET..." -ForegroundColor Yellow

if (Get-Command dotnet -ErrorAction SilentlyContinue) {
    Write-Host "✅ .NET está disponible" -ForegroundColor Green
    
    try {
        $dotnetVersion = dotnet --version
        Write-Host "✅ .NET version: $dotnetVersion" -ForegroundColor Green
        
        if ($dotnetVersion -like "9.*") {
            Write-Host "✅ .NET 9.0 detected - Compatible" -ForegroundColor Green
        } else {
            Write-Host "⚠️ .NET 9.0 recomendado para este proyecto" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Error al verificar .NET: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "❌ .NET no está instalado" -ForegroundColor Red
}

# Resumen
Write-Host "`n📋 Siguiente pasos:" -ForegroundColor Cyan
Write-Host "1. Configurar GitHub Environments (dev, qa, uat, prod)" -ForegroundColor White
Write-Host "2. Configurar Variables en cada Environment" -ForegroundColor White
Write-Host "3. Configurar Repository Secrets" -ForegroundColor White
Write-Host "4. Push al branch 'helm' para testing" -ForegroundColor White
Write-Host "5. Verificar deployment en AKS" -ForegroundColor White

Write-Host "`n🎉 Verificación completada! Ver README-HELM.md para configuración detallada." -ForegroundColor Green