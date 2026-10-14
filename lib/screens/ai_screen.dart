import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final db = DatabaseService.instance;
  final ai = const AiService();
  String text = 'Chargement...';
  List<PredictiveAlert> alerts = [];

  Future<void> load() async {
    final roads = await db.getRoadObservations();
    final nets = await db.getNetworkMeasurements();
    final incidents = await db.getIncidents();

    final a = ai.analyzeRoads(roads);
    final generatedAlerts = ai.generatePredictiveAlerts(
      roads: roads,
      networks: nets,
      incidents: incidents,
    );

    if (mounted) {
      setState(() {
        text =
            '${a.level}\nScore terrain : ${a.score}/100\n${a.explanation}\n\n${ai.summarizeNetwork(nets)}';
        alerts = generatedAlerts;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Intelligence IA',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(text),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text('Alertes Prédictives & Risques Routiers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...alerts.map(
            (item) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(item.description),
                    const Divider(),
                    Text('Source : ${item.source}',
                        style: const TextStyle(fontSize: 12)),
                    Text('Incertitude : ${item.uncertainty}',
                        style: const TextStyle(fontSize: 12)),
                    Text(
                      'Validité : ${item.validityWindow.inHours} heures à partir de ${item.timestamp.toLocal()}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.verified),
              title: Text('Règle de qualité'),
              subtitle: Text(
                  'Mesuré ≠ estimé ≠ modèle. Chaque information conserve son origine, sa date et son niveau d’incertitude.'),
            ),
          ),
        ],
      );
}
