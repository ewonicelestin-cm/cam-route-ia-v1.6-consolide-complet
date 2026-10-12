import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/route_result.dart';

class RoutingService {
  // Canaux de routage primaires et secondaires (paliatifs)
  static const primaryBaseUrl = 'https://router.project-osrm.org/route/v1/driving';
  static const fallbackBaseUrl = 'https://routing.openstreetmap.de/routed-car/route/v1/driving';

  final http.Client _client;

  RoutingService({http.Client? client}) : _client = client ?? http.Client();

  Future<RouteResult?> calculateRoute({required LatLng start, required LatLng destination}) async {
    // Tentative 1 : Canal primaire (OSRM public principal)
    RouteResult? result = await _tryFetchRoute(primaryBaseUrl, start, destination);
    if (result != null && !result.isEstimated) return result;

    // Tentative 2 : Canal palliattif secondaire (OSRM OpenStreetMap.de)
    result = await _tryFetchRoute(fallbackBaseUrl, start, destination);
    if (result != null && !result.isEstimated) return result;

    // Tentative 3 : Repli géométrique hors-ligne (estimation locale)
    return _estimateRoute(start: start, destination: destination);
  }

  Future<RouteResult?> _tryFetchRoute(String baseUrl, LatLng start, LatLng destination) async {
    try {
      final coordinates = '${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}';
      final response = await _client.get(
        Uri.parse('$baseUrl/$coordinates?overview=full&geometries=geojson&steps=false'),
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['code'] != 'Ok') return null;

      final routes = decoded['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;

      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>?;
      final coordinatesList = geometry?['coordinates'] as List?;
      if (coordinatesList == null || coordinatesList.isEmpty) return null;

      final points = coordinatesList.map<LatLng>((value) {
        final point = value as List;
        return LatLng((point[1] as num).toDouble(), (point[0] as num).toDouble());
      }).toList();

      final distanceMeters = (route['distance'] as num).toDouble();
      final durationSeconds = (route['duration'] as num).toDouble();

      return RouteResult(
        points: points,
        distanceMeters: distanceMeters,
        durationSeconds: durationSeconds,
      );
    } catch (_) {
      return null;
    }
  }

  RouteResult _estimateRoute({required LatLng start, required LatLng destination}) {
    final stepCount = 10;
    final points = <LatLng>[];
    final distance = const Distance();
    final directDistance = distance.as(LengthUnit.Meter, start, destination);
    final durationSeconds = (directDistance / 14.5).clamp(30.0, 86400.0).toDouble();

    for (var step = 0; step <= stepCount; step++) {
      final ratio = step / stepCount;
      points.add(LatLng(
        start.latitude + (destination.latitude - start.latitude) * ratio,
        start.longitude + (destination.longitude - start.longitude) * ratio,
      ));
    }

    return RouteResult.estimated(
      points: points,
      distanceMeters: directDistance,
      durationSeconds: durationSeconds,
      note: 'Canaux OSRM primaires et palliattifs indisponibles (connexion absente ou service injoignable). Tracé calculé via estimation géométrique locale.',
    );
  }
}
