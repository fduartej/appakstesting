#!/usr/bin/env pwsh

Write-Host "🔍 Verificando estado de la aplicación en AKS..." -ForegroundColor Cyan

Write-Host "=== Deployment Status ===" -ForegroundColor Yellow
kubectl get deployment database-test-api -o wide

Write-Host "`n=== Pod Status ===" -ForegroundColor Yellow
kubectl get pods -l app=database-test-api -o wide

Write-Host "`n=== Pod Details ===" -ForegroundColor Yellow
$pods = kubectl get pods -l app=database-test-api -o jsonpath='{.items[*].metadata.name}'
foreach ($pod in $pods.Split(' ')) {
    if ($pod -ne "") {
        Write-Host "`n--- Pod: $pod ---" -ForegroundColor Green
        kubectl describe pod $pod | Select-String -Pattern "Ready|State|Restart|Warning|Error|Events:" -A 5
    }
}

Write-Host "`n=== Service Status ===" -ForegroundColor Yellow
kubectl get service database-test-api -o wide

Write-Host "`n=== Recent Events ===" -ForegroundColor Yellow
kubectl get events --sort-by=.metadata.creationTimestamp | Select-Object -Last 10

Write-Host "`n=== Health Check Test ===" -ForegroundColor Yellow
# Intentar hacer port-forward y probar el health endpoint
$job = Start-Job -ScriptBlock {
    kubectl port-forward service/database-test-api 8080:80
}

Start-Sleep -Seconds 3

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/DatabaseTest/health" -TimeoutSec 10
    Write-Host "✅ Health check exitoso: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor White
} catch {
    Write-Host "❌ Health check falló: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Stop-Job -Job $job -Force
    Remove-Job -Job $job -Force
}

Write-Host "`n🎯 Para acceder a la aplicación manualmente:" -ForegroundColor Cyan
Write-Host "kubectl port-forward service/database-test-api 8080:80" -ForegroundColor White
Write-Host "Luego ve a: http://localhost:8080" -ForegroundColor White
