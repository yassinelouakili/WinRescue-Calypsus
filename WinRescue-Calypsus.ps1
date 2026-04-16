# ============================================
# WinRescue Calypsus - HelpDesk Toolkit
# Autor: Yassine Elouakili El Mahdati
# Version: 0.5.0
# Estado: EN DESARROLLO
# ============================================

# Configurar codificación UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null

# ============================================
# WinRescue Calypsus - HelpDesk Toolkit
# Autor: Yassine Elouakili El Mahdati
# Version: 0.5.0
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

# Seguro de Importación de Módulos
function Import-ModuleSafe {
    param (
        [string]$Ruta,
        [string]$Nombre
    )

    try {
        if (-not (Get-Module -Name $Nombre)) {
            if (Test-Path $Ruta) {
                Import-Module $Ruta -Force -ErrorAction Stop
                Escribir-Log "Módulo cargado: $Nombre" "SUCCESS"
                return $true
            } else {
                Escribir-Log "Módulo no encontrado: $Ruta" "ERROR"
                return $false
            }
        }
        return $true
    } catch {
        Escribir-Log "Error cargando módulo ${Nombre}: $_" "ERROR"
        Write-Host "Error cargando módulo $Nombre" -ForegroundColor Red
        return $false
    }
}

function Pause {
    Write-Host "`nPresione Enter para continuar..." -ForegroundColor Gray
    Read-Host
}


# Banner ASCII
function Mostrar-Banner {
    Clear-Host
    Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    ░▒▓█▓▒░ W·I·N·R·E·S·C·U·E  C·A·L·Y·P·S·U·S ░▒▓█▓▒░        ║
║                       HelpDesk Toolkit                       ║
║                         v0.5.0                               ║
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

# Menú Principal
function Mostrar-Menu {
    do {
        Mostrar-Banner

        Write-Host "`n Menú Principal" -ForegroundColor White -BackgroundColor DarkBlue
        Write-Host ("-" * 40) -ForegroundColor DarkGray
        Write-Host " 1. Información del Sistema" -ForegroundColor Cyan
		Write-Host " 2. Herramientas de Red" -ForegroundColor Cyan
		Write-Host " 3. Limpieza y Optimización" -ForegroundColor Cyan
		Write-Host " 4. Reparación del Sistema" -ForegroundColor Cyan
        Write-Host " 0. Salir" -ForegroundColor Cyan
        Write-Host ("-" * 40) -ForegroundColor DarkGray

        $opcion = Read-Host "`n Selecciona una opción [1-0]"

        switch ($opcion) {
            '1' {
                if (Import-ModuleSafe "$PSScriptRoot\Modules\SystemInfo.psm1" "SystemInfo") {
                    Show-SystemMenu
                } else {
                    Write-Host "`n Módulo SystemInfo no encontrado" -ForegroundColor Red
                    Pause
                }
            }
			'2' {
                if (Import-ModuleSafe "$PSScriptRoot\Modules\RedTools.psm1" "RedTools") {
                    Mostrar-RedMenu
                } else {
                    Write-Host "`n Módulo RedTools no encontrado" -ForegroundColor Red
                    Pause
                }
            }
			'3' {
                if (Import-ModuleSafe "$PSScriptRoot\Modules\Cleaner.psm1" "Cleaner") {
                    Mostrar-CleanerMenu
                } else {
                    Write-Host "`n Módulo Cleaner no encontrado" -ForegroundColor Red
                    Pause
                }
            }
			'4' {
                if (Import-ModuleSafe "$PSScriptRoot\Modules\RepairOS.psm1" "RepairOS") {
                    Start-RepairSystem
                } else {
                    Write-Host "`n Módulo RepairOS no encontrado" -ForegroundColor Red
                    Pause
                }
            }
            '0' {
                Escribir-Log "Programa finalizado por el usuario" "INFO"
                Write-Host "`n ¡Gracias por usar WinRescue Calypsus!" -ForegroundColor Green
                Write-Host " Log guardado en: $script:LogFile" -ForegroundColor Gray
                Write-Host "`n Saliendo..." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
                return
            }
            default {
                Write-Host " Opción no válida. Intente de nuevo." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
        
        if ($opcion -ne '0') {
            Write-Host "`n Presione cualquier tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
    } while ($true)
}

# Inicialización
Inicializar-Directorios
Escribir-Log "=== WinRescue Calypsus Iniciado ===" "INFO"
Escribir-Log "Versión: 0.5.0" "INFO"
Escribir-Log "Usuario: $env:USERNAME" "INFO"
Write-Host "Log actual: $script:LogFile`n" -ForegroundColor Gray

# Mostrar menú principal
Mostrar-Menu

Inicializar-Directorios
Escribir-Log "WinRescue Calypsus iniciado - Version 0.2.0" "INFO"
Mostrar-Banner

Write-Host "`nSistema de logging operativo" -ForegroundColor Green
Write-Host "Log actual: $script:LogFile`n" -ForegroundColor Gray


Write-Host "Presiona cualquier tecla para salir..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Escribir-Log "WinRescue Calypsus cerrado" "INFO"