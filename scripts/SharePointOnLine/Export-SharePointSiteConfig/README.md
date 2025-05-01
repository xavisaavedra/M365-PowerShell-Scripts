# Export-SharePointSiteConfig.ps1

Exporta la configuración principal de un sitio de SharePoint Online a un archivo JSON estructurado. Ideal para análisis, auditorías, documentación técnica y automatización de inventarios.

## 📋 Descripción

Este script en PowerShell se conecta a un sitio de SharePoint Online utilizando `PnP.PowerShell`, y exporta información clave como:

- Título y URL del sitio
- Plantilla de sitio aplicada y tipo (grupo moderno, comunicación, clásico, etc.)
- Idioma del sitio y configuración regional (zona horaria, LCID)
- Tipo de sitio clasificado de forma descriptiva
- Exportación de datos a un archivo JSON
- Registro de logs detallados con transcripción completa

Organiza los archivos de entrada y salida en carpetas seguras (`Data\JsonInput`, `Data\JsonOutput`) y genera un log con marca temporal en la carpeta `Logs`.

---

## 📁 Tabla de contenido

- [Instalación](#instalación)
- [Uso](#uso)
- [Ejemplo de salida](#ejemplo-de-salida)
- [Requisitos](#requisitos)
- [Créditos](#créditos)
- [Licencia](#licencia)

---

## ⚙️ Instalación

1. Clona este repositorio o descarga el script `Export-SharePointSiteConfig.ps1`.
2. Crea las siguientes carpetas si no existen:

```
Data\JsonInput
Data\JsonOutput
Logs
```

3. Coloca un archivo `secreto.json` en `Data\JsonInput` con el siguiente contenido:

```json
{
  "ClientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

Este `ClientId` debe estar registrado como aplicación en Azure AD con permisos a SharePoint.

---

## 🚀 Uso

Ejecuta el script desde PowerShell:

```powershell
.\Export-SharePointSiteConfig.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/Proyectos"
```

Esto generará:

- Un archivo `siteData.json` con los datos extraídos en `Data\JsonOutput`
- Un archivo de log en `Logs` con todos los eventos, errores y advertencias

---

## 📦 Ejemplo de salida

```json
{
  "Title": "Proyectos",
  "URL": "https://contoso.sharepoint.com/sites/Proyectos",
  "Template": "GROUP#0",
  "SiteType": "👥 Sitio de grupo moderno (con M365)",
  "LCID": 3082,
  "Language": "🇪🇸 Español (España)",
  "TimeZoneId": 4,
  "TimeZoneDesc": "(UTC+01:00) Bruselas, Copenhague, Madrid, París"
}
```

---

## ✅ Requisitos

- PowerShell 7.x o Windows PowerShell 5.1
- Módulo [PnP.PowerShell](https://pnp.github.io/powershell/)
  - El script instalará automáticamente el módulo si no está presente
- Permisos para conectarse al sitio de SharePoint
- Registro de aplicación con `ClientId` válido

---

## 👨‍💻 Créditos

Script desarrollado por **Xavi Saavedra Alois**  
Especialista en M365, SharePoint Online y automatización con PowerShell.

---

## 📝 Licencia

Distribuido bajo la licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---

© 2025 Xavi Saavedra Alois
