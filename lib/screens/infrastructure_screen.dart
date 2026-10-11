import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../services/database_service.dart';

class InfrastructureScreen extends StatefulWidget {
  const InfrastructureScreen({super.key});

  @override
  State<InfrastructureScreen> createState() => _InfrastructureScreenState();
}

class _InfrastructureScreenState extends State<InfrastructureScreen> {
  final DatabaseService _db = DatabaseService();
  List<InfrastructurePoint> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _db.getInfrastructures();
    if (mounted) {
      setState(() => _items = list);
    }
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: _load,
        child: _items.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 240),
                  Center(child: Text('Aucune infrastructure enregistrée.')),
                ],
              )
            : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final x = _items[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_city),
                      title: Text(x.name.isEmpty ? x.type : x.name),
                      subtitle: Text(
                        '${x.type}\n'
                        '${x.latitude.toStringAsFixed(5)}, ${x.longitude.toStringAsFixed(5)}'
                        '${x.description.isEmpty ? '' : '\n${x.description}'}',
                      ),
                    ),
                  );
                },
              ),
      );
}
