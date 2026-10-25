# Security Portfolio (MVP en Flutter)

Prototipo interactivo de un catálogo de **reportes de seguridad** basado en un portafolio de ciberseguridad ofensiva. Muestra únicamente información pública y de alto nivel (sin pasos de reproducción), siguiendo la práctica de divulgación responsable.

## Características

- **Pantalla 1 (HomeScreen):** encabezado estilo terminal con certificaciones y listado de reportes en tarjetas (`Card`) con imagen, organización, severidad, estado y botón "Ver detalle".
- **Pantalla 2 (DetailScreen):** detalle del reporte (tipo, descripción, impacto) y formulario de contacto con nombre validado y motivo seleccionable.
- **Navegación ida y vuelta:** `Navigator.push` / `Navigator.pop`.
- **Paso de parámetros:** el objeto `SecurityReport` viaja de la Pantalla 1 a la Pantalla 2 por constructor; al volver, la Pantalla 2 devuelve un mensaje que se muestra en un `SnackBar`.

## Estructura del proyecto

```
assets/
└── images/            # banners locales de cada reporte
lib/
├── main.dart
├── models/
│   └── security_report.dart
├── screens/
│   ├── home_screen.dart
│   └── detail_screen.dart
└── widgets/
    ├── report_card.dart
    └── severity_chip.dart
```

## Cómo ejecutarlo

```bash
flutter pub get
flutter run
```

## Verificación del entorno

```bash
flutter doctor -v
```

## Autor

Victor Andre Chiquito Toro 
