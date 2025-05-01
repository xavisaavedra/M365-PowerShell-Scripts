# 🤝 Guía de Contribución

¡Gracias por tu interés en contribuir a este proyecto!

## 🛠️ Requisitos técnicos

- PowerShell 7.2 o superior.
- Módulo [`PnP.PowerShell`](https://pnp.github.io/powershell/).
- Conocimientos básicos en administración de SharePoint Online.
- Seguir las convenciones de nombres en **español claro y descriptivo**.

## 📁 Estructura del proyecto

- `/src`: Scripts principales.
- `/data/JsonInput`: Datos sensibles como secretos (excluidos del repositorio).
- `/data/JsonOutput`: Archivos de salida del script.
- `/logs`: Archivos generados automáticamente.
- `/modules`: Módulos reutilizables si se separan funciones.
- `/tests`: Scripts de prueba o validación.
- `/docs`: Documentación extendida.

## 🚦 Cómo contribuir

1. **Fork** del repositorio.
2. Crear una rama: `git checkout -b feature/NuevaFuncionalidad`
3. Realiza tus cambios y escribe comentarios claros.
4. Asegúrate de que el script no genere errores.
5. Realiza un pull request con una descripción clara del cambio.

## 🧼 Convenciones de estilo

- Nombres de variables descriptivos y en español (`$RutaSalida`, `$DatosSitio`).
- Comentarios útiles y estructurados.
- Usa `Write-Output` para resultados informativos, `Write-Host` para mensajes, y `Write-Error`/`Write-Warning` según contexto.
- Evita funciones anidadas o complejas si no es necesario.

## 📦 Licencia

Este proyecto está cubierto por la licencia MIT. Asegúrate de respetarla en cualquier contribución.