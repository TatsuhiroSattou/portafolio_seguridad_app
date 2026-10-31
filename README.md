# BugTatsu Sec

<<<<<<< HEAD
Prototipo interactivo de un catálogo de **reportes de seguridad** basado en un portafolio de ciberseguridad ofensiva. Muestra únicamente información pública y de alto nivel que he divulgando a lo largo de estos meses para aportar conocimientos en bug bouting (sin pasos de reproducción), siguiendo la práctica de divulgación responsable.
=======
Aplicación móvil en Flutter de **BugTatsu Sec**, la versión móvil de mi portafolio de ciberseguridad ofensiva ([portafolio.bugtatsu.xyz](https://portafolio.bugtatsu.xyz)). Muestra reportes de seguridad en formato de catálogo, únicamente con información pública y de alto nivel (sin pasos de reproducción), siguiendo la práctica de divulgación responsable.
>>>>>>> 1bdbed2 (feat(brand): rebranding a BugTatsu Sec con paquete com.bugtatsu.sec y tema unificado)

Es la evolución de la Actividad Integradora 1 (*Security Portfolio*): se aplicó un rebranding completo y se agregaron servicios nativos.

## Identidad del proyecto

| | |
|---|---|
| Nombre comercial | **BugTatsu Sec** |
| Android `applicationId` | `com.bugtatsu.sec` |
| iOS bundle identifier | `com.bugtatsu.sec` |
| Gestor de estado | Provider |
| Tema | Oscuro tipo terminal (`lib/core/app_theme.dart`) |

## Instalación y ejecución

Requisitos: Flutter estable, Android Studio con un emulador (o un dispositivo físico) y `flutter doctor -v` sin errores.

```bash
git clone https://github.com/TatsuhiroSattou/portafolio_seguridad_app.git
cd portafolio_seguridad_app
flutter pub get
flutter run
```
