/// Modelo de datos de un reporte de seguridad del portafolio.
///
/// Solo contiene información pública y de alto nivel (sin pasos de
/// reproducción), siguiendo la práctica de divulgación responsable.
class SecurityReport {
  final int id;
  final String organization;
  final String title;
  final String vulnType;
  final String severity;
  final String status;
  final String description;
  final String impact;
  final String imagePath;

  const SecurityReport({
    required this.id,
    required this.organization,
    required this.title,
    required this.vulnType,
    required this.severity,
    required this.status,
    required this.description,
    required this.impact,
    required this.imagePath,
  });

  bool get isResolved => status == 'Solucionada';
}

/// Certificaciones que se muestran en el encabezado de la Pantalla 1.
const List<String> certifications = [
  'CRTeamer',
  'eCPPTv3',
  'CRTA',
  'eJPTv2',
  'CNSP',
];

/// Datos del catálogo (no hay backend en este MVP).
const List<SecurityReport> sampleReports = [
  SecurityReport(
    id: 1,
    organization: 'NASA',
    title: 'XSS almacenado en sitio principal',
    vulnType: 'Cross-Site Scripting (almacenado)',
    severity: 'Crítica (P1)',
    status: 'Solucionada',
    description:
        'Se identificó un XSS almacenado en un sitio principal de la '
        'organización, reportado de forma responsable a través del canal '
        'oficial.',
    impact: 'Riesgo de secuestro de cuentas. La organización emitió una '
        'carta de reconocimiento.',
    imagePath: 'assets/images/nasa.png',
  ),
  SecurityReport(
    id: 2,
    organization: 'Motorola',
    title: 'XSS almacenado en carrito de compras',
    vulnType: 'Cross-Site Scripting (almacenado)',
    severity: 'Crítica (P1)',
    status: 'Solucionada',
    description:
        'Vulnerabilidad de XSS almacenado en el flujo del carrito de '
        'compras de la tienda en línea, corregida tras el reporte.',
    impact: 'Riesgo de engaño a usuarios y robo de datos.',
    imagePath: 'assets/images/motorola.png',
  ),
  SecurityReport(
    id: 3,
    organization: 'Harvard Medical School / Brigham and Women\'s Hospital',
    title: 'Ejecución remota de código sin autenticación',
    vulnType: 'Remote Code Execution (RCE)',
    severity: 'Crítica (P1)',
    status: 'Solucionada',
    description:
        'Falla de ejecución remota de código no autenticada en una '
        'interfaz de investigación, reportada y corregida por el equipo '
        'responsable.',
    impact: 'Puntuación CVSS 9.8.',
    imagePath: 'assets/images/harvard_rce.png',
  ),
  SecurityReport(
    id: 4,
    organization: 'Harvard MCZbase',
    title: 'XSS reflejado en base de datos de colecciones',
    vulnType: 'Cross-Site Scripting (reflejado)',
    severity: 'Alta (P2)',
    status: 'Solucionada',
    description:
        'XSS reflejado en la base de datos de colecciones del Museo de '
        'Zoología Comparada.',
    impact: 'Riesgo de phishing sobre un dominio de confianza. Las cookies '
        'de sesión tenían HttpOnly.',
    imagePath: 'assets/images/mczbase.png',
  ),
  SecurityReport(
    id: 5,
    organization: 'Lenovo',
    title: 'Hallazgo crítico en proceso de corrección',
    vulnType: 'Detalles reservados',
    severity: 'Crítica (P1)',
    status: 'En proceso',
    description:
        'El write-up se publicará únicamente cuando el fabricante '
        'confirme la corrección.',
    impact: 'Información reservada hasta la solución del fabricante.',
    imagePath: 'assets/images/lenovo.png',
  ),
];
