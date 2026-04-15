# RedTools.psm1
# Herramientas de red


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

function Test-Conectividad {
    param(
        [string]$Hostname = "google.com",
        [int]$Count = 4
    )
    
    Write-Host "`nProbando conectividad con $Hostname..." -ForegroundColor Cyan
    $result = Test-Connection -ComputerName $Hostname -Count $Count -ErrorAction SilentlyContinue
    
    if ($result) {
        $avgTime = ($result | Measure-Object -Property ResponseTime -Average).Average
        Write-Host "Conexión exitosa" -ForegroundColor Green
        Write-Host "  Tiempo promedio: $avgTime ms"
        Write-Host "  Paquetes enviados: $Count"
        Write-Host "  Paquetes perdidos: $(($result | Where-Object {$_.StatusCode -ne 0}).Count)"
    } else {
        Write-Host "No se pudo conectar a $Hostname" -ForegroundColor Red
    }
}

function Get-RedInfo {
    Write-Host "`nINFORMACIÓN DE RED DETALLADA:" -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor DarkGray
    
    # Obtener IP pública
    try {
        $publicIP = Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5
        Write-Host "`nIP Pública: $publicIP" -ForegroundColor Yellow
    } catch {
        Write-Host "`nIP Pública: No disponible" -ForegroundColor Red
    }
    
    # Tabla de rutas
    Write-Host "`nTABLA DE RUTAS:" -ForegroundColor Yellow
    Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object InterfaceAlias, NextHop, RouteMetric | Format-Table -AutoSize
    
    # Conexiones activas
    Write-Host "`nCONEXIONES ACTIVAS:" -ForegroundColor Yellow
    Get-NetTCPConnection -State Established | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess | Format-Table -AutoSize
    
    # DNS configurado
    Write-Host "`nSERVICIOS DNS:" -ForegroundColor Yellow
    $dnsServers = Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object {$_.ServerAddresses}
    foreach ($dns in $dnsServers) {
        Write-Host "  $($dns.InterfaceAlias): $($dns.ServerAddresses -join ', ')"
    }
}

function Test-PortScan {
    param(
        [string]$Hostname,
        [int[]]$Ports = @(80, 443, 22, 3389, 21, 25)
    )
    
    Write-Host "`nESCANEO DE PUERTOS - $Hostname" -ForegroundColor Cyan
    Write-Host ("=" * 50) -ForegroundColor DarkGray
    
    foreach ($port in $Ports) {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $result = $tcp.BeginConnect($Hostname, $port, $null, $null)
        $wait = $result.AsyncWaitHandle.WaitOne(1000, $false)
        
        if ($wait) {
            Write-Host "  Puerto $port - ABIERTO" -ForegroundColor Green
        } else {
            Write-Host "  Puerto $port - CERRADO" -ForegroundColor Red
        }
        $tcp.Close()
    }
}

function Flush-DNS {
    Write-Host "`nLIMPIANDO CACHE DNS..." -ForegroundColor Cyan
    try {
        ipconfig /flushdns | Out-Null
        Write-Host "Cache DNS limpiado exitosamente" -ForegroundColor Green
    } catch {
        Write-Host "Error limpiando cache DNS" -ForegroundColor Red
    }
}

function Renew-IPAddress {
    Write-Host "`nRENOVANDO DIRECCIÓN IP..." -ForegroundColor Cyan
    try {
        ipconfig /release | Out-Null
        Start-Sleep -Seconds 2
        ipconfig /renew | Out-Null
        Write-Host "IP renovada exitosamente" -ForegroundColor Green
    } catch {
        Write-Host "Error renovando IP" -ForegroundColor Red
    }
}

function Mostrar-RedMenu {
    do {
        Clear-Host
        Write-Host "`nHERRAMIENTAS DE RED" -ForegroundColor Cyan
        Write-Host ("=" * 50) -ForegroundColor DarkGray
        Write-Host " 1. Información completa de red"
        Write-Host " 2. Probar conectividad (Google)"
        Write-Host " 3. Escanear puertos comunes"
        Write-Host " 4. Limpiar cache DNS"
        Write-Host " 5. Renovar IP (DHCP)"
        Write-Host " 6. Realizar traceroute"
        Write-Host " 7. Volver al menú principal"
        Write-Host ("=" * 50) -ForegroundColor DarkGray
        
        $option = Read-Host "`nSeleccione una opción"
        
        switch ($option) {
            '1' { 
                Get-RedInfo
                Pause
            }
            '2' { 
                $hostname = Read-Host "Host a probar [google.com]"
                if ([string]::IsNullOrWhiteSpace($hostname)) { $hostname = "google.com" }
                Test-Conectividad -Hostname $hostname
                Pause
            }
            '3' { 
                $hostname = Read-Host "Host a escanear"
                if (-not [string]::IsNullOrWhiteSpace($hostname)) {
                    Test-PortScan -Hostname $hostname
                }
                Pause
            }
            '4' { 
                Flush-DNS
                Pause
            }
            '5' { 
                if (Permisos) {
                    Renew-IPAddress
                } else {
                    Write-Host "⚠ Esta función requiere privilegios de administrador" -ForegroundColor Yellow
                }
                Pause
            }
            '6' { 
                $hostname = Read-Host "Destino para traceroute"
                if (-not [string]::IsNullOrWhiteSpace($hostname)) {
                    tracert $hostname
                }
                Pause
            }
            '7' { return }
            default { 
                Write-Host "Opción inválida" -ForegroundColor Red
                Start-Sleep 1
            }
        }
    } while ($true)
}

Export-ModuleMember -Function Mostrar-RedMenu, Test-Conectividad, Get-RedInfo, Test-PortScan, Flush-DNS, Renew-IPAddress