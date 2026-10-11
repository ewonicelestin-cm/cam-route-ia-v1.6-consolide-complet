import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class LiveNetworkSnapshot {
  final String operatorName;
  final String technology;
  final double? signalDbm;
  final double? qualityDb;
  final int? latencyMs;
  final DateTime timestamp;
  final String source;

  const LiveNetworkSnapshot({
    required this.operatorName,
    required this.technology,
    required this.signalDbm,
    required this.qualityDb,
    required this.latencyMs,
    required this.timestamp,
    required this.source,
  });

  String get signalLabel {
    final value = signalDbm;
    if (value == null) return 'Non mesuré';
    if (value >= -80) return 'Très bon';
    if (value >= -90) return 'Bon';
    if (value >= -100) return 'Moyen';
    if (value >= -110) return 'Faible';
    return 'Très faible';
  }
}

class LiveNetworkService {
  static const _channel = MethodChannel('camroute/network');

  Future<LiveNetworkSnapshot> measure() async {
    Map<dynamic, dynamic>? raw;
    if (!kIsWeb) {
      try {
        raw = await _channel.invokeMethod<Map<dynamic, dynamic>>('getNetworkSnapshot');
      } catch (_) {}
    }

    final latency = await _measureLatency();

    if (raw == null) {
      return LiveNetworkSnapshot(
        operatorName: kIsWeb ? 'Navigateur Web' : 'Donnée radio non disponible',
        technology: kIsWeb ? 'Connexion Web' : 'Inconnue',
        signalDbm: null,
        qualityDb: null,
        latencyMs: latency,
        timestamp: DateTime.now(),
        source: kIsWeb
            ? 'Test de latence HTTP Web (TelephonyManager indisponible sur navigateur)'
            : 'Test de latence HTTP (Mesure radio indisponible)',
      );
    }

    return LiveNetworkSnapshot(
      operatorName: (raw['operator'] as String?)?.trim().isNotEmpty == true ? raw['operator'] as String : 'Opérateur non identifié',
      technology: (raw['technology'] as String?)?.trim().isNotEmpty == true ? raw['technology'] as String : 'Technologie non identifiée',
      signalDbm: (raw['signalDbm'] as num?)?.toDouble(),
      qualityDb: (raw['qualityDb'] as num?)?.toDouble(),
      latencyMs: latency,
      timestamp: DateTime.now(),
      source: 'Mesure radio du téléphone + test HTTP de latence',
    );
  }

  Future<int?> _measureLatency() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.head(Uri.parse('https://www.cloudflare.com/cdn-cgi/trace')).timeout(const Duration(seconds: 8));
      stopwatch.stop();
      if (response.statusCode >= 200 && response.statusCode < 500) return stopwatch.elapsedMilliseconds;
    } catch (_) {}
    return null;
  }
}
