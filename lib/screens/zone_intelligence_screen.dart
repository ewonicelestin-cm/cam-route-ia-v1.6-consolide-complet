import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/global_place.dart';
import '../models/route_result.dart';
import '../services/global_place_catalog.dart';
import '../services/route_correlation_service.dart';
import '../services/routing_service.dart';

class ZoneIntelligenceScreen extends StatefulWidget {
  const ZoneIntelligenceScreen({super.key});

  @override
  State<ZoneIntelligenceScreen> createState() => _ZoneIntelligenceScreenState();
}

class _ZoneIntelligenceScreenState extends State<ZoneIntelligenceScreen> {
  final startController = TextEditingController(text: 'Yaoundé, Cameroun');
  final endController = TextEditingController(text: 'Douala, Cameroun');

  LatLng _startPoint = const LatLng(3.8480, 11.5021);
  LatLng _endPoint = const LatLng(4.0511, 9.7679);

  final service = RouteCorrelationService();
  final routingService = RoutingService();

  RouteCorrelationResult? result;
  List<SmartRouteOption> routeOptions = [];
  int selectedOptionIndex = 0;

  bool loading = false;
  bool searchingStart = false;
  bool searchingEnd = false;
  String? error;

  List<GlobalPlace> startSuggestions = [];
  List<GlobalPlace> endSuggestions = [];

  Future<void> _searchStart(String query) async {
    if (query.trim().length < 2) {
      setState(() => startSuggestions = []);
      return;
    }
    setState(() => searchingStart = true);
    final local = GlobalPlaceCatalog.filter(query: query);
    final remote = await GlobalPlaceCatalog.searchNominatim(query);
    if (mounted) {
      setState(() {
        startSuggestions = [...local, ...remote].take(6).toList();
        searchingStart = false;
      });
    }
  }

  Future<void> _searchEnd(String query) async {
    if (query.trim().length < 2) {
      setState(() => endSuggestions = []);
      return;
    }
    setState(() => searchingEnd = true);
    final local = GlobalPlaceCatalog.filter(query: query);
    final remote = await GlobalPlaceCatalog.searchNominatim(query);
    if (mounted) {
      setState(() {
        endSuggestions = [...local, ...remote].take(6).toList();
        searchingEnd = false;
      });
    }
  }

  void _swapLocations() {
    setState(() {
      final tmpText = startController.text;
      startController.text = endController.text;
      endController.text = tmpText;

      final tmpPoint = _startPoint;
      _startPoint = _endPoint;
      _endPoint = tmpPoint;

      startSuggestions = [];
      endSuggestions = [];
      result = null;
      routeOptions = [];
    });
  }

  Future<void> analyzeRoute() async {
    setState(() {
      loading = true;
      error = null;
      result = null;
      routeOptions = [];
      startSuggestions = [];
      endSuggestions = [];
    });

    try {
      final options = await routingService.calculateSmartRouteOptions(
        start: _startPoint,
        destination: _endPoint,
      );

      final report = await service.analyzeRoute(
        start: _startPoint,
        destination: _endPoint,
      );

      if (mounted) {
        setState(() {
          routeOptions = options;
          result = report;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => error =
            'Calcul ou analyse impossible : $e\nVérifiez la connexion Internet et les noms de lieux.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    startController.dispose();
    endController.dispose();
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
                  const Text('Navigation & Calcul d\'Itinéraires',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text(
                      'Saisissez les noms des lieux de départ et d’arrivée pour calculer les itinéraires OSRM et analyser le corridor géospatial.'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.trip_origin, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: startController,
                          decoration: InputDecoration(
                            labelText: 'Lieu de Départ (Nom, Ville, Adresse)',
                            suffixIcon: searchingStart
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2))
                                : null,
                          ),
                          onChanged: _searchStart,
                        ),
                      ),
                    ],
                  ),
                  if (startSuggestions.isNotEmpty)
                    Card(
                      color: Colors.grey[50],
                      child: Column(
                        children: startSuggestions
                            .map((p) => ListTile(
                                  dense: true,
                                  title: Text(p.name),
                                  subtitle: Text('${p.city}, ${p.country}'),
                                  onTap: () {
                                    setState(() {
                                      startController.text = p.name;
                                      _startPoint = LatLng(p.latitude, p.longitude);
                                      startSuggestions = [];
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Center(
                    child: IconButton(
                      icon: const Icon(Icons.swap_vert, size: 28, color: Colors.blue),
                      tooltip: 'Inverser le trajet',
                      onPressed: _swapLocations,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: endController,
                          decoration: InputDecoration(
                            labelText: 'Lieu d\'Arrivée (Nom, Ville, Adresse)',
                            suffixIcon: searchingEnd
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2))
                                : null,
                          ),
                          onChanged: _searchEnd,
                        ),
                      ),
                    ],
                  ),
                  if (endSuggestions.isNotEmpty)
                    Card(
                      color: Colors.grey[50],
                      child: Column(
                        children: endSuggestions
                            .map((p) => ListTile(
                                  dense: true,
                                  title: Text(p.name),
                                  subtitle: Text('${p.city}, ${p.country}'),
                                  onTap: () {
                                    setState(() {
                                      endController.text = p.name;
                                      _endPoint = LatLng(p.latitude, p.longitude);
                                      endSuggestions = [];
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: loading ? null : analyzeRoute,
                      icon: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.route),
                      label: Text(loading
                          ? 'Calcul et analyse en cours…'
                          : 'Calculer & Comparer l\'itinéraire'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ),
          if (routeOptions.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text('Options d\'Itinéraires Comparées',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...routeOptions.asMap().entries.map((entry) {
              final idx = entry.key;
              final opt = entry.value;
              final selected = idx == selectedOptionIndex;
              return Card(
                color: selected ? Colors.blue.withOpacity(0.05) : null,
                shape: selected
                    ? RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: ListTile(
                  title: Row(
                    children: [
                      Text(opt.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Chip(
                        label: Text(opt.badgeText, style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                          'Distance : ${opt.route.distanceKilometers.toStringAsFixed(1)} km • Durée : ${_duration(opt.route.durationSeconds)}'),
                      Text('Avantage : ${opt.advantage}'),
                      Text('Limitation : ${opt.limitation}'),
                      Text('Indice de Praticabilité : ${opt.safetyScore}/100'),
                    ],
                  ),
                  onTap: () => setState(() => selectedOptionIndex = idx),
                ),
              );
            }),
          ],
          if (result != null) ..._buildReport(result!),
        ],
      );

  List<Widget> _buildReport(RouteCorrelationResult r) => [
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.analytics),
            title: Text('${r.route.distanceKilometers.toStringAsFixed(1)} km'),
            subtitle: Text(
                'Durée de conduite estimée : ${_duration(r.route.durationSeconds)}\n'
                '${r.zones.length} zones d\'échantillonnage analysées • Généré ${r.generatedAt.toLocal()}'),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Synthèse du Corridor',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                    'Événements sismiques détectés : ${r.seismicEventCount}'),
                Text(
                    'Zones avec prévision météo disponible : ${r.weatherAvailableCount}/${r.zones.length}'),
                const Text(
                    'Note de couverture : Mesures radio cellulaires locales requises pour valider chaque tronçon.'),
              ],
            ),
          ),
        ),
        ...r.zones.map(_zoneCard),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text(
                'Important : Les données décrivent l’état des sources au moment de la requête. Les prévisions météo et séismes ne garantissent pas l’absence de risques impromptus.'),
          ),
        ),
      ];

  Widget _zoneCard(RouteZoneReport z) {
    final a = z.analysis;
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.location_on_outlined),
        title: Text(
            'Zone ${z.index} • km ${z.distanceFromStartKm.toStringAsFixed(1)} depuis le départ'),
        subtitle: Text(
            "${a.country}${a.region.isEmpty ? '' : ' • ${a.region}'} • ${a.seismicEvents.length} événement(s) sismique(s)"),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  'Coordonnées : ${z.point.latitude.toStringAsFixed(5)}, ${z.point.longitude.toStringAsFixed(5)}')),
          const SizedBox(height: 6),
          Text(a.weather == null
              ? 'Météo : indisponible.'
              : 'Météo (${a.weather!.time.toLocal()}): ${a.weather!.temperature.toStringAsFixed(1)} °C, vent ${a.weather!.windSpeed.toStringAsFixed(1)} km/h, précipitations ${a.weather!.precipitation.toStringAsFixed(1)} mm.'),
          const SizedBox(height: 6),
          Text(
              'Sismologie : ${a.seismicEvents.isEmpty ? 'aucun événement retourné par la requête dans la zone' : ''}'),
          ...a.seismicEvents.take(5).map(
                (e) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title:
                      Text('M ${e.magnitude.toStringAsFixed(1)} • ${e.place}'),
                  subtitle: Text(
                      '${e.time.toLocal()} • profondeur ${e.depthKm.toStringAsFixed(1)} km'),
                ),
              ),
          const Divider(),
          Text('Réseau mobile : ${a.networkSourceStatus}'),
          ...a.warnings.map((w) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child:
                  Align(alignment: Alignment.centerLeft, child: Text('• $w')))),
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
