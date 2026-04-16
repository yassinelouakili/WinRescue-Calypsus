# RepairOS.psm1
# Modulo de reparacion del sistema para WinRescue Calypsus

function Repair-SystemFiles {
    Write-Host "`nREPARANDO ARCHIVOS DEL SISTEMA..." -ForegroundColor Cyan
    
	Write-Host "`n  Ejecutando DISM /Online /Cleanup-Image /RestoreHealth..." -ForegroundColor Yellow
    DISM /Online /Cleanup-Image /RestoreHealth
	
    Write-Host "  Ejecutando SFC /SCANNOW..." -ForegroundColor Yellow
    sfc /scannow
    
    
    
    Write-Host "`nReparacion de archivos del sistema completada" -ForegroundColor Green
}

function Reset-NetworkStack {
    Write-Host "`nREINICIANDO PILA DE RED..." -ForegroundColor Cyan
    
    $commands = @(
        "netsh winsock reset",
        "netsh int ip reset",
        "ipconfig /release",
        "ipconfig /renew",
        "ipconfig /flushdns"
    )
    
    foreach ($cmd in $commands) {
        Write-Host "  Ejecutando: $cmd" -ForegroundColor Yellow
        Invoke-Expression $cmd | Out-Null
        Start-Sleep -Milliseconds 500
    }
    
    Write-Host "`nPila de red reiniciada. Se recomienda reiniciar el equipo." -ForegroundColor Green
}

function Repair-WindowsUpdate {
    Write-Host "`nREPARANDO WINDOWS UPDATE..." -ForegroundColor Cyan

    $services = @("Bits", "wuauserv", "appidsvc", "cryptsvc")

    foreach ($service in $services) {
        Write-Host "  Deteniendo servicio: $service" -ForegroundColor Yellow

        # Intento rápido con Stop-Service
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue

        # Forzado con sc.exe (más agresivo)
        sc.exe stop $service | Out-Null

        # Esperar con timeout (evita bucle infinito)
        $timeout = 10
        while ($timeout -gt 0) {
            $status = (Get-Service $service -ErrorAction SilentlyContinue).Status
            if ($status -eq "Stopped") { break }
            Start-Sleep -Seconds 1
            $timeout--
        }
    }

    Start-Sleep -Seconds 2

    Write-Host "  Limpiando cache de Windows Update..." -ForegroundColor Yellow
    Remove-Item -Path "$env:WINDIR\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue

    foreach ($service in $services) {
        Write-Host "  Iniciando servicio: $service" -ForegroundColor Yellow
        Start-Service -Name $service -ErrorAction SilentlyContinue
    }

    Write-Host "`nWindows Update reparado correctamente" -ForegroundColor Green
}


function Start-RepairSystem {
    do {
        Clear-Host
        Write-Host "`nREPARACION DEL SISTEMA" -ForegroundColor Cyan
        Write-Host ("=" * 50) -ForegroundColor DarkGray
        Write-Host ""
        Write-Host " 1. Reparar archivos del sistema (SFC/DISM)"
        Write-Host " 2. Reiniciar pila de red"
        Write-Host " 3. Reparar Windows Update"
        Write-Host " 4. Volver al menu principal"
        Write-Host ""
        Write-Host ("=" * 50) -ForegroundColor DarkGray
        
        $option = Read-Host "Seleccione una opcion"
        
        switch ($option) {
            '1' { Repair-SystemFiles; pause }
            '2' { Reset-NetworkStack; pause }
            '3' { Repair-WindowsUpdate; pause }
            '4' { return }
            default { 
                Write-Host "Opcion no valida" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    } while ($true)
}

Export-ModuleMember -Function Start-RepairSystem, Repair-SystemFiles, Reset-NetworkStack, Repair-WindowsUpdate