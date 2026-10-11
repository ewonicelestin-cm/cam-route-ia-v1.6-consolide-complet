class SeismicEvent {
  final String id;
  final double latitude;
  final double longitude;
  final double magnitude;
  final double depthKm;
  final String place;
  final DateTime time;
  final String url;

  const SeismicEvent({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.magnitude,
    required this.depthKm,
    required this.place,
    required this.time,
    required this.url,
  });
}

class WeatherSnapshot {
  final double temperature;
  final double windSpeed;
  final double precipitation;
  final int weatherCode;
  final DateTime time;
  final double? precipitationNext6h;
  final String source;

  const WeatherSnapshot({
    required this.temperature,
    required this.windSpeed,
    required this.precipitation,
    required this.weatherCode,
    required this.time,
    this.precipitationNext6h,
    this.source = 'Open-Meteo',
  });
}

class ZoneAnalysis {
  final String country;
  final String iso;
  final String region;
  final List<SeismicEvent> seismicEvents;
  final WeatherSnapshot? weather;
  final int observedNetworkPoints;
  final int observedRoadPoints;
  final int observedInfrastructurePoints;
  final String networkSourceStatus;
  final int informationScore;
  final List<String> warnings;
  final DateTime generatedAt;

  const ZoneAnalysis({
    required this.country,
    required this.iso,
    required this.region,
    required this.seismicEvents,
    required this.weather,
    required this.observedNetworkPoints,
    required this.observedRoadPoints,
    required this.observedInfrastructurePoints,
    required this.networkSourceStatus,
    required this.informationScore,
    required this.warnings,
    required this.generatedAt,
  });
}
