class LocationRecord {
  final int? id; final double latitude; final double longitude;
  final double? altitude; final double? accuracy; final double? speed; final double? heading;
  final DateTime timestamp;
  const LocationRecord({this.id, required this.latitude, required this.longitude, this.altitude, this.accuracy, this.speed, this.heading, required this.timestamp});
  factory LocationRecord.fromMap(Map<String,dynamic> m) => LocationRecord(
    id:m['id'] as int?, latitude:(m['latitude'] as num).toDouble(), longitude:(m['longitude'] as num).toDouble(),
    altitude:(m['altitude'] as num?)?.toDouble(), accuracy:(m['accuracy'] as num?)?.toDouble(),
    speed:(m['speed'] as num?)?.toDouble(), heading:(m['heading'] as num?)?.toDouble(), timestamp:DateTime.parse(m['timestamp'] as String));
}

class RoadObservation {
  final int? id; final double latitude; final double longitude; final String roadType; final String condition; final String description; final DateTime timestamp;
  const RoadObservation({this.id,required this.latitude,required this.longitude,required this.roadType,required this.condition,this.description='',required this.timestamp});
  factory RoadObservation.fromMap(Map<String,dynamic> m) => RoadObservation(id:m['id'] as int?,latitude:(m['latitude'] as num).toDouble(),longitude:(m['longitude'] as num).toDouble(),roadType:m['road_type'] as String? ?? '',condition:m['condition'] as String? ?? '',description:m['description'] as String? ?? '',timestamp:DateTime.parse(m['timestamp'] as String));
}

class NetworkMeasurement {
  final int? id; final double latitude; final double longitude; final String operator; final String technology; final double? signalStrength; final double? quality; final DateTime timestamp;
  const NetworkMeasurement({this.id,required this.latitude,required this.longitude,required this.operator,required this.technology,this.signalStrength,this.quality,required this.timestamp});
  factory NetworkMeasurement.fromMap(Map<String,dynamic> m) => NetworkMeasurement(id:m['id'] as int?,latitude:(m['latitude'] as num).toDouble(),longitude:(m['longitude'] as num).toDouble(),operator:m['operator'] as String? ?? '',technology:m['technology'] as String? ?? '',signalStrength:(m['signal_strength'] as num?)?.toDouble(),quality:(m['quality'] as num?)?.toDouble(),timestamp:DateTime.parse(m['timestamp'] as String));
}

class InfrastructurePoint {
  final int? id; final double latitude; final double longitude; final String type; final String name; final String description; final DateTime timestamp;
  const InfrastructurePoint({this.id,required this.latitude,required this.longitude,required this.type,required this.name,this.description='',required this.timestamp});
  factory InfrastructurePoint.fromMap(Map<String,dynamic> m) => InfrastructurePoint(id:m['id'] as int?,latitude:(m['latitude'] as num).toDouble(),longitude:(m['longitude'] as num).toDouble(),type:m['type'] as String? ?? '',name:m['name'] as String? ?? '',description:m['description'] as String? ?? '',timestamp:DateTime.parse(m['timestamp'] as String));
}
