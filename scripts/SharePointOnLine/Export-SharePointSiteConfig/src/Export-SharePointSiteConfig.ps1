<#
.SYNOPSIS
Exporta información detallada de configuración de un sitio de SharePoint Online a un archivo JSON.

.DESCRIPTION
Este script se conecta a un sitio de SharePoint Online utilizando el módulo PnP.PowerShell y extrae información clave del sitio, incluyendo:
- Plantilla aplicada y tipo de sitio
- Configuración regional (zona horaria, idioma)
- Título y URL del sitio

Los datos obtenidos se exportan en formato JSON a una carpeta de salida estructurada, y se genera un log detallado de toda la ejecución, incluyendo advertencias y errores.

La conexión se realiza utilizando autenticación mediante `ClientId`, definido en un archivo de credenciales JSON ubicado en la carpeta `Data\JsonInput`.

Además, el script organiza los archivos de entrada y salida en carpetas específicas (`Data\JsonInput`, `Data\JsonOutput`) y genera un log en `Logs\Export-SharePointSiteConfig_YYYY-MM-DD_HH-MM-SS.log` para auditoría y depuración.

.PARAMETER SiteUrl
URL del sitio de SharePoint Online desde el cual se desea extraer la información. Este parámetro es obligatorio.

.EXAMPLE
.\Export-SharePointSiteConfig.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/Proyectos"

Este ejemplo conecta con el sitio indicado, extrae su configuración y exporta los datos a un archivo JSON, generando también un log de toda la ejecución en la carpeta Logs.

.NOTES
Requisitos:
- El módulo PnP.PowerShell debe estar disponible (el script lo instala si es necesario).
- El archivo de credenciales `secreto.json` debe existir en `Data\JsonInput`, y contener un campo `ClientId`.
- Se requiere conexión interactiva con permisos adecuados en el sitio de SharePoint.

Autor: Xavi Saavedra Alois
Versión: 1.0
Fecha: 2025-05-01
#>



[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SiteUrl
)

# ▓▓▓ Preparación del entorno ▓▓▓

# Directorio base del script (para rutas relativas)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Carpeta de entrada JSON segura (para credenciales)
$InputJsonPath = Join-Path -Path $ScriptDir -ChildPath "Data\JsonInput"

# Carpeta de salida JSON segura (para exportación de datos)
$OutputJsonPath = Join-Path -Path $ScriptDir -ChildPath "Data\JsonOutput"

# Carpetade logs
$LogsPath = Join-Path -Path $ScriptDir -ChildPath "Logs"

# Nombre del log con marca temporal
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogFile = Join-Path -Path $LogsPath -ChildPath "Export-SharePointSiteConfig_$Timestamp.log"

# Crear carpeta de logs si no existe
if (-not (Test-Path -Path $LogsPath)) {
    try {
        New-Item -Path $LogsPath -ItemType Directory -Force | Out-Null
    } catch {
        Write-Warning "No se pudo crear la carpeta Logs: $_"
    }
}

# Iniciar transcripción para log detallado
try {
    Start-Transcript -Path $LogFile -Append -ErrorAction Stop
} catch {
    Write-Warning "❗ No se pudo iniciar el log de transcripción: $_"
}

# Validar existencia del archivo de entrada JSON
$SecretFile = Join-Path -Path $InputJsonPath -ChildPath "secreto.json"
if (-not (Test-Path -Path $SecretFile)) {
    Write-Error "❌ No se encontró el archivo de credenciales: $SecretFile"
    Stop-Transcript | Out-Null
    exit 1
}

# Cargar módulo PnP.PowerShell si no está disponible
if (-not (Get-Module -ListAvailable -Name "PnP.PowerShell")) {
    try {
        Install-Module -Name "PnP.PowerShell" -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
        Write-Host "✅ Módulo PnP.PowerShell instalado correctamente."
    } catch {
        Write-Error "❌ Error al instalar PnP.PowerShell: $_"
        Stop-Transcript | Out-Null
        exit 1
    }
}

Import-Module PnP.PowerShell -ErrorAction Stop

# ▓▓▓ Conexión a SharePoint ▓▓▓

try {
    $Secret = Get-Content $SecretFile | ConvertFrom-Json
    $ClientId = $Secret.ClientId

    Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Interactive
    Write-Host "🔐 Conectado a $SiteUrl correctamente."
} catch {
    Write-Error "❌ Error al conectar a SharePoint: $_"
    Stop-Transcript | Out-Null
    exit 1
}

# ▓▓▓ Obtención de datos del sitio ▓▓▓

try {
    $Web = Get-PnPWeb -Includes WebTemplate, Configuration
    $Ctx = Get-PnPContext

    $Ctx.Load($Web.RegionalSettings)
    $Ctx.Load($Web.RegionalSettings.TimeZone)
    $Ctx.ExecuteQuery()

    if ([string]::IsNullOrEmpty($web.WebTemplate) -or ($null -eq $web.Configuration)) {
        Write-Warning "No se pudo obtener la plantilla del sitio. Valores nulos en WebTemplate o Configuration."
        $templateFull = "#"
    } else {
        $templateFull = "$($web.WebTemplate)#$($web.Configuration)"
    }
    
    # 🧩 Template completo
    # $templateFull = "$($web.WebTemplate)#$($web.Configuration)"
    # Write-host "Plantilla completa: $templateFull"
    # Write-Host "Plantilla: $($web.WebTemplate)"
    # Write-Host "Configuración: $($web.Configuration)"

    
    # $web2 = Get-PnPWeb -Includes WebTemplate, Configuration, TemplateName



    
    Write-Verbose "WebTemplate: $($web.WebTemplate)"
    Write-Verbose "Configuration: $($web.Configuration)"

    
    $TimeZoneId   = $Web.RegionalSettings.TimeZone.Id
    $TimeZoneDesc = $Web.RegionalSettings.TimeZone.Description
    $LCID         = [int]$Web.RegionalSettings.LocaleId

    # Mapa de idioma por LCID
    $LCIDMap = @{
        1033 = "🇺🇸 Inglés (EE.UU.)"
        2057 = "🇬🇧 Inglés (Reino Unido)"
        3082 = "🇪🇸 Español (España)"
        1027 = "🇦🇩 Catalán"
        1036 = "🇫🇷 Francés"
        1040 = "🇮🇹 Italiano"
        1031 = "🇩🇪 Alemán"
        1046 = "🇧🇷 Portugués (Brasil)"
        1049 = "🇷🇺 Ruso"
        1041 = "🇯🇵 Japonés"
        2052 = "🇨🇳 Chino (Simplificado)"
        1025 = "🇸🇦 Árabe"
    }

    $LanguageDisplay = $LCIDMap[$LCID]
    if (-not $LanguageDisplay) {
        $LanguageDisplay = "🏳️ Idioma no definido ($LCID)"
    }

    # Clasificación del tipo de sitio
    $SiteTypes = @{
        "GROUP#0"              = "👥 Sitio de grupo moderno (con M365)"
        "SITEPAGEPUBLISHING#0" = "📢 Sitio de comunicación"
        "STS#3"                = "🧱 Sitio moderno sin grupo"
        "STS#0"                = "📄 Sitio clásico vacío"
    }

    $SiteType = $SiteTypes[$TemplateFull]
    if (-not $SiteType) {
        $SiteType = "⚙️  Otro tipo o personalizado ($TemplateFull)"
    }

    if ($templateFull -eq "#") {
        $tipoSitio = "⚠️ Plantilla no disponible o sitio no identificado correctamente"
    }
    
    # Mostrar resumen en consola
    Write-Output "📋 Información del sitio extraída:"
    Write-Output "──────────────────────────────────────"
    Write-Output "🏷️  Título del sitio      : $($Web.Title)"
    Write-Output "🔗  URL                  : $($Web.Url)"
    Write-Output "🧩  Plantilla aplicada   : $TemplateFull"
    Write-Output "📌  Tipo de sitio        : $SiteType"
    Write-Output "🌐  Idioma (LCID)        : $LCID"
    Write-Output "🈯  Idioma detectado     : $LanguageDisplay"
    Write-Output "🕒  Zona horaria ID      : $TimeZoneId"
    Write-Output "🕓  Descripción zona     : $TimeZoneDesc"
    Write-Output "──────────────────────────────────────"

    # Exportar datos
    $SiteData = @{
        Title        = $Web.Title
        URL          = $Web.Url
        Template     = $TemplateFull
        SiteType     = $SiteType
        LCID         = $LCID
        Language     = $LanguageDisplay
        TimeZoneId   = $TimeZoneId
        TimeZoneDesc = $TimeZoneDesc
    }


# Crear carpeta de salida JSON si no existe
if (-not (Test-Path -Path $OutputJsonPath)) {
    try {
        New-Item -Path $OutputJsonPath -ItemType Directory -Force | Out-Null
    } catch {
        Write-Warning "No se pudo crear la carpeta Logs: $_"
    }
}

    $OutputFile = Join-Path -Path $OutputJsonPath "siteData.json"
    $SiteData | ConvertTo-Json -Depth 3 | Out-File -FilePath $OutputFile

    Write-Output "✅ Los datos del sitio han sido exportados a: $OutputFile"
} catch {
    Write-Error "❌ Error al procesar datos del sitio: $_"
} finally {
    # Finalizar log
    try {
        Stop-Transcript | Out-Null
    } catch {
        Write-Warning "⚠️ No se pudo cerrar la transcripción del log correctamente: $_"
    }
}
