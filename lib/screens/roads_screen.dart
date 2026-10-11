import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../services/database_service.dart';

class RoadsScreen extends StatefulWidget {
  const RoadsScreen({super.key});

  @override
  State<RoadsScreen> createState() => _RoadsScreenState();
}

class _RoadsScreenState extends State<RoadsScreen> {
  final DatabaseService _db = DatabaseService();
  List<RoadObservation> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _db.getRoadObservations();
    if (mounted) {
      setState(() => _items = list);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Text('Aucune observation routière.'),
              ),
            ),
          ..._items.map(
            (x) => Card(
              child: ListTile(
                leading: const Icon(Icons.route),
                title: Text('${x.roadType} • ${x.condition}'),
                subtitle: Text(
                  '${x.latitude.toStringAsFixed(5)}, ${x.longitude.toStringAsFixed(5)}\n'
                  '${x.description.isEmpty ? "Sans description" : x.description}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
