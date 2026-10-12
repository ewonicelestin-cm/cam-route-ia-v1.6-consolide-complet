import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/app_data.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class GpsScreen extends StatefulWidget {
  const GpsScreen({super.key});

  @override
  State<GpsScreen> createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> {
  final LocationService _locationService = LocationService();
  final DatabaseService _db = DatabaseService();
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSub;
  int _savedCount = 0;
  bool _tracking = false;

  @override
  void initState() {
    super.initState();
    _count();
  }

  Future<void> _count() async {
    final count = await _db.getLocationCount();
    if (mounted) {
      setState(() => _savedCount = count);
    }
  }

  Future<void> _get() async {
    final pos = await _locationService.getCurrentPosition();
    if (pos == null) return;
    setState(() => _currentPosition = pos);
    await _db.insertLocation(
      LocationRecord(
        latitude: pos.latitude,
        longitude: pos.longitude,
        altitude: pos.altitude,
        accuracy: pos.accuracy,
        speed: pos.speed,
        heading: pos.heading,
        timestamp: DateTime.now(),
      ),
    );
    _count();
  }

  void _toggle() {
    if (_tracking) {
      _positionSub?.cancel();
      setState(() => _tracking = false);
      return;
    }
    _positionSub = _locationService.positionStream().listen((pos) async {
      if (!mounted) return;
      setState(() => _currentPosition = pos);
      await _db.insertLocation(
        LocationRecord(
          latitude: pos.latitude,
          longitude: pos.longitude,
          altitude: pos.altitude,
          accuracy: pos.accuracy,
          speed: pos.speed,
          heading: pos.heading,
          timestamp: DateTime.now(),
        ),
      );
      _count();
    });
    setState(() => _tracking = true);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        FilledButton.icon(
          onPressed: _get,
          icon: const Icon(Icons.gps_fixed),
          label: const Text('Obtenir ma position'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _toggle,
          icon: Icon(_tracking ? Icons.stop : Icons.play_arrow),
          label: Text(_tracking ? 'Arrêter le suivi' : 'Démarrer le suivi'),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _currentPosition == null
                ? const Text('Aucune position disponible.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Latitude : ${_currentPosition!.latitude}'),
                      Text('Longitude : ${_currentPosition!.longitude}'),
                      Text(
                          'Altitude : ${_currentPosition!.altitude.toStringAsFixed(1)} m'),
                      Text(
                          'Précision : ${_currentPosition!.accuracy.toStringAsFixed(1)} m'),
                      Text(
                          'Vitesse : ${_currentPosition!.speed.toStringAsFixed(1)} m/s'),
                    ],
                  ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.storage),
          title: const Text('Positions enregistrées'),
          trailing: Text('$_savedCount'),
        ),
      ],
    );
  }
}
