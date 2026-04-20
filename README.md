# WinRescue Calypsus - HelpDesk Toolkit

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/Version-1.0-blue)
![Windows](https://img.shields.io/badge/Windows-10%2B-0078D6)

**Herramienta profesional para diagnostico, mantenimiento y reparacion de sistemas Windows**

Version: 1.0 | Licencia: MIT | Autor: Yassine Elouakili El Mahdati

## Caracteristicas

| Funcionalidad | Descripcion |
|---------------|-------------|
| Informacion del sistema | CPU, RAM, discos, GPU, servicios |
| Herramientas de red | Ping, traceroute, escaneo de puertos, flush DNS |
| Limpieza y optimizacion | Temporales, cache navegadores, discos |
| Reparacion del sistema | SFC, DISM, Windows Update, permisos |
| Reportes HTML | Diagnostico profesional en formato web |
| Sistema de logs | Trazabilidad completa de operaciones |

## Instalacion

```powershell
git clone https://github.com/yassinelouakili/winrescue-calypsus.git
cd winrescue-calypsus
```

## Uso

Ejecutar PowerShell como Administrador (recomendado):

```powershell
.\WinRescue-Calypsus.ps1
```

## Demo

```
Menu Principal
----------------------------------------
1. Informacion del Sistema
2. Herramientas de Red
3. Limpieza y Optimizacion
4. Reparacion del Sistema
5. Generar Reporte Completo
6. Configuracion
7. Salir
```

![DEMO](imagen/demo.png)
## Requisitos

- Windows 10/11 o Windows Server 2016+
- PowerShell 5.1 o superior

## Estructura

```
WinRescue-Calypsus/
├── WinRescue-Calypsus.ps1              # Script principal
├── Modules/
│   ├── SystemInfo.psm1        # Informacion del sistema
│   ├── RedTools.psm1          # Herramientas de red
│   ├── Cleaner.psm1           # Limpieza y optimizacion
│   ├── RepairOS.psm1          # Reparacion del sistema
│   ├── ReportGenerator.psm1   # Generador de reportes
│   └── ConfigMenu.psm1        # Configuracion
├── Logs/                      # Archivos de log
├── Reports/                   # Reportes generados
├── Backups/                   # Respaldos
├── Imagen                     # Imagenes
├── LICENSE                    # MIT License
└── README.md                  # Documentacion
```

## Autor

**Yassine Elouakili El Mahdati**
- LinkedIn: https://www.linkedin.com/in/yassine-elouakili-el-mahdati-033b56342
- GitHub: https://github.com/yassinelouakili

## Licencia

Distribuido bajo licencia MIT. Ver archivo LICENSE para mas informacion.
