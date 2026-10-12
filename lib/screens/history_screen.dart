import 'package:flutter/material.dart';
import '../services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _routes = [];
  int _locationCount = 0;
  int _roadCount = 0;
  int _networkCount = 0;
  int _infraCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _db.getRoutes(),
      _db.getLocationCount(),
      _db.getRoadObservationCount(),
      _db.getNetworkMeasurementCount(),
      _db.getInfrastructureCount(),
    ]);
    if (mounted) {
      setState(() {
        _routes = results[0] as List<Map<String, dynamic>>;
        _locationCount = results[1] as int;
        _roadCount = results[2] as int;
        _networkCount = results[3] as int;
        _infraCount = results[4] as int;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          // Carte de statistiques du cache SQLite (Hors-ligne à grande échelle)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cache SQLite & Observations Hors-ligne',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'État du stockage local pour le fonctionnement sans connexion Internet (zones blanches et campagnes) :',
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.2,
                    children: [
                      _statTile('Itinéraires', '$_routes'),
                      _statTile('Positions GPS', '$_locationCount'),
                      _statTile('Observations route', '$_roadCount'),
                      _statTile('Mesures réseau', '$_networkCount'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Infrastructures enregistrées : $_infraCount', style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                const Text('Itinéraires enregistrés', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_routes.isNotEmpty)
                  TextButton.icon(
                    onPressed: () async {
                      await _db.deleteAllRoutes();
                      _load();
                    },
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Tout supprimer'),
                  ),
              ],
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!_loading && _routes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Text('Aucun itinéraire enregistré dans le cache local.'),
              ),
            ),
          ..._routes.map((r) {
            final km = (r['distance_meters'] as num).toDouble() / 1000;
            final min = ((r['duration_seconds'] as num).toDouble() / 60).round();
            return Card(
              child: ListTile(
                leading: const Icon(Icons.route),
                title: Text('${km.toStringAsFixed(1)} km • $min min'),
                subtitle: Text(
                  'Départ : ${r['start_latitude']}, ${r['start_longitude']}\n'
                  'Arrivée : ${r['destination_latitude']}, ${r['destination_longitude']}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await _db.deleteRoute(r['id'] as int);
                    _load();
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value) => Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
