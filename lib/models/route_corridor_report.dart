import 'package:latlong2/latlong.dart';
import 'app_data.dart';
import 'zone_analysis.dart';

class CorridorZoneReport {
  final int index;
  final double distanceFromStartKm;
  final LatLng point;
  final ZoneAnalysis intelligence;
  final List<NetworkMeasurement> networkMeasurements;
  final List<RoadObservation> roadObservations;
  final List<InfrastructurePoint> infrastructures;

  const CorridorZoneReport({
    required this.index,
    required this.distanceFromStartKm,
    required this.point,
    required this.intelligence,
    required this.networkMeasurements,
    required this.roadObservations,
    required this.infrastructures,
  });

  int get measuredNetworkCount =>
      networkMeasurements.where((m) => m.signalStrength != null).length;
  int get weakOrUnknownNetworkCount => networkMeasurements
      .where((m) => m.signalStrength == null || m.signalStrength! < -105)
      .length;
  int get badRoadCount => roadObservations
      .where((r) => r.condition.toLowerCase().contains('mauvais'))
      .length;
}

class RouteCorridorReport {
  final double distanceKm;
  final List<CorridorZoneReport> zones;
  final DateTime generatedAt;
  final List<String> limitations;

  const RouteCorridorReport({
    required this.distanceKm,
    required this.zones,
    required this.generatedAt,
    required this.limitations,
  });

  int get seismicEventCount => zones.fold(
      0, (sum, zone) => sum + zone.intelligence.seismicEvents.length);
  int get measuredNetworkCount =>
      zones.fold(0, (sum, zone) => sum + zone.measuredNetworkCount);
  int get badRoadCount => zones.fold(0, (sum, zone) => sum + zone.badRoadCount);
  int get zonesWithWeather =>
      zones.where((z) => z.intelligence.weather != null).length;
  int get zonesWithNetworkData =>
      zones.where((z) => z.networkMeasurements.isNotEmpty).length;
  int get zonesWithRecentSeismicEvents =>
      zones.where((z) => z.intelligence.seismicEvents.isNotEmpty).length;
  int get informationCoveragePercent {
    if (zones.isEmpty) return 0;
    final points = zones.length * 4;
    final available = zonesWithWeather +
        zonesWithNetworkData +
        zonesWithRecentSeismicEvents +
        zones.where((z) => z.roadObservations.isNotEmpty).length;
    return ((available / points) * 100).round().clamp(0, 100);
  }

  List<String> get smartRouteNotes {
    final notes = <String>[];
    if (zonesWithWeather < zones.length)
      notes.add(
          'Certaines zones ne disposent pas d’une donnée météo exploitable au moment de l’analyse.');
    if (zonesWithNetworkData < zones.length)
      notes.add(
          'La couverture mobile n’est pas confirmée dans les zones sans mesure terrain récente.');
    if (zonesWithRecentSeismicEvents > 0)
      notes.add(
          'Des événements sismiques récents ont été trouvés à proximité de certaines zones ; ils sont affichés comme informations observées, pas comme prédiction.');
    if (badRoadCount > 0)
      notes.add(
          'Des observations locales classées « mauvais » existent sur le corridor ; leur date doit être vérifiée avant utilisation.');
    if (notes.isEmpty)
      notes.add(
          'Aucune anomalie issue des données actuellement disponibles ; cela ne constitue pas une garantie de sécurité.');
    return notes;
  }
}
