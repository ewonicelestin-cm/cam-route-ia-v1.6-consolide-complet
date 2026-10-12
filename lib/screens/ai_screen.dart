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

  Future<void> load() async {
    final roads = await db.getRoadObservations();
    final nets = await db.getNetworkMeasurements();
    final a = ai.analyzeRoads(roads);
    if (mounted) {
      setState(() => text =
          '${a.level}\nScore terrain : ${a.score}/100\n${a.explanation}\n\n${ai.summarizeNetwork(nets)}');
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
                  const SizedBox(height: 16),
                  const Text('Corrélation mondiale préparatoire',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                      'Le moteur est préparé pour croiser, par zone ou segment d’itinéraire : données terrain, réseau mobile, sismologie, météo/climat, routes et infrastructures sensibles. Il conserve la provenance et ne transforme pas une absence de mesure en donnée réelle.'),
                ],
              ),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.verified),
              title: Text('Règle de qualité'),
              subtitle: Text(
                  'Mesuré ≠ estimé ≠ modèle. Chaque information doit conserver son origine et sa date.'),
            ),
          ),
        ],
      );
}
