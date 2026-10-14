import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/app_data.dart';
import '../models/route_corridor_report.dart';
import '../models/route_result.dart';
import '../services/database_service.dart';
import '../services/global_place_catalog.dart';
import '../services/location_service.dart';
import '../services/route_corridor_service.dart';
import '../services/routing_service.dart';
import 'route_corridor_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final map = MapController();
  final location = LocationService();
  final routing = RoutingService();
  final corridorService = RouteCorridorService();
  final db = DatabaseService();

  LatLng center = const LatLng(5.96, 10.159);
  LatLng? current;
  LatLng? destination;
  RouteResult? route;
  RouteCorridorReport? corridorReport;
  List<RoadObservation> roads = [];
  List<NetworkMeasurement> networks = [];
  List<InfrastructurePoint> infrastructures = [];
  List<CommunityIncident> incidents = [];
  bool showRoads = true;
  bool showNetwork = true;
  bool showInfrastructure = true;
  bool showCorridor = true;
  bool showHeatmap = true;
  bool showIncidents = true;
  bool loading = false;
  bool analyzing = false;

  @override
  void initState() {
    super.initState();
    GlobalPlaceCatalog.selected.addListener(_selectedPlaceChanged);
    _load();
    _locate();
  }

  @override
  void dispose() {
    GlobalPlaceCatalog.selected.removeListener(_selectedPlaceChanged);
    super.dispose();
  }

  void _selectedPlaceChanged() {
    final place = GlobalPlaceCatalog.selected.value;
    if (place == null || !mounted) return;
    final point = LatLng(place.latitude, place.longitude);
    setState(() {
      destination = point;
      route = null;
      corridorReport = null;
    });
    map.move(point, 12);
  }

  Future<void> _load() async {
    final data = await Future.wait([
      db.getRoadObservations(),
      db.getNetworkMeasurements(),
      db.getInfrastructures(),
      db.getIncidents(),
    ]);
    if (!mounted) return;
    setState(() {
      roads = data[0] as List<RoadObservation>;
      networks = data[1] as List<NetworkMeasurement>;
      infrastructures = data[2] as List<InfrastructurePoint>;
      incidents = data[3] as List<CommunityIncident>;
    });
  }

  Future<void> _locate() async {
    final p = await location.getCurrentPosition();
    if (p == null || !mounted) return;
    final point = LatLng(p.latitude, p.longitude);
    setState(() => current = point);
    map.move(point, 15);
  }

  Future<void> _calculateRoute() async {
    if (current == null || destination == null) {
      _message('Position GPS et destination nécessaires.');
      return;
    }
    setState(() {
      loading = true;
      corridorReport = null;
    });
    final result = await routing.calculateRoute(
      start: current!,
      destination: destination!,
    );
    if (!mounted) return;
    if (result == null) {
      setState(() => loading = false);
      _message('Itinéraire indisponible.');
      return;
    }
    await db.insertRoute(
      startLatitude: current!.latitude,
      startLongitude: current!.longitude,
      destinationLatitude: destination!.latitude,
      destinationLongitude: destination!.longitude,
      distanceMeters: result.distanceMeters,
      durationSeconds: result.durationSeconds,
      createdAt: DateTime.now(),
    );
    setState(() {
      route = result;
      loading = false;
    });
    if (result.isEstimated) {
      _message(
          'Trajet calculé en estimation hors ligne : le tracé est géométrique et non routier réel.');
    }
    _fitRoute(result.points);
  }

  Future<void> _analyzeCorridor() async {
    final selectedRoute = route;
    if (selectedRoute == null) {
      _message("Calcule d'abord un itinéraire.");
      return;
    }
    setState(() => analyzing = true);
    try {
      final result = await corridorService.analyze(selectedRoute);
      if (!mounted) return;
      setState(() => corridorReport = result);
      _message("${result.zones.length} zones analysées sur l'itinéraire.");
    } catch (e) {
      if (mounted) {
        _message('Analyse du corridor impossible : ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => analyzing = false);
    }
  }

  void _fitRoute(List<LatLng> points) {
    if (points.isEmpty) return;
    map.move(points[points.length ~/ 2], 9);
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void _showReportDialog() {
    String selectedType = 'Route coupée';
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.add_location_alt, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Signaler un Incident / Réseau',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(labelText: 'Type de signalement'),
              items: const [
                'Route coupée / Latérite',
                'Inondation / Glissement',
                'Accident / Obstacle',
                'Contrôle Police / Ralentissement',
                'Bon réseau mobile ici',
              ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
              onChanged: (v) => selectedType = v!,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description complémentaire'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Envoyer le signalement'),
                onPressed: () async {
                  final p = await location.getCurrentPosition();
                  if (p == null) {
                    if (mounted) Navigator.pop(context);
                    _message('GPS indisponible : impossible d’ancrer le signalement.');
                    return;
                  }
                  await db.insertIncident(
                    CommunityIncident(
                      latitude: p.latitude,
                      longitude: p.longitude,
                      type: selectedType,
                      description: descController.text.trim(),
                      timestamp: DateTime.now(),
                    ),
                  );
                  if (mounted) Navigator.pop(context);
                  _load();
                  _message('Signalement communautaire enregistré.');
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Marker _marker(LatLng point, IconData icon, Color color, String label) {
    return Marker(
      point: point,
      width: 44,
      height: 44,
      child: Tooltip(
        message: label,
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }

  Color _networkSignalColor(double? dbm) {
    if (dbm == null) return Colors.grey;
    if (dbm >= -85) return Colors.green;
    if (dbm >= -105) return Colors.orange;
    return Colors.red;
  }

  Color _zoneColor(CorridorZoneReport zone) {
    if (zone.badRoadCount > 0 || zone.intelligence.seismicEvents.isNotEmpty) {
      return Colors.red;
    }
    if (zone.networkMeasurements.isEmpty || zone.intelligence.weather != null) {
      return Colors.orange;
    }
    return Colors.green;
  }

  String _zoneLabel(CorridorZoneReport zone) {
    final flags = <String>[];
    if (zone.intelligence.seismicEvents.isNotEmpty) {
      flags.add(
          '${zone.intelligence.seismicEvents.length} événement(s) sismique(s)');
    }
    if (zone.badRoadCount > 0) {
      flags.add('${zone.badRoadCount} route(s) en mauvais état');
    }
    if (zone.networkMeasurements.isEmpty) {
      flags.add('réseau non documenté localement');
    } else {
      flags.add('${zone.measuredNetworkCount} mesure(s) réseau');
    }
    return 'Zone ${zone.index} • km ${zone.distanceFromStartKm.toStringAsFixed(1)}\n${flags.join(' • ')}';
  }

  List<Marker> _markers() {
    final markers = <Marker>[];
    if (showRoads) {
      for (final item in roads) {
        markers.add(_marker(
          LatLng(item.latitude, item.longitude),
          Icons.warning_amber,
          item.condition.toLowerCase() == 'mauvais'
              ? Colors.red
              : Colors.orange,
          'Route ${item.condition}',
        ));
      }
    }
    if (showNetwork) {
      for (final item in networks) {
        final color = showHeatmap ? _networkSignalColor(item.signalStrength) : Colors.blue;
        markers.add(_marker(
          LatLng(item.latitude, item.longitude),
          Icons.network_cell,
          color,
          '${item.operator} ${item.technology} (${item.signalStrength?.toStringAsFixed(0) ?? "N/A"} dBm)',
        ));
      }
    }
    if (showInfrastructure) {
      for (final item in infrastructures) {
        markers.add(_marker(
          LatLng(item.latitude, item.longitude),
          Icons.location_city,
          Colors.deepPurple,
          item.name.isEmpty ? item.type : item.name,
        ));
      }
    }
    if (showIncidents) {
      for (final item in incidents) {
        markers.add(_marker(
          LatLng(item.latitude, item.longitude),
          Icons.report_problem,
          Colors.redAccent,
          '${item.type}\n${item.description}',
        ));
      }
    }
    if (showCorridor && corridorReport != null) {
      for (final zone in corridorReport!.zones) {
        markers.add(_marker(
          zone.point,
          Icons.analytics,
          _zoneColor(zone),
          _zoneLabel(zone),
        ));
      }
    }
    if (current != null) {
      markers.add(
          _marker(current!, Icons.my_location, Colors.blue, 'Position GPS'));
    }
    if (destination != null) {
      final place = GlobalPlaceCatalog.selected.value;
      markers.add(_marker(
        destination!,
        Icons.place,
        Colors.red,
        place?.label ?? 'Destination',
      ));
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final selected = GlobalPlaceCatalog.selected.value;
    return Stack(
      children: [
        FlutterMap(
          mapController: map,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 6.5,
            onTap: (_, point) => setState(() {
              destination = point;
              route = null;
              corridorReport = null;
            }),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.camroute.ia',
            ),
            if (route != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: route!.points,
                    strokeWidth: 5,
                    color: route!.isEstimated ? Colors.orange : Colors.green,
                  ),
                ],
              ),
            MarkerLayer(markers: _markers()),
          ],
        ),
        Positioned(
          top: 10,
          left: 10,
          right: 10,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Heatmap Réseau'),
                      selected: showHeatmap,
                      onSelected: (value) => setState(() => showHeatmap = value),
                    ),
                    const SizedBox(width: 4),
                    FilterChip(
                      label: const Text('Signalements'),
                      selected: showIncidents,
                      onSelected: (value) => setState(() => showIncidents = value),
                    ),
                    const SizedBox(width: 4),
                    FilterChip(
                      label: const Text('Routes'),
                      selected: showRoads,
                      onSelected: (value) => setState(() => showRoads = value),
                    ),
                    const SizedBox(width: 4),
                    FilterChip(
                      label: const Text('Infrastructure'),
                      selected: showInfrastructure,
                      onSelected: (value) =>
                          setState(() => showInfrastructure = value),
                    ),
                    const SizedBox(width: 4),
                    FilterChip(
                      label: const Text('Corridor'),
                      selected: showCorridor,
                      onSelected: (value) => setState(() => showCorridor = value),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (selected != null)
          Positioned(
            top: 70,
            left: 10,
            right: 10,
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.public),
                title: Text(selected.name),
                subtitle: Text('${selected.country} • ${selected.continent}'),
                trailing: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() {
                    destination = null;
                    route = null;
                    corridorReport = null;
                  }),
                ),
              ),
            ),
          ),
        Positioned(
          right: 10,
          bottom: corridorReport != null ? 285 : 160,
          child: Column(
            children: [
              FloatingActionButton.extended(
                heroTag: 'signaler-map',
                onPressed: _showReportDialog,
                icon: const Icon(Icons.add_location_alt),
                label: const Text('+ Signaler'),
                backgroundColor: Colors.redAccent,
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'refresh-map',
                onPressed: _load,
                child: const Icon(Icons.refresh),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'gps-map',
                onPressed: _locate,
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
        if (destination != null)
          Positioned(
            left: 10,
            right: 10,
            bottom: corridorReport != null ? 135 : 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected == null
                          ? 'Destination : ${destination!.latitude.toStringAsFixed(5)}, ${destination!.longitude.toStringAsFixed(5)}'
                          : 'Destination : ${selected.label}',
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.icon(
                          onPressed: loading ? null : _calculateRoute,
                          icon: loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.route),
                          label: const Text("Calculer l'itinéraire"),
                        ),
                        if (route != null) ...[
                          const SizedBox(height: 6),
                          OutlinedButton.icon(
                            onPressed: analyzing ? null : _analyzeCorridor,
                            icon: analyzing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.analytics),
                            label: const Text('Analyser les données'),
                          ),
                          const SizedBox(height: 6),
                          FilledButton.icon(
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        RouteCorridorScreen(route: route!))),
                            icon: const Icon(Icons.auto_awesome),
                            label:
                                const Text("Ouvrir l'itinéraire intelligent"),
                          ),
                        ],
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () => setState(() {
                              destination = null;
                              route = null;
                              corridorReport = null;
                            }),
                            icon: const Icon(Icons.clear),
                          ),
                        ),
                      ],
                    ),
                    if (route != null) ...[
                      Text(
                        '${route!.distanceKilometers.toStringAsFixed(1)} km • ${route!.duration.inMinutes} min',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        route!.isEstimated
                            ? 'Source : ${route!.source} • Itinéraire estimé hors ligne'
                            : 'Source : ${route!.source}',
                        style: TextStyle(
                          color: route!.isEstimated
                              ? Colors.orange[700]
                              : Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        if (corridorReport != null)
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: _corridorSummary(corridorReport!),
          ),
        const Positioned(
          left: 5,
          bottom: 3,
          child: Text(
            '© OpenStreetMap contributors',
            style: TextStyle(fontSize: 10, backgroundColor: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _corridorSummary(RouteCorridorReport report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Corrélations de l'itinéraire",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text('${report.zones.length} zones'),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              '${report.seismicEventCount} événement(s) sismique(s) trouvé(s) • '
              '${report.measuredNetworkCount} mesure(s) réseau avec intensité • '
              '${report.badRoadCount} observation(s) routière(s) en mauvais état.',
            ),
            const SizedBox(height: 4),
            const Text(
              'Les marqueurs indiquent des données ou observations à examiner ; ils ne constituent pas une prédiction de danger ni une garantie de couverture.',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
