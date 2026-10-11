import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/route_correlation_service.dart';

class ZoneIntelligenceScreen extends StatefulWidget {
  const ZoneIntelligenceScreen({super.key});

  @override
  State<ZoneIntelligenceScreen> createState() => _ZoneIntelligenceScreenState();
}

class _ZoneIntelligenceScreenState extends State<ZoneIntelligenceScreen> {
  final startLat = TextEditingController(text: '3.8480');
  final startLon = TextEditingController(text: '11.5021');
  final endLat = TextEditingController(text: '4.0511');
  final endLon = TextEditingController(text: '9.7679');
  final service = RouteCorrelationService();
  RouteCorrelationResult? result;
  bool loading = false;
  String? error;

  double? _number(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));

  Future<void> analyzeRoute() async {
    final a = _number(startLat), b = _number(startLon), c = _number(endLat), d = _number(endLon);
    if (a == null || b == null || c == null || d == null || a < -90 || a > 90 || c < -90 || c > 90 || b < -180 || b > 180 || d < -180 || d > 180) {
      setState(() => error = 'Coordonnées invalides. Latitude : -90 à 90 ; longitude : -180 à 180.');
      return;
    }
    setState(() {
      loading = true;
      error = null;
      result = null;
    });
    try {
      final report = await service.analyzeRoute(start: LatLng(a, b), destination: LatLng(c, d));
      if (mounted) setState(() => result = report);
    } catch (e) {
      if (mounted) setState(() => error = 'Analyse impossible : $e\nVérifie la connexion Internet et les coordonnées.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    startLat.dispose();
    startLon.dispose();
    endLat.dispose();
    endLon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Corrélation sur un itinéraire complet', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('L\'application calcule la route routière puis analyse jusqu\'à six zones réparties entre le départ et l\'arrivée. Les données météo et sismiques sont demandées pour chaque zone.'),
                  const SizedBox(height: 12),
                  const Text('Départ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(children: [Expanded(child: _field(startLat, 'Latitude')), const SizedBox(width: 8), Expanded(child: _field(startLon, 'Longitude'))]),
                  const SizedBox(height: 8),
                  const Text('Destination', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(children: [Expanded(child: _field(endLat, 'Latitude')), const SizedBox(width: 8), Expanded(child: _field(endLon, 'Longitude'))]),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: loading ? null : analyzeRoute,
                      icon: loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.route),
                      label: Text(loading ? 'Calcul et corrélation en cours…' : 'Analyser tout l\'itinéraire'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Exemple prérempli : Yaoundé → Douala. Les coordonnées peuvent être remplacées pour tout autre itinéraire routier pris en charge.'),
                ],
              ),
            ),
          ),
          if (error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ),
          if (result != null) ..._buildReport(result!),
        ],
      );

  Widget _field(TextEditingController controller, String label) => TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        decoration: InputDecoration(labelText: label),
      );

  List<Widget> _buildReport(RouteCorrelationResult r) => [
        Card(
          child: ListTile(
            leading: const Icon(Icons.route),
            title: Text('${r.route.distanceKilometers.toStringAsFixed(1)} km'),
            subtitle: Text('Durée estimée de conduite : ${_duration(r.route.durationSeconds)}\n${r.zones.length} zones analysées • Généré ${r.generatedAt.toLocal()}'),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Synthèse de l\'itinéraire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Événements sismiques retournés dans les rayons analysés : ${r.seismicEventCount} (un même événement peut apparaître dans plusieurs zones).'),
                Text('Zones avec météo disponible : ${r.weatherAvailableCount}/${r.zones.length}.'),
                const Text('Couverture téléphonique réelle : non déterminée automatiquement dans cette version. Les relevés opérateur/terrain sont nécessaires pour conclure zone par zone.'),
              ],
            ),
          ),
        ),
        ...r.zones.map(_zoneCard),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text('Limites importantes : les points échantillonnés ne représentent pas chaque mètre de route. La météo est une photographie des données disponibles au moment de la requête ; les événements sismiques récents ne prédisent pas un futur séisme. Vérifie les alertes officielles et l\'état réel des routes avant le départ.'),
          ),
        ),
      ];

  Widget _zoneCard(RouteZoneReport z) {
    final a = z.analysis;
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.location_on_outlined),
        title: Text('Zone ${z.index} • ${z.distanceFromStartKm.toStringAsFixed(1)} km depuis le départ'),
        subtitle: Text("${a.country}${a.region.isEmpty ? '' : ' • ${a.region}'} • ${a.seismicEvents.length} événement(s) sismique(s)"),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(alignment: Alignment.centerLeft, child: Text('Coordonnées : ${z.point.latitude.toStringAsFixed(5)}, ${z.point.longitude.toStringAsFixed(5)}')),
          const SizedBox(height: 6),
          Text(a.weather == null ? 'Météo : indisponible.' : 'Météo (${a.weather!.time.toLocal()}): ${a.weather!.temperature.toStringAsFixed(1)} °C, vent ${a.weather!.windSpeed.toStringAsFixed(1)} km/h, précipitations ${a.weather!.precipitation.toStringAsFixed(1)} mm.'),
          const SizedBox(height: 6),
          Text('Sismologie : ${a.seismicEvents.isEmpty ? 'aucun événement retourné par la requête dans le rayon et la période demandés' : ''}'),
          ...a.seismicEvents.take(5).map(
                (e) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('M ${e.magnitude.toStringAsFixed(1)} • ${e.place}'),
                  subtitle: Text('${e.time.toLocal()} • profondeur ${e.depthKm.toStringAsFixed(1)} km'),
                ),
              ),
          const Divider(),
          Text('Réseau mobile : ${a.networkSourceStatus}'),
          ...a.warnings.map((w) => Padding(padding: const EdgeInsets.only(top: 4), child: Align(alignment: Alignment.centerLeft, child: Text('• $w')))),
        ],
      ),
    );
  }

  String _duration(double seconds) {
    final d = Duration(seconds: seconds.round());
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return h > 0 ? '$h h $m min' : '$m min';
  }
}
