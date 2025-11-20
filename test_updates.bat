# Script para probar actualizaciones
# Ejecutar desde la raíz del proyecto

echo "🔄 Probando sistema de actualizaciones..."

# Verificar que las dependencias estén instaladas
flutter pub get

# Verificar análisis estático
flutter analyze

# Construir APK de prueba
flutter build apk --debug

# Verificar que el APK se creó
if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
    echo "✅ APK generado exitosamente"
    echo "📱 APK listo para subir a Google Drive"
    echo "🔗 URL de descarga configurada: https://drive.google.com/uc?export=download&id=1aBAfygVV6SY5tLC3JSmNEMSBYfDbn8va"
else
    echo "❌ Error al generar APK"
    exit 1
fi

echo "🎉 Sistema de actualizaciones listo para usar!"