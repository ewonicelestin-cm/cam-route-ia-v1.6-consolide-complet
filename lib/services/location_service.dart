import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> requestPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied)
      p = await Geolocator.requestPermission();
    return p != LocationPermission.denied &&
        p != LocationPermission.deniedForever;
  }

  Future<Position?> getCurrentPosition() async {
    if (!await requestPermission()) return null;
    return Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high));
  }

  Stream<Position> positionStream() => Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 10));
}
