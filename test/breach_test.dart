import 'package:bugtatsu_sec/models/breach.dart';
import 'package:bugtatsu_sec/providers/breaches_provider.dart';
import 'package:bugtatsu_sec/services/breach_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Respuesta de ejemplo con el mismo formato que la API de Have I Been Pwned.
const _sampleJson = r'''
[
  {
    "Name": "Adobe",
    "Title": "Adobe",
    "Domain": "adobe.com",
    "BreachDate": "2013-10-04",
    "AddedDate": "2013-12-04T00:00:00Z",
    "PwnCount": 152445165,
    "Description": "En octubre de 2013, <a href=\"https://example.com\">Adobe</a> sufrió una brecha &amp; se filtraron cuentas.",
    "LogoPath": "https://logos.haveibeenpwned.com/Adobe.png",
    "DataClasses": ["Email addresses", "Password hints"],
    "IsVerified": true,
    "IsSensitive": false
  },
  {
    "Name": "Example",
    "Title": "Example Forum",
    "Domain": "example.org",
    "BreachDate": "2020-01-15",
    "AddedDate": "2020-02-01T00:00:00Z",
    "PwnCount": 5000,
    "Description": "Foro de ejemplo.",
    "LogoPath": "",
    "DataClasses": ["Usernames"],
    "IsVerified": false,
    "IsSensitive": false
  }
]
''';

/// Servicio falso: devuelve datos o lanza un error sin tocar la red.
class _FakeService extends BreachService {
  _FakeService({this.data, this.failure});

  final List<Breach>? data;
  final BreachException? failure;

  @override
  Future<List<Breach>> fetchBreaches() async {
    final error = failure;
    if (error != null) throw error;
    return List<Breach>.of(data ?? const []);
  }
}

void main() {
  group('Breach (mapeo JSON)', () {
    test('fromJson lee los campos de la API', () {
      final breaches = parseBreaches(_sampleJson);
      final adobe = breaches.first;

      expect(adobe.title, 'Adobe');
      expect(adobe.domain, 'adobe.com');
      expect(adobe.pwnCount, 152445165);
      expect(adobe.breachDate, DateTime.parse('2013-10-04'));
      expect(adobe.dataClasses, ['Email addresses', 'Password hints']);
      expect(adobe.isVerified, isTrue);
      expect(adobe.pwnCountLabel, '152 M');
      expect(adobe.pwnCountFull, '152.445.165');
    });

    test('la descripción HTML se convierte en texto plano', () {
      final adobe = parseBreaches(_sampleJson).first;

      expect(adobe.plainDescription, isNot(contains('<')));
      expect(adobe.plainDescription, contains('Adobe sufrió una brecha & se'));
    });

    test('toJson y fromJson son inversos', () {
      final original = parseBreaches(_sampleJson).first;
      final copy = Breach.fromJson(original.toJson());

      expect(copy.title, original.title);
      expect(copy.pwnCount, original.pwnCount);
      expect(copy.dataClasses, original.dataClasses);
    });

    test('un JSON que no es una lista lanza FormatException', () {
      expect(() => parseBreaches('{"a": 1}'), throwsFormatException);
    });
  });

  group('BreachesProvider (estados)', () {
    test('empieza en cargando y termina en éxito', () async {
      final provider = BreachesProvider(
        _FakeService(data: parseBreaches(_sampleJson)),
        minLoadingTime: Duration.zero,
      );

      expect(provider.status, BreachesStatus.loading);
      await provider.load();

      expect(provider.status, BreachesStatus.success);
      expect(provider.total, 2);
      // La más reciente (Example, 2020) va primero.
      expect(provider.visible.first.title, 'Example Forum');
    });

    test('un fallo de red termina en el estado de error', () async {
      final provider = BreachesProvider(
        _FakeService(
          failure: const BreachException(
            BreachErrorKind.network,
            'Sin conexión',
          ),
        ),
        minLoadingTime: Duration.zero,
      );

      await provider.load();

      expect(provider.status, BreachesStatus.error);
      expect(provider.error?.kind, BreachErrorKind.network);
    });

    test('la búsqueda filtra por título', () async {
      final provider = BreachesProvider(
        _FakeService(data: parseBreaches(_sampleJson)),
        minLoadingTime: Duration.zero,
      );
      await provider.load();

      provider.setQuery('adobe');

      expect(provider.visible.length, 1);
      expect(provider.visible.first.name, 'Adobe');
    });
  });
}
