# BugTatsu Sec

Aplicación móvil en Flutter de **BugTatsu Sec**, la versión móvil de mi portafolio de ciberseguridad ofensiva ([portafolio.bugtatsu.xyz](https://portafolio.bugtatsu.xyz)). Muestra reportes de seguridad en formato de catálogo, únicamente con información pública y de alto nivel (sin pasos de reproducción), siguiendo la práctica de divulgación responsable.

Es la evolución de la Actividad Integradora 1 (*Security Portfolio*): se aplicó un rebranding completo y se agregaron servicios nativos.

## Identidad del proyecto

| | |
|---|---|
| Nombre comercial | **BugTatsu Sec** |
| Android `applicationId` | `com.bugtatsu.sec` |
| iOS bundle identifier | `com.bugtatsu.sec` |
| Gestor de estado | Provider |
| Tema | Oscuro tipo terminal (`lib/core/app_theme.dart`) |

Icono y *splash screen* propios generados desde `assets/branding/` con `flutter_launcher_icons` y `flutter_native_splash`.

## Servicios nativos

| Servicio | Qué hace | Código |
|---|---|---|
| Conectividad | Detecta en tiempo real si hay internet (Stream) y muestra un banner *offline* sobre cualquier pantalla. | [`connectivity_service.dart`](lib/services/connectivity_service.dart), [`offline_banner.dart`](lib/widgets/offline_banner.dart) |
| Caché local | Las solicitudes de contacto se guardan primero en el dispositivo y se envían al recuperar la conexión. | [`requests_repository.dart`](lib/repositories/requests_repository.dart), [`requests_provider.dart`](lib/providers/requests_provider.dart) |
| Cámara, galería y permisos | Pide el permiso de cámara en tiempo de ejecución y maneja los casos concedido, denegado y bloqueado. | [`permission_service.dart`](lib/services/permission_service.dart), [`evidence_provider.dart`](lib/providers/evidence_provider.dart) |
| Recorte y compresión | La foto se recorta en cuadrado y se comprime a JPEG en un *isolate* (sin congelar la interfaz). | [`image_service.dart`](lib/services/image_service.dart) |
| Notificaciones locales | Canal nativo de Android y soporte iOS para alertas locales. | [`notification_service.dart`](lib/services/notification_service.dart) |

## Instalación y ejecución

Requisitos: Flutter estable, Android Studio con un emulador (o un dispositivo físico) y `flutter doctor -v` sin errores.

```bash
git clone https://github.com/TatsuhiroSattou/portafolio_seguridad_app.git
cd portafolio_seguridad_app
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter run
```

> En Android 13 o superior la app pide el permiso de notificaciones al abrirse. En Android, el permiso de cámara se solicita al pulsar **Tomar foto**.
