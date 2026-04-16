# Cleaner.psm1
# Limpieza y optimización del sistema

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

function Clear-TempFiles {
    Write-Host "`nLIMPIANDO ARCHIVOS TEMPORALES..." -ForegroundColor Cyan
    
    $tempPaths = @(
        "$env:TEMP\*",
        "$env:WINDIR\Temp\*",
        "$env:WINDIR\Prefetch\*",
        "$env:APPDATA\Microsoft\Windows\Recent\*"
    )
    
    $totalFreed = 0
    
    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            $files = Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue
            $sizeBefore = ($files | Measure-Object -Property Length -Sum).Sum
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            $sizeAfter = (Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            $freed = $sizeBefore - $sizeAfter
            $totalFreed += $freed
            
            if ($freed -gt 0) {
                $freedMB = [math]::Round($freed / 1MB, 2)
                Write-Host "  Solicitar-Permisos$([System.IO.Path]::GetDirectoryName($path)): $freedMB MB liberados" -ForegroundColor Green
            }
        }
    }
    
    $totalFreedGB = [math]::Round($totalFreed / 1GB, 2)
    Write-Host "`nTotal liberado: $totalFreedGB GB" -ForegroundColor Green
}

function Clear-NavegadorCache {
    Write-Host "`nLIMPIANDO CACHE DEL NAVEGADOR..." -ForegroundColor Cyan
    
    # Chrome
    $chromePaths = @(
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache\*"
    )
    
    # Edge
    $edgePaths = @(
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache\*"
    )
    
    $allPaths = $chromePaths + $edgePaths
    
    foreach ($path in $allPaths) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  Limpiado: $path" -ForegroundColor Green
        }
    }
}

function Optimize-Drives {
    Write-Host "`nOPTIMIZANDO UNIDADES..." -ForegroundColor Cyan
    
    $drives = Get-PhysicalDisk | Where-Object {$_.MediaType -eq "HDD"}
    
    foreach ($drive in $drives) {
        $driveLetter = $drive | Get-Disk | Get-Partition | Get-Volume | Select-Object -ExpandProperty DriveLetter
        if ($driveLetter) {
            Write-Host "  Optimizando unidad $($driveLetter):..."
            Optimize-Volume -DriveLetter $driveLetter -Defrag -Verbose -ErrorAction SilentlyContinue
        }
    }
}

function Eliminar-AntiguosPuntosRestauracion {
    Write-Host "`nELIMINANDO PUNTOS DE RESTAURACIÓN ANTIGUOS..." -ForegroundColor Cyan
    
    try {
        $restorePoints = Get-ComputerRestorePoint | Sort-Object -Property CreationTime -Descending
        $keepCount = 3
        
        if ($restorePoints.Count -gt $keepCount) {
            $toDelete = $restorePoints | Select-Object -Skip $keepCount
            foreach ($point in $toDelete) {
                Remove-ComputerRestorePoint -RestorePoint $point.SequenceNumber
                Write-Host "  Eliminado punto del $($point.CreationTime)" -ForegroundColor Green
            }
        }
        Write-Host "Mantenidos los últimos $keepCount puntos de restauración" -ForegroundColor Green
    } catch {
        Write-Host "No se pudieron eliminar puntos de restauración" -ForegroundColor Yellow
    }
}

function Mostrar-CleanerMenu {
    do {
        Clear-Host
        Write-Host "`nLIMPIEZA Y OPTIMIZACIÓN" -ForegroundColor Cyan
        Write-Host ("=" * 50) -ForegroundColor DarkGray
        Write-Host " 1. Limpiar archivos temporales"
        Write-Host " 2. Limpiar cache de navegadores"
        Write-Host " 3. Optimizar discos duros"
        Write-Host " 4. Eliminar puntos de restauración antiguos"
        Write-Host " 5. Limpieza completa (todo)"
        Write-Host " 6. Volver al menú principal"
        Write-Host ("=" * 50) -ForegroundColor DarkGray
        
        $option = Read-Host "`nSeleccione una opción"
        
        switch ($option) {
            '1' { 
                Clear-TempFiles
                Pause
            }
            '2' { 
                Clear-NavegadorCache
                Pause
            }
            '3' { 
                if (Permisos) {
                    Optimize-Drives
                } else {
                    Write-Host "Esta función requiere privilegios de administrador" -ForegroundColor Yellow
                }
                Pause
            }
            '4' { 
                Eliminar-AntiguosPuntosRestauracion
                Pause
            }
            '5' { 
                Clear-TempFiles
                Clear-NavegadorCache
                if (Permisos) {
                    Optimize-Drives
                    Eliminar-AntiguosPuntosRestauracion
                }
                Write-Host "`nLimpieza completa finalizada" -ForegroundColor Green
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

Export-ModuleMember -Function Mostrar-CleanerMenu, Clear-TempFiles, Clear-NavegadorCache, Optimize-Drives, Eliminar-AntiguosPuntosRestauracion