@echo off
echo ==========================================
echo DEPLOY A GOOGLE DRIVE - Solo APK y Version
echo ==========================================
echo 1. Construyendo APK...
echo ==========================================
call flutter build apk --debug

echo.
echo ==========================================
echo 2. Copiando APK y version.json a Google Drive...
echo ==========================================

:: RUTA ORIGEN (Esta es la ruta por defecto de Flutter)
set ORIGEN="build\app\outputs\flutter-apk\app-debug.apk"

:: RUTA DESTINO (Tu carpeta de Google Drive en tu PC)
set DESTINO="G:\Mi unidad\Apk-test\saray.apk"

:: Copiar APK
copy /Y %ORIGEN% %DESTINO%

:: Copiar también el JSON
copy /Y "version.json" "G:\Mi unidad\Apk-test\version.json"

echo.
echo ==========================================
echo ¡DEPLOY COMPLETADO!
echo ✅ APK construido exitosamente
echo ✅ Archivos copiados a Google Drive
echo Google Drive está sincronizando automáticamente...
echo ==========================================