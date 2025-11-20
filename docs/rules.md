# Reglas del Proyecto "Saray"

Aquí se guardarán las reglas específicas que se vayan definiendo para el desarrollo de la app. Por ahora, está vacío. Agrega reglas aquí a medida que se definan.

## Regla 1: Manejo de Errores en Español
Si copio y te pego los errores (como diagnósticos de Dart/Flutter o cualquier otro tipo), siempre responde en español explicando:
- Por qué ocurre el error.
- La solución para repararlo.

## Regla 3: Proceso de Deployment - USAR deploy.bat EXCLUSIVAMENTE
**CRÍTICO - PROCESO OBLIGATORIO:** Para cualquier deployment, actualización o distribución de la app a testers, **DEBE usarse exclusivamente el script `deploy.bat`** ubicado en la raíz del proyecto. **NO se deben ejecutar comandos manuales de `flutter build apk --release`** ni ningún otro comando de build individual.

**Proceso correcto:**
1. Ejecutar `./deploy.bat` desde la raíz del proyecto
2. El script automáticamente:
   - Hace build en modo release
   - Optimiza el APK
   - Copia el APK a la carpeta de Google Drive configurada
   - Prepara la distribución para testers

**Prohibido:**
- ❌ `flutter build apk --release`
- ❌ Builds manuales de cualquier tipo
- ❌ Copias manuales de archivos APK

**Motivo:** El script `deploy.bat` incluye optimizaciones específicas, configuraciones de Google Drive y automatización completa del proceso de distribución OTA.