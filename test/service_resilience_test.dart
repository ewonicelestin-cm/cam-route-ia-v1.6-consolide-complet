import 'dart:convert';

import 'package:cam_route_ia/services/ai_service.dart';
import 'package:cam_route_ia/services/route_corridor_service.dart';
import 'package:cam_route_ia/services/route_correlation_service.dart';
import 'package:cam_route_ia/services/routing_service.dart';
import 'package:cam_route_ia/services/zone_intelligence_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class _FakeClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final path = request.url.path;

    if (path.contains('/v1/forecast')) {
      return http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode({
          'current': {},
          'hourly': {},
        }))),
        200,
      );
    }

    if (path.contains('/fdsnws/event/1/query')) {
      return http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode({'features': []}))),
        200,
      );
    }

    if (path.contains('/ws/geoserve/regions.json')) {
      return http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode({
          'admin': {'features': []},
        }))),
        200,
      );
    }

    return http.StreamedResponse(Stream.value(utf8.encode('{}')), 200);
  }
}

void main() {
  test('les services peuvent être instanciés', () {
    expect(const AiService(), isA<AiService>());
    expect(RouteCorrelationService(), isA<RouteCorrelationService>());
    expect(RouteCorridorService(), isA<RouteCorridorService>());
    expect(ZoneIntelligenceService(), isA<ZoneIntelligenceService>());
  });

  test('l’analyse de zone reste robuste si les API externes répondent avec des payloads incomplets', () async {
    final service = ZoneIntelligenceService(
      client: _FakeClient(),
      now: () => DateTime.utc(2026, 1, 1),
    );

    final result = await service.analyze(point: const LatLng(4.0511, 9.7679));

    expect(result.country, 'Inconnu');
    expect(result.weather, isNull);
    expect(result.seismicEvents, isEmpty);
    expect(
      result.warnings.any((w) => w.contains('Les événements sismiques et la météo sont des données externes')),
      isTrue,
    );
  });

  test('le service de routage produit une estimation hors ligne si OSRM ne répond pas', () async {
    final service = RoutingService(client: _FailingClient());

    final result = await service.calculateRoute(
      start: const LatLng(48.8566, 2.3522),
      destination: const LatLng(48.8600, 2.3720),
    );

    expect(result, isNotNull);
    expect(result!.isEstimated, isTrue);
    expect(result.source, contains('Estimation'));
    expect(result.points.length, greaterThanOrEqualTo(2));
    expect(result.distanceMeters, greaterThan(0));
  });
}

class _FailingClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    throw http.ClientException('OSRM indisponible');
  }
}
