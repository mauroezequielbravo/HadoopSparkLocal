#!/usr/bin/env pwsh
# Script de validación del entorno Hadoop + Spark + Hive

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Verificación del Entorno" -ForegroundColor Cyan
Write-Host "  Hadoop + Spark + Hive" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allHealthy = $true

# Función para verificar un servicio
function Test-Service {
    param(
        [string]$ServiceName,
        [string]$ContainerName,
        [string]$Url = $null,
        [string]$Command = $null
    )
    
    Write-Host "Verificando $ServiceName..." -NoNewline
    
    # Verificar que el contenedor esté corriendo
    $containerStatus = docker ps --filter "name=$ContainerName" --format "{{.Status}}"
    
    if ($containerStatus -notmatch "Up") {
        Write-Host " ❌ FALLÓ (contenedor no está corriendo)" -ForegroundColor Red
        return $false
    }
    
    # Si hay una URL, verificar conectividad
    if ($Url) {
        try {
            $response = Invoke-WebRequest -Uri $Url -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                Write-Host " ✅ OK" -ForegroundColor Green
                return $true
            }
        } catch {
            Write-Host " ❌ FALLÓ (no responde en $Url)" -ForegroundColor Red
            return $false
        }
    }
    
    # Si hay un comando, ejecutarlo
    if ($Command) {
        try {
            $result = docker exec $ContainerName bash -c "$Command" 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host " ✅ OK" -ForegroundColor Green
                return $true
            } else {
                Write-Host " ❌ FALLÓ (comando falló)" -ForegroundColor Red
                return $false
            }
        } catch {
            Write-Host " ❌ FALLÓ (error al ejecutar comando)" -ForegroundColor Red
            return $false
        }
    }
    
    Write-Host " ✅ OK" -ForegroundColor Green
    return $true
}

# Verificar servicios
Write-Host "1. Servicios de Contenedores" -ForegroundColor Yellow
Write-Host "------------------------------" -ForegroundColor Yellow

$allHealthy = $allHealthy -and (Test-Service "Hadoop (HDFS)" "hadoop-master" -Url "http://localhost:9870")
$allHealthy = $allHealthy -and (Test-Service "Spark Master" "spark-master" -Url "http://localhost:8080")
$allHealthy = $allHealthy -and (Test-Service "Jupyter Notebook" "spark-master" -Url "http://localhost:8888")
$allHealthy = $allHealthy -and (Test-Service "PostgreSQL" "postgres-hive-metastore" -Command "pg_isready -U postgres")
$allHealthy = $allHealthy -and (Test-Service "Hive Metastore" "hive-metastore" -Command "nc -z localhost 9083")
$allHealthy = $allHealthy -and (Test-Service "HiveServer2" "hive-server" -Url "http://localhost:10002")

Write-Host ""
Write-Host "2. Conectividad HDFS" -ForegroundColor Yellow
Write-Host "------------------------------" -ForegroundColor Yellow

Write-Host "Verificando acceso a HDFS..." -NoNewline
$hdfsTest = docker exec hadoop-master hdfs dfs -ls / 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host " ✅ OK" -ForegroundColor Green
} else {
    Write-Host " ❌ FALLÓ" -ForegroundColor Red
    $allHealthy = $false
}

Write-Host ""
Write-Host "3. Conectividad Hive" -ForegroundColor Yellow
Write-Host "------------------------------" -ForegroundColor Yellow

Write-Host "Verificando Beeline (Hive)..." -NoNewline
$hiveTest = docker exec hive-server beeline -u jdbc:hive2://localhost:10000 -e "SHOW DATABASES;" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host " ✅ OK" -ForegroundColor Green
} else {
    Write-Host " ❌ FALLÓ" -ForegroundColor Red
    $allHealthy = $false
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($allHealthy) {
    Write-Host "  ✅ Todos los servicios están OK" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Servicios disponibles:" -ForegroundColor White
    Write-Host "  • Jupyter Notebook:    http://localhost:8888" -ForegroundColor White
    Write-Host "  • HDFS NameNode:       http://localhost:9870" -ForegroundColor White
    Write-Host "  • Spark Master UI:     http://localhost:8080" -ForegroundColor White
    Write-Host "  • YARN ResourceMgr:    http://localhost:8088" -ForegroundColor White
    Write-Host "  • HiveServer2 UI:      http://localhost:10002" -ForegroundColor White
    Write-Host ""
    Write-Host "Conectarse a Hive:" -ForegroundColor White
    Write-Host "  docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000" -ForegroundColor Gray
    Write-Host ""
    exit 0
} else {
    Write-Host "  ❌ Algunos servicios fallaron" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Para ver logs:" -ForegroundColor White
    Write-Host "  docker-compose logs -f [servicio]" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Para reiniciar:" -ForegroundColor White
    Write-Host "  docker-compose restart" -ForegroundColor Gray
    Write-Host ""
    exit 1
}
