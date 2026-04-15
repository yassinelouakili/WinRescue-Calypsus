# SystemInfo.psm1
# Módulo de información del sistema

function Get-SystemInfo {
    Write-Host "`nRECOPILANDO INFORMACIÓN DEL SISTEMA..." -ForegroundColor Cyan
    Write-Host ("=" * 50) -ForegroundColor DarkGray
    
    # Información del Sistema Operativo
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Host "`nSISTEMA OPERATIVO:" -ForegroundColor Yellow
    Write-Host "   Nombre: $($os.Caption)"
    Write-Host "   Versión: $($os.Version)"
    Write-Host "   Build: $($os.BuildNumber)"
    Write-Host "   Instalación: $($os.InstallDate)"
    Write-Host "   Último boot: $($os.LastBootUpTime)"
    
    # Información del Procesador
    $cpu = Get-CimInstance Win32_Processor
    Write-Host "`nPROCESADOR:" -ForegroundColor Yellow
    Write-Host "   Modelo: $($cpu.Name)"
    Write-Host "   Núcleos: $($cpu.NumberOfCores)"
    Write-Host "   Hilos: $($cpu.NumberOfLogicalProcessors)"
    Write-Host "   Velocidad: $($cpu.MaxClockSpeed) MHz"
    
    # Información de Memoria RAM
    $mem = Get-CimInstance Win32_ComputerSystem
    $totalRAM = [math]::Round($mem.TotalPhysicalMemory / 1GB, 2)
    Write-Host "`nMEMORIA RAM:" -ForegroundColor Yellow
    Write-Host "   Total: $totalRAM GB"
    
    # RAM disponible
    $osMem = Get-CimInstance Win32_OperatingSystem
    $freeRAM = [math]::Round($osMem.FreePhysicalMemory / 1MB, 2)
    $usedRAM = [math]::Round(($totalRAM * 1024) - $freeRAM, 2)
    Write-Host "   Usada: $usedRAM MB"
    Write-Host "   Libre: $freeRAM MB"
    
    # Información de Discos
    Write-Host "`nALMACENAMIENTO:" -ForegroundColor Yellow
    $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
    foreach ($disk in $disks) {
        $sizeGB = [math]::Round($disk.Size / 1GB, 2)
        $freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
        $usedGB = $sizeGB - $freeGB
        $percentFree = [math]::Round(($freeGB / $sizeGB) * 100, 2)
        Write-Host "   Unidad $($disk.DeviceID):"
        Write-Host "     - Tamaño: $sizeGB GB"
        Write-Host "     - Usado: $usedGB GB"
        Write-Host "     - Libre: $freeGB GB ($percentFree`% libre)"
        
        if ($percentFree -lt 10) {
            Write-Host "       ¡ESPACIO CRÍTICO!" -ForegroundColor Red
        } elseif ($percentFree -lt 20) {
            Write-Host "       Espacio bajo" -ForegroundColor Yellow
        }
    }
    
    # Información de Red
    Write-Host "`nRED:" -ForegroundColor Yellow
    $adapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
    foreach ($adapter in $adapters) {
        $ipConfig = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4
        Write-Host "   $($adapter.Name):"
        Write-Host "     - IP: $($ipConfig.IPAddress)"
        Write-Host "     - MAC: $($adapter.MacAddress)"
    }
    
    # Información de GPU
    Write-Host "`nGRÁFICOS:" -ForegroundColor Yellow
    $gpu = Get-CimInstance Win32_VideoController | Where-Object {$_.Name -notlike "*Remote*"}
    foreach ($video in $gpu) {
        $vram = [math]::Round($video.AdapterRAM / 1GB, 2)
        Write-Host "   $($video.Name)"
        Write-Host "     - VRAM: $vram GB"
        Write-Host "     - Resolución: $($video.CurrentHorizontalResolution)x$($video.CurrentVerticalResolution)"
    }
}

function Get-SystemServices {
    Write-Host "`nSERVICIOS CRÍTICOS:" -ForegroundColor Cyan
    Write-Host ("=" * 50) -ForegroundColor DarkGray
    
    $criticalServices = @("WinDefend", "W32Time", "Spooler", "Dhcp", "Dnscache")
    
    foreach ($serviceName in $criticalServices) {
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($service) {
            $status = $service.Status
            $statusSymbol = if ($status -eq "Running") { "✓" } else { "✗" }
            $statusColor = if ($status -eq "Running") { "Green" } else { "Red" }
            Write-Host "   $statusSymbol $($service.DisplayName): " -NoNewline
            Write-Host "$status" -ForegroundColor $statusColor
        }
    }
}

function Show-SystemMenu {
    do {
        Clear-Host
        Write-Host "`nINFORMACIÓN DEL SISTEMA" -ForegroundColor Cyan
        Write-Host ("=" * 50) -ForegroundColor DarkGray
        Write-Host " 1. Información completa del sistema"
        Write-Host " 2. Servicios críticos"
        Write-Host " 3. Exportar todo a archivo"
        Write-Host " 4. Volver al menú principal"
        Write-Host ("=" * 50) -ForegroundColor DarkGray
        
        $option = Read-Host "`nSeleccione una opción"
        
        switch ($option) {
            '1' { 
                Get-SystemInfo
                Read-Host "Presione Enter para continuar"
            }
            '2' { 
                Get-SystemServices
                Read-Host "Presione Enter para continuar"
            }
            '3' { 
                $output = "$PSScriptRoot\..\Reports\SystemInfo_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
                Get-SystemInfo | Out-File -FilePath $output
                Write-Host "`nReporte guardado en: $output" -ForegroundColor Green
                Read-Host "Presione Enter para continuar"
            }
            '4' { return }
            default { 
                Write-Host "Opción inválida" -ForegroundColor Red
                Start-Sleep 1
            }
        }
    } while ($true)
}

Export-ModuleMember -Function Show-SystemMenu, Get-SystemInfo, Get-SystemServices