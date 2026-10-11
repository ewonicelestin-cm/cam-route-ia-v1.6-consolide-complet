import 'package:flutter/material.dart';
import '../models/route_corridor_report.dart';
import '../models/route_result.dart';
import '../services/route_corridor_service.dart';

class RouteCorridorScreen extends StatefulWidget {
  final RouteResult route;
  const RouteCorridorScreen({super.key, required this.route});

  @override
  State<RouteCorridorScreen> createState() => _RouteCorridorScreenState();
}

class _RouteCorridorScreenState extends State<RouteCorridorScreen> {
  final service = RouteCorridorService();
  RouteCorridorReport? report;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    setState(() {
      loading = true;
      error = null;
      report = null;
    });
    try {
      final result = await service.analyze(widget.route);
      if (mounted) setState(() => report = result);
    } catch (e) {
      if (mounted) {
        setState(() => error = "Analyse impossible pour le moment. Vérifie la connexion Internet puis réessaie. Détail : $e");
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Corrélation de l'itinéraire")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Analyse du corridor complet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Distance routière calculée : ${widget.route.distanceKilometers.toStringAsFixed(1)} km'),
                  Text('Durée estimée par le service de routage : ${_duration(widget.route.durationSeconds)}'),
                  Text('Source du tracé : ${widget.route.source}'),
                  if (widget.route.isEstimated)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Le tracé est une estimation hors ligne et ne remplace pas un itinéraire routier réel. Les données de corridor restent locales et qualitatives.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    'L\'itinéraire est échantillonné en zones successives. Chaque zone est rapprochée des données sismiques, météo et observations terrain enregistrées à proximité.',
                  ),
                  const SizedBox(height: 10),
                  if (loading) const LinearProgressIndicator(),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Interrogation des sources externes et analyse des zones… cela peut prendre un moment.'),
                    ),
                  if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  if (!loading)
                    OutlinedButton.icon(
                      onPressed: _runAnalysis,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Relancer l'analyse"),
                    ),
                ],
              ),
            ),
          ),
          if (report != null) ..._buildReport(report!),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Important : les résultats décrivent les données disponibles, pas une garantie de sécurité. Une absence de mesure n\'indique pas une absence de danger ou de couverture mobile. Vérifie les consignes des autorités et les informations officielles avant le départ.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildReport(RouteCorridorReport r) => [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: [
            _stat('Zones analysées', '${r.zones.length}', Icons.route),
            _stat('Événements sismiques trouvés', '${r.seismicEventCount}', Icons.landscape),
            _stat('Mesures réseau avec signal', '${r.measuredNetworkCount}', Icons.network_cell),
            _stat('Observations route dégradée', '${r.badRoadCount}', Icons.warning_amber),
          ],
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lecture globale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Rapport généré le ${r.generatedAt.toLocal()}'),
                const SizedBox(height: 6),
                const Text(
                  'Les zones sont espacées sur le tracé afin de fournir une couverture synthétique de l\'itinéraire. Les observations terrain sont associées dans un rayon local de 5 km autour de chaque zone.',
                ),
                const SizedBox(height: 8),
                Text('Couverture informationnelle : ${r.informationCoveragePercent}% (météo, sismologie, réseau mesuré et observations locales).'),
                const SizedBox(height: 8),
                ...r.smartRouteNotes.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.rule, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 8, 4, 4),
          child: Text('DÉTAIL PAR ZONE', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ),
        ...r.zones.map(_zoneCard),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Limites et qualité des données', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...r.limitations.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ];

  Widget _stat(String title, String value, IconData icon) => Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22),
              const SizedBox(height: 5),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      );

  Widget _zoneCard(CorridorZoneReport z) {
    final a = z.intelligence;
    final hasLocalNetwork = z.networkMeasurements.isNotEmpty;
    final weather = a.weather;
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(child: Text('${z.index}')),
        title: Text('Zone ${z.index} • km ${z.distanceFromStartKm.toStringAsFixed(1)}'),
        subtitle: Text("${a.country.isEmpty ? 'Pays non déterminé' : a.country} • ${a.seismicEvents.length} événement(s) sismique(s)"),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [
          _detail('Coordonnées', '${z.point.latitude.toStringAsFixed(5)}, ${z.point.longitude.toStringAsFixed(5)}'),
          _detail('Météo réelle disponible', weather == null ? 'Donnée indisponible' : '${weather.temperature.toStringAsFixed(1)} °C • vent ${weather.windSpeed.toStringAsFixed(1)} km/h • pluie actuelle ${weather.precipitation.toStringAsFixed(1)} mm • source ${weather.source}'),
          if (weather?.precipitationNext6h != null) _detail('Prévision pluie 6 h', '${weather!.precipitationNext6h!.toStringAsFixed(1)} mm cumulés selon la prévision disponible.'),
          _detail('Réseau téléphonique', hasLocalNetwork ? '${z.networkMeasurements.length} observation(s) locale(s), dont ${z.measuredNetworkCount} avec intensité mesurée.' : 'Aucune observation locale dans un rayon de 5 km. Couverture réelle inconnue.'),
          if (hasLocalNetwork) ...z.networkMeasurements.take(5).map((m) => _detail('${m.operator} • ${m.technology}', m.signalStrength == null ? 'Intensité non mesurée • ${m.timestamp.toLocal()}' : '${m.signalStrength!.toStringAsFixed(0)} dBm • ${m.timestamp.toLocal()}')),
          _detail('État des routes', z.roadObservations.isEmpty ? 'Aucune observation routière locale enregistrée.' : '${z.roadObservations.length} observation(s), dont ${z.badRoadCount} signalée(s) en mauvais état.'),
          if (z.roadObservations.isNotEmpty) ...z.roadObservations.take(5).map((r) => _detail('${r.roadType} • ${r.condition}', '${r.description.isEmpty ? 'Sans description' : r.description} • ${r.timestamp.toLocal()}')),
          _detail('Infrastructures', z.infrastructures.isEmpty ? 'Aucune infrastructure locale enregistrée.' : '${z.infrastructures.length} point(s) : ${z.infrastructures.map((i) => i.name.isEmpty ? i.type : i.name).take(6).join(', ')}'),
          _detail('Statut de source', a.networkSourceStatus),
          if (a.seismicEvents.isNotEmpty) ...a.seismicEvents.take(5).map((e) => _detail('Séisme M ${e.magnitude.toStringAsFixed(1)}', '${e.place} • profondeur ${e.depthKm.toStringAsFixed(1)} km • ${e.time.toLocal()}')),
          if (a.seismicEvents.isEmpty) _detail('Sismologie', 'Aucun événement trouvé par la requête récente dans le rayon configuré ; cela ne signifie pas absence de risque sismique.'),
          ...a.warnings.map((w) => _detail('Note', w)),
        ],
      ),
    );
  }

  Widget _detail(String title, String value) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(value),
          ],
        ),
      );

  String _duration(double seconds) {
    final totalMinutes = (seconds / 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return hours > 0 ? '$hours h $minutes min' : '$minutes min';
  }
}
