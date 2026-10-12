import 'package:latlong2/latlong.dart';
import '../models/route_result.dart';
import '../models/zone_analysis.dart';
import 'routing_service.dart';
import 'zone_intelligence_service.dart';

class RouteCorrelationResult {
  final RouteResult route;
  final List<RouteZoneReport> zones;
  final DateTime generatedAt;
  const RouteCorrelationResult(
      {required this.route, required this.zones, required this.generatedAt});
  int get seismicEventCount =>
      zones.fold(0, (sum, z) => sum + z.analysis.seismicEvents.length);
  int get weatherAvailableCount =>
      zones.where((z) => z.analysis.weather != null).length;
}

class RouteZoneReport {
  final int index;
  final double distanceFromStartKm;
  final LatLng point;
  final ZoneAnalysis analysis;
  const RouteZoneReport(
      {required this.index,
      required this.distanceFromStartKm,
      required this.point,
      required this.analysis});
}

/// Builds a road route using RoutingService, samples it at representative points,
/// then correlates recent seismic events and current weather at each sampled point.
class RouteCorrelationService {
  final ZoneIntelligenceService zoneService;
  final RoutingService routingService;

  RouteCorrelationService({
    ZoneIntelligenceService? zoneService,
    RoutingService? routingService,
  })  : zoneService = zoneService ?? ZoneIntelligenceService(),
        routingService = routingService ?? RoutingService();

  Future<RouteCorrelationResult> analyzeRoute(
      {required LatLng start,
      required LatLng destination,
      int sampleCount = 6}) async {
    final route = await routingService.calculateRoute(
        start: start, destination: destination);
    if (route == null || route.points.length < 2) {
      throw Exception(
          'Aucun itinéraire routier disponible entre ces coordonnées.');
    }
    final points = route.points;
    final count = sampleCount.clamp(2, 8);
    final indexes = <int>{};
    for (var i = 0; i < count; i++) {
      indexes.add(((points.length - 1) * i / (count - 1)).round());
    }
    final selected = indexes.toList()..sort();
    final cumulativeMeters = List<double>.filled(points.length, 0);
    for (var i = 1; i < points.length; i++) {
      cumulativeMeters[i] = cumulativeMeters[i - 1] +
          const Distance().as(LengthUnit.Meter, points[i - 1], points[i]);
    }
    final geometryLength = cumulativeMeters.last;
    final reports =
        await Future.wait(selected.asMap().entries.map((entry) async {
      final idx = entry.value;
      final point = points[idx];
      final progress = geometryLength > 0
          ? cumulativeMeters[idx] / geometryLength
          : idx / (points.length - 1);
      final analysis = await zoneService
          .analyze(point: point, seismicRadiusKm: 100)
          .timeout(const Duration(seconds: 35));
      return RouteZoneReport(
          index: entry.key + 1,
          distanceFromStartKm: route.distanceKilometers * progress,
          point: point,
          analysis: analysis);
    }));

    return RouteCorrelationResult(
        route: route, zones: reports, generatedAt: DateTime.now());
  }
}
