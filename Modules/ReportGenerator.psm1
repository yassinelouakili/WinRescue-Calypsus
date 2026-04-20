# ReportGenerator.psm1
# Generador de reportes

function Generate-FullReport {
    Write-Host "`nGENERANDO REPORTE COMPLETO..." -ForegroundColor Cyan
    
    $reportDate = Get-Date -Format "yyyyMMdd_HHmmss"
    $reportPath = "$PSScriptRoot\..\Reports\WinRescue_Report_$reportDate.html"
    $computerName = $env:COMPUTERNAME
    $username = $env:USERNAME
    
    # Recolectar datos
    Write-Host "  Recolectando información del sistema..." -ForegroundColor Yellow
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $mem = Get-CimInstance Win32_ComputerSystem
    $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
    $services = Get-Service | Where-Object {$_.Status -eq "Running"}
    
    # Crear HTML
    $html = @"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WinRescue Calypsus Report - $computerName</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: auto;
            background-color: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        h2 {
            color: #34495e;
            margin-top: 20px;
            background-color: #ecf0f1;
            padding: 10px;
            border-radius: 5px;
        }
        .info-box {
            background-color: #ecf0f1;
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 10px 0;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #3498db;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        .status-good {
            color: green;
            font-weight: bold;
        }
        .status-warning {
            color: orange;
            font-weight: bold;
        }
        .status-critical {
            color: red;
            font-weight: bold;
        }
        .footer {
            margin-top: 30px;
            text-align: center;
            font-size: 12px;
            color: #7f8c8d;
            border-top: 1px solid #ddd;
            padding-top: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>WinRescue Calypsus - Reporte del Sistema</h1>
        <div class="info-box">
            <strong>Equipo:</strong> $computerName<br>
            <strong>Usuario:</strong> $username<br>
            <strong>Fecha:</strong> $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")<br>
            <strong>Reporte generado por:</strong> WinRescue Calypsus HelpDesk Toolkit v2.0
        </div>
        
        <h2>Sistema Operativo</h2>
        <table>
            <tr><th>Propiedad</th><th>Valor</th></tr>
            <tr><td>Nombre</td><td>$($os.Caption)</td></tr>
            <tr><td>Versión</td><td>$($os.Version)</td></tr>
            <tr><td>Build</td><td>$($os.BuildNumber)</td></tr>
            <tr><td>Instalación</td><td>$($os.InstallDate)</td></tr>
            <tr><td>Último boot</td><td>$($os.LastBootUpTime)</td></tr>
        </table>
        
        <h2>Procesador</h2>
        <table>
            <tr><th>Propiedad</th><th>Valor</th></tr>
            <tr><td>Modelo</td><td>$($cpu.Name)</td></tr>
            <tr><td>Núcleos</td><td>$($cpu.NumberOfCores)</td></tr>
            <tr><td>Hilos</td><td>$($cpu.NumberOfLogicalProcessors)</td></tr>
            <tr><td>Velocidad</td><td>$($cpu.MaxClockSpeed) MHz</td></tr>
        </table>
        
        <h2>Memoria RAM</h2>
        <table>
            <tr><th>Propiedad</th><th>Valor</th></tr>
            <tr><td>Total</td><td>$([math]::Round($mem.TotalPhysicalMemory / 1GB, 2)) GB</td></tr>
        </table>
        
        <h2>Almacenamiento</h2>
        <table>
            <tr><th>Unidad</th><th>Tamaño Total</th><th>Espacio Libre</th><th>Porcentaje Libre</th><th>Estado</th></tr>
"@
    
    foreach ($disk in $disks) {
        $sizeGB = [math]::Round($disk.Size / 1GB, 2)
        $freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
        $percentFree = [math]::Round(($freeGB / $sizeGB) * 100, 2)
        $status = if ($percentFree -lt 10) { "Crítico" } elseif ($percentFree -lt 20) { "Advertencia" } else { "Bueno" }
        $statusClass = if ($percentFree -lt 10) { "status-critical" } elseif ($percentFree -lt 20) { "status-warning" } else { "status-good" }
        
        $html += @"
            <tr>
                <td>$($disk.DeviceID)</td>
                <td>$sizeGB GB</td>
                <td>$freeGB GB</td>
                <td>$percentFree%</td>
                <td class="$statusClass">$status</td>
            </tr>
"@
    }
    
    $html += @"
        </table>
        
        <h2>Servicios en Ejecución</h2>
        <p>Total de servicios activos: $($services.Count)</p>
        
        <div class="footer">
            <p>WinRescue Calypsus -  HelpDesk Toolkit | Generado automáticamente</p>
            <p>Yassine Elouakili El Mahdati - v1.0</p>
        </div>
    </div>
</body>
</html>
"@
    
    # Guardar reporte
    $html | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Host "Reporte generado exitosamente" -ForegroundColor Green
    Write-Host "Ubicación: $reportPath" -ForegroundColor Yellow
    
    # Preguntar si quiere abrirlo
    $open = Read-Host "`n¿Desea abrir el reporte ahora? (S/N)"
    if ($open -eq 'S' -or $open -eq 's') {
        Start-Process $reportPath
    }
}

Export-ModuleMember -Function Generate-FullReport