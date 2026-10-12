import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import '../models/route_corridor_report.dart';
import '../models/route_result.dart';
import 'database_service.dart';
import 'zone_intelligence_service.dart';

class RouteCorridorService {
  RouteCorridorService(
      {DatabaseService? database, ZoneIntelligenceService? intelligence})
      : _database = database ?? DatabaseService(),
        _intelligence = intelligence ?? ZoneIntelligenceService();

  final DatabaseService _database;
  final ZoneIntelligenceService _intelligence;
  static const double _localRadiusKm = 5;
  static const double _sampleSpacingKm = 40;
  static const int _maxSamples = 10;
  final Distance _distance = const Distance();

  Future<RouteCorridorReport> analyze(RouteResult route) async {
    if (route.points.length < 2) {
      throw StateError(
          'L’itinéraire ne contient pas assez de points pour analyser un corridor.');
    }
    final roads = await _database.getRoadObservations();
    final networks = await _database.getNetworkMeasurements();
    final infrastructures = await _database.getInfrastructures();
    final samples = _sampleRoute(route.points);
    final reports = <CorridorZoneReport>[];

    for (var i = 0; i < samples.length; i++) {
      final sample = samples[i];
      final analysis = await _intelligence.analyze(
        point: sample.point,
        seismicRadiusKm: 50,
      );
      reports.add(CorridorZoneReport(
        index: i + 1,
        distanceFromStartKm: sample.distanceKm,
        point: sample.point,
        intelligence: analysis,
        networkMeasurements: networks
            .where((m) => _within(m.latitude, m.longitude, sample.point))
            .toList(),
        roadObservations: roads
            .where((m) => _within(m.latitude, m.longitude, sample.point))
            .toList(),
        infrastructures: infrastructures
            .where((m) => _within(m.latitude, m.longitude, sample.point))
            .toList(),
      ));
    }

    final limitations = <String>[
      'La couverture mobile réelle n’est pas fournie automatiquement par les opérateurs : seules les mesures locales enregistrées sont comptées.',
      'Les zones sans mesure réseau sont « non documentées », pas nécessairement sans couverture.',
      'La météo représente les conditions disponibles au moment de la requête ; ce n’est pas une prévision de danger routier.',
      'Les événements sismiques sont des événements observés récemment, pas une prédiction de séisme ni une évaluation officielle du risque.',
      'Les observations de routes et d’infrastructures proviennent de la base locale et peuvent être anciennes.',
    ];
    if (route.isEstimated) {
      limitations.add(
          'Le tracé a été estimé hors ligne. Il sert de support local et ne remplace pas un itinéraire routier réel calculé par OSRM ou une carte dédiée.');
    }

    return RouteCorridorReport(
      distanceKm: route.distanceKilometers,
      zones: reports,
      generatedAt: DateTime.now(),
      limitations: limitations,
    );
  }

  bool _within(double latitude, double longitude, LatLng center) {
    final meters = _distance.as(
      LengthUnit.Meter,
      center,
      LatLng(latitude, longitude),
    );
    return meters <= _localRadiusKm * 1000;
  }

  List<_RouteSample> _sampleRoute(List<LatLng> points) {
    final segments = <double>[];
    var totalMeters = 0.0;
    for (var i = 1; i < points.length; i++) {
      final length = _distance.as(LengthUnit.Meter, points[i - 1], points[i]);
      segments.add(length);
      totalMeters += length;
    }
    if (totalMeters <= 0) return [_RouteSample(points.first, 0)];

    final desiredCount = (totalMeters / (_sampleSpacingKm * 1000)).ceil() + 1;
    final count = math.max(2, math.min(_maxSamples, desiredCount));
    final result = <_RouteSample>[];
    for (var sampleIndex = 0; sampleIndex < count; sampleIndex++) {
      final target = totalMeters * sampleIndex / (count - 1);
      var traversed = 0.0;
      var selected = points.last;
      for (var segmentIndex = 0;
          segmentIndex < segments.length;
          segmentIndex++) {
        final segmentLength = segments[segmentIndex];
        if (traversed + segmentLength >= target) {
          final fraction =
              segmentLength == 0 ? 0.0 : (target - traversed) / segmentLength;
          final a = points[segmentIndex];
          final b = points[segmentIndex + 1];
          selected = LatLng(
            a.latitude + (b.latitude - a.latitude) * fraction,
            a.longitude + (b.longitude - a.longitude) * fraction,
          );
          break;
        }
        traversed += segmentLength;
      }
      if (result.isEmpty ||
          _distance.as(LengthUnit.Meter, result.last.point, selected) > 100) {
        result.add(_RouteSample(selected, target / 1000));
      }
    }
    return result;
  }
}

class _RouteSample {
  final LatLng point;
  final double distanceKm;
  const _RouteSample(this.point, this.distanceKm);
}
