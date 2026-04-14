# ============================================
# WinRescue Calypsus - HelpDesk Toolkit
# Autor: Yassine Elouakili El Mahdati
# Version: 0.2.0
# Estado: EN DESARROLLO
# ============================================

# Configuración Global
$script:RutaLogs = "$PSScriptRoot\Logs"
$script:RutaReports = "$PSScriptRoot\Reports"
$script:RutaBackups = "$PSScriptRoot\Backups"
$script:LogFile = "$script:RutaLogs\WinRescue_$(Get-Date -Format 'yyyyMMdd').log"

# Crear estructura de directorios
function Inicializar-Directorios {
    $directorios = @($script:RutaLogs, $script:RutaReports, $script:RutaBackups)
    foreach ($dir in $directorios) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
}

# Función de logging
function Escribir-Log {
    param (
        [string]$Mensaje,
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Tipo = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $colorMap = @{
        "INFO" = "White"
        "WARNING" = "Yellow"
        "ERROR" = "Red"
        "SUCCESS" = "Green"
    }
    
    $logEntry = "[$timestamp] [$Tipo] $Mensaje"
    Add-Content -Path $script:LogFile -Value $logEntry
    
    if ($Tipo -eq "ERROR") {
        Write-Host $logEntry -ForegroundColor Red
    } elseif ($Tipo -eq "SUCCESS") {
        Write-Host $logEntry -ForegroundColor Green
    }
}

# Verificar privilegios de administrador
function Permisos {
    $identidad = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identidad)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Solicitar los permisos si es necesario
function Solicitar-Permisos {
    if (-not (Permisos)) {
        Write-Host "`n Solicitando privilegios de administrador..." -ForegroundColor Yellow
        $scriptPath = $MyInvocation.MyCommand.Path
        $arguments = "-File `"$scriptPath`""
        
        $process = Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments -PassThru
        exit
    }
}

# Banner ASCII
function Mostrar-Banner {
    Clear-Host
    Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    ░▒▓█▓▒░ W·I·N·R·E·S·C·U·E  C·A·L·Y·P·S·U·S ░▒▓█▓▒░        ║
║                       HelpDesk Toolkit                       ║
║                         v1.0                                 ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

    Write-Host ""
    
    # Estado de privilegios
    if (Permisos) {
        Write-Host " MODO ADMINISTRADOR - Funciones completas habilitadas" -ForegroundColor Green
    } else {
        Write-Host " MODO USUARIO - Algunas funciones estarán limitadas" -ForegroundColor Yellow
        Write-Host "   Para funciones completas, ejecute como administrador" -ForegroundColor Gray
    }

    # Info del sistema
    try {
        $equipo = $env:COMPUTERNAME
        $os = (Get-CimInstance Win32_OperatingSystem).Caption
        $build = (Get-CimInstance Win32_OperatingSystem).BuildNumber
        Write-Host "`n $equipo | $os (Build $build)" -ForegroundColor Gray
        Write-Host ("=" * 60) -ForegroundColor DarkGray
    } catch {
        Write-Host " Error obteniendo información del sistema" -ForegroundColor Red
    }
}

Inicializar-Directorios
Escribir-Log "WinRescue Calypsus iniciado - Version 0.2.0" "INFO"
Mostrar-Banner

Write-Host "`nSistema de logging operativo" -ForegroundColor Green
Write-Host "Log actual: $script:LogFile`n" -ForegroundColor Gray


Write-Host "Presiona cualquier tecla para salir..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Escribir-Log "WinRescue Calypsus cerrado" "INFO"
