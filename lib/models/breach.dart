/// Modelo de una filtración de datos devuelta por la API pública de
/// Have I Been Pwned (https://haveibeenpwned.com/api/v3/breaches).
///
/// Solo se mapean los campos que usa la interfaz. Todos los campos del JSON
/// se leen de forma tolerante: si falta alguno, se usa un valor por defecto
/// en vez de lanzar una excepción.
class Breach {
  final String name;
  final String title;
  final String domain;
  final DateTime? breachDate;
  final DateTime? addedDate;
  final int pwnCount;
  final String description;
  final String logoPath;
  final List<String> dataClasses;
  final bool isVerified;
  final bool isSensitive;

  const Breach({
    required this.name,
    required this.title,
    required this.domain,
    required this.breachDate,
    required this.addedDate,
    required this.pwnCount,
    required this.description,
    required this.logoPath,
    required this.dataClasses,
    required this.isVerified,
    required this.isSensitive,
  });

  /// Convierte un objeto JSON de la API en un [Breach].
  factory Breach.fromJson(Map<String, dynamic> json) {
    final name = json['Name'] as String? ?? '';
    return Breach(
      name: name,
      title: json['Title'] as String? ?? (name.isEmpty ? 'Sin título' : name),
      domain: json['Domain'] as String? ?? '',
      breachDate: DateTime.tryParse(json['BreachDate'] as String? ?? ''),
      addedDate: DateTime.tryParse(json['AddedDate'] as String? ?? ''),
      pwnCount: (json['PwnCount'] as num?)?.toInt() ?? 0,
      description: json['Description'] as String? ?? '',
      logoPath: json['LogoPath'] as String? ?? '',
      dataClasses: (json['DataClasses'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      isVerified: json['IsVerified'] as bool? ?? false,
      isSensitive: json['IsSensitive'] as bool? ?? false,
    );
  }

  /// Convierte el modelo de vuelta a JSON (mismas claves que la API).
  Map<String, dynamic> toJson() => {
        'Name': name,
        'Title': title,
        'Domain': domain,
        'BreachDate': breachDate?.toIso8601String(),
        'AddedDate': addedDate?.toIso8601String(),
        'PwnCount': pwnCount,
        'Description': description,
        'LogoPath': logoPath,
        'DataClasses': dataClasses,
        'IsVerified': isVerified,
        'IsSensitive': isSensitive,
      };

  /// URL completa del logo (la API puede devolver una ruta relativa).
  String get logoUrl {
    if (logoPath.isEmpty) return '';
    if (logoPath.startsWith('http')) return logoPath;
    final path = logoPath.startsWith('/') ? logoPath : '/$logoPath';
    return 'https://haveibeenpwned.com$path';
  }

  /// La descripción llega en HTML: se quitan las etiquetas y entidades comunes.
  String get plainDescription {
    return description
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .trim();
  }

  /// Cantidad de cuentas afectadas en formato corto (por ejemplo "152 M").
  String get pwnCountLabel {
    if (pwnCount >= 1000000000) {
      return '${(pwnCount / 1000000000).toStringAsFixed(1)} mil millones';
    }
    if (pwnCount >= 1000000) return '${(pwnCount / 1000000).toStringAsFixed(0)} M';
    if (pwnCount >= 1000) return '${(pwnCount / 1000).toStringAsFixed(0)} mil';
    return '$pwnCount';
  }

  /// Cantidad de cuentas afectadas con separador de miles (por ejemplo "152.445.165").
  String get pwnCountFull => pwnCount.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
      );

  /// Fecha en formato dd/mm/aaaa, o un texto por defecto si no se conoce.
  static String formatDate(DateTime? date) {
    if (date == null) return 'Fecha desconocida';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
