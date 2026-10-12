import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final String source;
  final bool isEstimated;
  final String? note;

  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    this.source = 'OSRM / OpenStreetMap',
    this.isEstimated = false,
    this.note,
  });

  double get distanceKilometers => distanceMeters / 1000;
  Duration get duration => Duration(seconds: durationSeconds.round());

  static RouteResult estimated({
    required List<LatLng> points,
    required double distanceMeters,
    required double durationSeconds,
    String? note,
  }) =>
      RouteResult(
        points: points,
        distanceMeters: distanceMeters,
        durationSeconds: durationSeconds,
        source: 'Estimation hors ligne',
        isEstimated: true,
        note: note ??
            'Le tracé est une approximation géométrique locale sans calcul routier réel.',
      );
}
