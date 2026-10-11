class GlobalPlace {
  final String continent;
  final String country;
  final String countryCode;
  final String city;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String? region;
  final bool isRemote;

  const GlobalPlace({
    required this.continent,
    required this.country,
    required this.countryCode,
    required this.city,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.region,
    this.isRemote = false,
  });

  String get label {
    final regStr = (region != null && region!.isNotEmpty) ? ' ($region)' : '';
    if (city == name) {
      return '$city$regStr, $country';
    }
    return '$name — $city$regStr, $country';
  }
}
