import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/app_data.dart';
import '../models/zone_analysis.dart';

class ZoneIntelligenceService {
  ZoneIntelligenceService({http.Client? client, DateTime Function()? now})
      : _client = client ?? http.Client(),
        _now = now ?? DateTime.now;

  final http.Client _client;
  final DateTime Function() _now;

  Future<ZoneAnalysis> analyze({required LatLng point, double seismicRadiusKm = 300}) async {
    final now = _now();
    final results = await Future.wait([
      _seismic(point, seismicRadiusKm).catchError((_) => <SeismicEvent>[]),
      _weather(point).catchError((_) => null),
      _region(point).catchError((_) => <String, String>{}),
    ]);
    final seismic = results[0] as List<SeismicEvent>;
    final weather = results[1] as WeatherSnapshot?;
    final region = results[2] as Map<String, String>;

    final warnings = <String>[];
    if (seismic.isNotEmpty) warnings.add('${seismic.length} événement(s) sismique(s) récent(s) trouvé(s) dans un rayon de ${seismicRadiusKm.round()} km.');
    if (weather != null && weather.precipitation >= 10) warnings.add('Précipitations importantes prévues/observées selon la donnée météo disponible.');
    if (weather != null && weather.windSpeed >= 50) warnings.add('Vent élevé selon la donnée météo disponible.');
    warnings.add('Les événements sismiques et la météo sont des données externes : ils ne constituent pas une prédiction de danger.');

    return ZoneAnalysis(
      country: region['country'] ?? 'Inconnu',
      iso: region['iso'] ?? '',
      region: region['region'] ?? 'Inconnue',
      seismicEvents: seismic,
      weather: weather,
      observedNetworkPoints: 0,
      observedRoadPoints: 0,
      observedInfrastructurePoints: 0,
      networkSourceStatus: 'Préparation ITU DCM : couverture 2G/3G/4G, cellules, QoS et mesures terrain à corréler.',
      informationScore: _informationScore(seismic, weather),
      warnings: warnings,
      generatedAt: now,
    );
  }

  int _informationScore(List<SeismicEvent> s, WeatherSnapshot? w) => (30 + (w != null ? 35 : 0) + (s.isNotEmpty ? 35 : 10)).clamp(0,100);

  Future<List<SeismicEvent>> _seismic(LatLng p, double radius) async {
    final uri = Uri.https('earthquake.usgs.gov','/fdsnws/event/1/query',{
      'format':'geojson','latitude':'${p.latitude}','longitude':'${p.longitude}','maxradiuskm':'$radius','orderby':'time','limit':'50','starttime':_now().subtract(const Duration(days:30)).toUtc().toIso8601String(),
    });
    final r = await _client.get(uri).timeout(const Duration(seconds:12));
    if (r.statusCode != 200) return [];
    final json = jsonDecode(r.body);
    if (json is! Map<String,dynamic>) return [];
    final features = (json['features'] as List?) ?? const <dynamic>[];
    return features.whereType<Map>().map((f) {
      final m = f.cast<String,dynamic>();
      final prop = ((m['properties'] as Map?) ?? const {}).cast<String,dynamic>();
      final geo = ((m['geometry'] as Map?) ?? const {}).cast<String,dynamic>();
      final c = (geo['coordinates'] as List?) ?? const [0.0, 0.0, 0.0];
      final latitude = _numFromList(c, 1) ?? 0.0;
      final longitude = _numFromList(c, 0) ?? 0.0;
      final magnitude = _doubleValue(prop['mag']) ?? 0.0;
      final depth = _doubleValue(_numFromList(c, 2)) ?? 0.0;
      final timeMillis = (prop['time'] as num?)?.toInt() ?? 0;
      return SeismicEvent(
        id: '${m['id'] ?? 'unknown'}',
        latitude: latitude,
        longitude: longitude,
        magnitude: magnitude,
        depthKm: depth,
        place: '${prop['place'] ?? 'Localisation inconnue'}',
        time: DateTime.fromMillisecondsSinceEpoch(timeMillis, isUtc: true),
        url: '${prop['url'] ?? ''}',
      );
    }).toList();
  }

  Future<WeatherSnapshot?> _weather(LatLng p) async {
    final uri = Uri.https('api.open-meteo.com','/v1/forecast',{'latitude':'${p.latitude}','longitude':'${p.longitude}','current':'temperature_2m,precipitation,wind_speed_10m,weather_code','hourly':'precipitation,temperature_2m,weather_code','forecast_days':'2','timezone':'auto'});
    final r = await _client.get(uri).timeout(const Duration(seconds:12));
    if (r.statusCode != 200) return null;
    final root = jsonDecode(r.body);
    if (root is! Map<String,dynamic>) return null;
    final current = (root['current'] as Map?)?.cast<String,dynamic>() ?? const <String,dynamic>{};
    final hourly = (root['hourly'] as Map?)?.cast<String,dynamic>() ?? const <String,dynamic>{};
    if (current.isEmpty && hourly.isEmpty) return null;

    final times = (hourly['time'] as List?) ?? const <dynamic>[];
    final rains = (hourly['precipitation'] as List?) ?? const <dynamic>[];
    final currentTime = _parseTime(current['time']);
    var startIndex = 0;
    if (currentTime != null && times.isNotEmpty) {
      final parsedTimes = times.map((value) => _parseTime(value)).whereType<DateTime>().toList();
      for (var i = 0; i < parsedTimes.length; i++) {
        final t = parsedTimes[i];
        if (!t.isBefore(currentTime)) { startIndex = i; break; }
      }
    }
    final next6 = rains.skip(startIndex).take(6).whereType<num>().map((value) => value.toDouble()).toList();
    final next6h = next6.isEmpty ? null : next6.fold<double>(0, (total, value) => total + value);

    return WeatherSnapshot(
      temperature: _doubleValue(current['temperature_2m']) ?? 0.0,
      windSpeed: _doubleValue(current['wind_speed_10m']) ?? 0.0,
      precipitation: _doubleValue(current['precipitation']) ?? 0.0,
      weatherCode: _intValue(current['weather_code']) ?? 0,
      time: currentTime ?? DateTime.now(),
      precipitationNext6h: next6h,
      source: 'Open-Meteo / prévision horaire',
    );
  }

  Future<Map<String,String>> _region(LatLng p) async {
    final uri = Uri.https('earthquake.usgs.gov','/ws/geoserve/regions.json',{'latitude':'${p.latitude}','longitude':'${p.longitude}','type':'admin'});
    final r = await _client.get(uri).timeout(const Duration(seconds:12));
    if (r.statusCode != 200) return {};
    final data = jsonDecode(r.body);
    if (data is! Map<String,dynamic>) return {};
    final admin = (data['admin'] as Map?)?.cast<String,dynamic>();
    final features = (admin?['features'] as List?) ?? const <dynamic>[];
    if (features.isEmpty) return {};
    final first = features.first;
    if (first is! Map) return {};
    final props = (first['properties'] as Map?)?.cast<String,dynamic>() ?? const <String,dynamic>{};
    return {
      'country': '${props['country'] ?? ''}',
      'iso': '${props['iso'] ?? ''}',
      'region': '${props['region'] ?? ''}',
    };
  }

  String networkSummary(List<NetworkMeasurement> measurements) {
    final known = measurements.where((m) => m.signalStrength != null).length;
    return '${measurements.length} mesure(s) terrain réseau, dont $known avec niveau de signal réellement mesuré.';
  }

  static DateTime? _parseTime(dynamic value) {
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static double? _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _intValue(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _numFromList(List<dynamic> values, int index) {
    if (index < 0 || index >= values.length) return null;
    return _doubleValue(values[index]);
  }
}
