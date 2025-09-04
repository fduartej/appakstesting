#!/usr/bin/env pwsh

param(
    [Parameter(Mandatory=$true)]
    [string]$AcrName,
    
    [string]$ImageTag = "latest"
)

Write-Host "🔧 Actualizando imagen del deployment en AKS..." -ForegroundColor Cyan

# Construir la URL completa de la imagen
$ImageUrl = "$AcrName.azurecr.io/database-test-api:$ImageTag"

Write-Host "📦 Nueva imagen: $ImageUrl" -ForegroundColor Yellow

# Actualizar el deployment
Write-Host "🚀 Actualizando deployment..." -ForegroundColor Green
kubectl set image deployment/database-test-api database-test-api=$ImageUrl

# Esperar a que el rollout termine
Write-Host "⏳ Esperando que el rollout termine..." -ForegroundColor Yellow
kubectl rollout status deployment/database-test-api --timeout=300s

# Verificar el estado
Write-Host "✅ Verificando estado final..." -ForegroundColor Green
kubectl get pods -l app=database-test-api
kubectl get deployment database-test-api

Write-Host "🎉 ¡Deployment actualizado exitosamente!" -ForegroundColor Green
