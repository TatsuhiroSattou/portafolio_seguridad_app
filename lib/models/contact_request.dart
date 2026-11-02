/// Solicitud de contacto que el usuario envía desde la pantalla de detalle.
///
/// Se guarda en el dispositivo (JSON) para no perderla si no hay internet.
class ContactRequest {
  final String id;
  final int reportId;
  final String organization;
  final String name;
  final String reason;
  final DateTime createdAt;
  final bool sent;

  const ContactRequest({
    required this.id,
    required this.reportId,
    required this.organization,
    required this.name,
    required this.reason,
    required this.createdAt,
    required this.sent,
  });

  ContactRequest copyWith({bool? sent}) {
    return ContactRequest(
      id: id,
      reportId: reportId,
      organization: organization,
      name: name,
      reason: reason,
      createdAt: createdAt,
      sent: sent ?? this.sent,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reportId': reportId,
        'organization': organization,
        'name': name,
        'reason': reason,
        'createdAt': createdAt.toIso8601String(),
        'sent': sent,
      };

  factory ContactRequest.fromJson(Map<String, dynamic> json) {
    return ContactRequest(
      id: json['id'] as String,
      reportId: json['reportId'] as int,
      organization: json['organization'] as String,
      name: json['name'] as String,
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sent: json['sent'] as bool? ?? false,
    );
  }
}
