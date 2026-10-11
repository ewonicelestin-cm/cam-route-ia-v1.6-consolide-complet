import 'dart:async';
import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../services/database_service.dart';
import '../services/live_network_service.dart';
import '../services/location_service.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  final DatabaseService _db = DatabaseService();
  final LiveNetworkService _live = LiveNetworkService();
  final LocationService _location = LocationService();
  Timer? _monitorTimer;
  bool _monitoring = false;
  List<NetworkMeasurement> _items = [];
  LiveNetworkSnapshot? _snapshot;
  bool _measuring = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _db.getNetworkMeasurements();
    if (mounted) setState(() => _items = list);
  }

  Future<void> _measure() async {
    setState(() {
      _measuring = true;
      _error = null;
    });
    try {
      final result = await _live.measure();
      final position = await _location.getCurrentPosition();
      if (position == null) {
        throw StateError('Position GPS indisponible : la mesure ne sera pas enregistrée sans géolocalisation.');
      }
      await _db.insertNetworkMeasurement(
        NetworkMeasurement(
          latitude: position.latitude,
          longitude: position.longitude,
          operator: result.operatorName,
          technology: result.technology,
          signalStrength: result.signalDbm,
          quality: result.qualityDb,
          timestamp: result.timestamp,
        ),
      );
      if (mounted) setState(() => _snapshot = result);
      await _load();
    } catch (e) {
      if (mounted) setState(() => _error = 'Mesure impossible : $e');
    } finally {
      if (mounted) setState(() => _measuring = false);
    }
  }

  Future<void> _toggleMonitoring() async {
    if (_monitoring) {
      _monitorTimer?.cancel();
      if (mounted) setState(() => _monitoring = false);
      return;
    }
    setState(() => _monitoring = true);
    await _measure();
    _monitorTimer?.cancel();
    _monitorTimer = Timer.periodic(const Duration(seconds: 30), (_) => _measure());
  }

  @override
  void dispose() {
    _monitorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Qualité réseau téléphonique',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Mesure réelle du téléphone : opérateur, technologie, intensité radio et latence Internet. Les résultats sont horodatés.',
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: _measuring ? null : _measure,
                    icon: _measuring
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.network_check),
                    label: Text(_measuring ? 'Mesure en cours…' : 'Mesurer maintenant'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _measuring ? null : _toggleMonitoring,
                    icon: Icon(_monitoring ? Icons.stop_circle : Icons.directions_car),
                    label: Text(
                      _monitoring
                          ? 'Arrêter le suivi réseau (30 s)'
                          : 'Suivre le réseau pendant le trajet',
                    ),
                  ),
                  if (_monitoring)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Mode trajet actif : une mesure GPS + radio est enregistrée toutes les 30 secondes au premier plan.',
                      ),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _error!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_snapshot != null) _liveCard(_snapshot!),
          const Card(
            child: ListTile(
              leading: Icon(Icons.verified_outlined),
              title: Text('Sources complémentaires'),
              subtitle: Text(
                'Les cartes ITU/GSMA peuvent fournir des données de couverture et de performance. CAM-ROUTE IA ne les transforme pas en mesure locale : la mesure du téléphone reste identifiée séparément.',
              ),
            ),
          ),
          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Text('Aucune mesure réseau enregistrée.'),
              ),
            ),
          ..._items.take(50).map(
                (x) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.network_cell),
                    title: Text('${x.operator} • ${x.technology}'),
                    subtitle: Text(
                      'Signal : ${x.signalStrength?.toStringAsFixed(0) ?? "Non mesuré"} dBm • Qualité radio : ${x.quality?.toStringAsFixed(0) ?? "Non mesurée"} dB\n${x.timestamp.toLocal()}',
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _liveCard(LiveNetworkSnapshot x) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dernière mesure réelle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Opérateur : ${x.operatorName}'),
              Text('Technologie : ${x.technology}'),
              Text('Signal : ${x.signalDbm?.toStringAsFixed(0) ?? "Non mesuré"} dBm — ${x.signalLabel}'),
              Text('Qualité radio : ${x.qualityDb?.toStringAsFixed(0) ?? "Non mesurée"} dB'),
              Text('Latence HTTP : ${x.latencyMs == null ? "Non mesurée" : "${x.latencyMs} ms"}'),
              Text('Mesuré : ${x.timestamp.toLocal()}'),
              const SizedBox(height: 6),
              Text(x.source, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      );
}
