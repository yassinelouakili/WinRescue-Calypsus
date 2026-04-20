# ConfigMenu.psm1
# Menú de configuración
# Configuración Global
$script:RutaLogs = "$PSScriptRoot\Logs"
$script:RutaReports = "$PSScriptRoot\Reports"
$script:RutaBackups = "$PSScriptRoot\Backups"
$script:LogFile = "$script:RutaLogs\WinRescue_$(Get-Date -Format 'yyyyMMdd').log"



function Show-ConfigMenu {
    do {
        Clear-Host
        Write-Host "`nCONFIGURACIÓN" -ForegroundColor Cyan
        Write-Host ("=" * 50) -ForegroundColor DarkGray
        Write-Host " 1. Ver configuración actual"
        Write-Host " 2. Limpiar logs"
        Write-Host " 3. Ver tamaño de logs"
        Write-Host " 4. Exportar configuración"
        Write-Host " 5. Acerca de"
        Write-Host " 6. Volver al menú principal"
        Write-Host ("=" * 50) -ForegroundColor DarkGray
        
        $option = Read-Host "`nSeleccione una opción"
        
        switch ($option) {
            '1' { 
                Write-Host "`nCONFIGURACIÓN ACTUAL:" -ForegroundColor Yellow
                Write-Host "  Ruta de logs: $script:RutaLogs"
                Write-Host "  Ruta de reports: $script:RutaReports"
                Write-Host "  Ruta de backups: $script:RutaBackups"
                Write-Host "  Archivo de log actual: $script:LogFile"
                Pause
            }
            '2' { 
                $confirm = Read-Host "¿Está seguro de limpiar todos los logs? (S/N)"
                if ($confirm -eq 'S' -or $confirm -eq 's') {
                    Remove-Item "$script:RutaLogs\*" -Force -ErrorAction SilentlyContinue
                    Write-Host "Logs limpiados" -ForegroundColor Green
                }
                Pause
            }
            '3' { 
                $logFiles = Get-ChildItem $script:RutaLogs -Filter "*.log" -ErrorAction SilentlyContinue
                $totalSize = ($logFiles | Measure-Object -Property Length -Sum).Sum
                $totalSizeMB = [math]::Round($totalSize / 1MB, 2)
                Write-Host "`nTAMAÑO DE LOGS:" -ForegroundColor Yellow
                Write-Host "  Número de archivos: $($logFiles.Count)"
                Write-Host "  Tamaño total: $totalSizeMB MB"
                Pause
            }
            '4' { 
                $configPath = "$PSScriptRoot\..\config.json"
                $config = @{
                    Version = "1.0"
                    LogPath = $script:RutaLogs
                    ReportPath = $script:RutaReports
                    BackupPath = $script:RutaBackups
                    LastRun = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                } | ConvertTo-Json
                $config | Out-File -FilePath $configPath -Encoding UTF8
                Write-Host "Configuración exportada a: $configPath" -ForegroundColor Green
                Pause
            }
            '5' { 
                Write-Host @"
`n═══════════════════════════════════════════════
     WINRESCUE CALYPSUS - HELPDESK TOOLKIT
═══════════════════════════════════════════════

Autor: Yassine Elouakili El Mahdati
Versión: 1.0
Licencia: MIT

Descripción:
Herramienta completa para diagnóstico, mantenimiento
y reparación de sistemas Windows.

Características:
• Información detallada del sistema
• Herramientas de red profesionales
• Limpieza y optimización
• Reparación del sistema
• Generación de reportes HTML

GitHub: https://github.com/yassinelouakili/winrescue-calypsus
LinkedIn: https://www.linkedin.com/in/yassine-elouakili-el-mahdati-033b56342

═══════════════════════════════════════════════
"@ -ForegroundColor Cyan
                Pause
            }
            '6' { return }
            default { 
                Write-Host "Opción inválida" -ForegroundColor Red
                Start-Sleep 1
            }
        }
    } while ($true)
}

Export-ModuleMember -Function Show-ConfigMenu