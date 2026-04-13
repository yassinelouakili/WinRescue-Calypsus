# ============================================
# WinRescue Suite - Calypsus HelpDesk Toolkit
# Autor: Yassine Elouakili El Mahdati
# Version: 0.1.0
# Estado: EN DESARROLLO
# ============================================

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    ░▒▓█▓▒░ W·I·N·R·E·S·C·U·E  C·A·L·Y·P·S·U·S ░▒▓█▓▒░        ║
║                    HelpDesk Toolkit                          ║
║                         v0.1.0                               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host "`nProyecto en construccion..." -ForegroundColor Yellow
Write-Host "Proximamente: modulos de diagnostico, red, limpieza y reparacion`n"

New-Item -ItemType Directory -Path ".\Logs" -Force | Out-Null
New-Item -ItemType Directory -Path ".\Reports" -Force | Out-Null
New-Item -ItemType Directory -Path ".\Backups" -Force | Out-Null
New-Item -ItemType Directory -Path ".\Modules" -Force | Out-Null

Write-Host "Estructura de directorios creada" -ForegroundColor Green
Write-Host "Logs/, Reports/, Backups/, Modules/`n" -ForegroundColor Gray

Write-Host "Presiona cualquier tecla para salir..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")