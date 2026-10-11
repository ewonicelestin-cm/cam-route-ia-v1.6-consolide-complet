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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _db.getRoutes();
    if (mounted) {
      setState(() => _routes = list);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          if (_routes.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  await _db.deleteAllRoutes();
                  _load();
                },
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Tout supprimer'),
              ),
            ),
          if (_routes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Text('Aucun itinéraire enregistré.'),
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
}
