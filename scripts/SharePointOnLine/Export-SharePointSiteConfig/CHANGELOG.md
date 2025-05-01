# 📜 CHANGELOG

Todas las actualizaciones importantes de este proyecto se documentarán en este archivo.

El formato sigue la convención de [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/) y la semántica de versiones [SemVer](https://semver.org/lang/es/).

---

## [1.0.0] - 2025-05-01

### Añadido
- Script `Export-SharePointSiteConfig.ps1` funcional para extraer y exportar configuración de sitios SharePoint Online.
- Soporte para logs automáticos con `Start-Transcript`.
- Exportación de datos a JSON.
- Validación de existencia del archivo secreto.
- Mapeo de LCID a idioma amigable.
- Clasificación automática del tipo de sitio.
- Soporte para instalación automática de PnP.PowerShell si no está presente.