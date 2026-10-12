import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/app_data.dart';
import '../services/database_service.dart';
import '../services/live_network_service.dart';
import '../services/location_service.dart';
import '../widgets/dashboard_card.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _locations = 0,
      _routes = 0,
      _roads = 0,
      _networkCount = 0,
      _infrastructureCount = 0;
  Position? _currentPosition;
  LiveNetworkSnapshot? _liveSnapshot;
  List<InfrastructurePoint> _infrastructures = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final db = DatabaseService();
    final counts = await Future.wait([
      db.getLocationCount(),
      db.getRouteCount(),
      db.getRoadObservationCount(),
      db.getNetworkMeasurementCount(),
      db.getInfrastructureCount(),
      db.getInfrastructures(),
    ]);

    if (mounted) {
      setState(() {
        _locations = counts[0] as int;
        _routes = counts[1] as int;
        _roads = counts[2] as int;
        _networkCount = counts[3] as int;
        _infrastructureCount = counts[4] as int;
        _infrastructures = counts[5] as List<InfrastructurePoint>;
        _loading = false;
      });
    }

    try {
      final pos = await LocationService()
          .getCurrentPosition()
          .timeout(const Duration(seconds: 4), onTimeout: () => null);
      if (mounted && pos != null) setState(() => _currentPosition = pos);
    } catch (_) {}

    try {
      final netSnap = await LiveNetworkService()
          .measure()
          .timeout(const Duration(seconds: 4));
      if (mounted) setState(() => _liveSnapshot = netSnap);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeFormatted =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final dateFormatted = '${now.day}/${now.month}/${now.year}';
    final timezone = now.timeZoneName;

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.map, color: Colors.blue, size: 28),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'CAM-ROUTE IA V1.6',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Chip(
                        label: Text(timezone,
                            style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                      'Cartographie intelligente, routage et analyse terrain en temps réel.'),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Heure locale : $dateFormatted à $timeFormatted ($timezone)',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.my_location,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _currentPosition == null
                              ? 'Position GPS : Localisation en attente...'
                              : 'GPS : ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)} (±${_currentPosition!.accuracy.toStringAsFixed(1)}m)',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => widget.onNavigate(4),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.signal_cellular_alt,
                            color: Colors.indigo),
                        const SizedBox(width: 8),
                        const Text('Qualité Réseau en Direct',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        if (_loading)
                          const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                        else
                          const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_liveSnapshot == null)
                      const Text(
                          'Appuyez pour lancer une mesure radio ou vérifier le signal.')
                    else ...[
                      Row(
                        children: [
                          const Text('Opérateur : ',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(_liveSnapshot!.operatorName),
                          const Spacer(),
                          Chip(
                            label: Text(_liveSnapshot!.technology,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white)),
                            backgroundColor: Colors.indigo,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                          'Signal : ${_liveSnapshot!.signalDbm?.toStringAsFixed(0) ?? "Non mesuré"} dBm — ${_liveSnapshot!.signalLabel}'),
                      if (_liveSnapshot!.latencyMs != null)
                        Text(
                            'Latence Internet (HTTP) : ${_liveSnapshot!.latencyMs} ms'),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => widget.onNavigate(2),
                  child: DashboardCard(
                      title: 'Positions',
                      value: '$_locations',
                      icon: Icons.gps_fixed),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => widget.onNavigate(6),
                  child: DashboardCard(
                      title: 'Itinéraires',
                      value: '$_routes',
                      icon: Icons.route),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => widget.onNavigate(5),
                  child: DashboardCard(
                      title: 'Routes',
                      value: '$_roads',
                      icon: Icons.construction),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => widget.onNavigate(4),
                  child: DashboardCard(
                      title: 'Réseau',
                      value: '$_networkCount',
                      icon: Icons.network_cell),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => widget.onNavigate(7),
            child: DashboardCard(
                title: 'Infrastructures & Sites utiles',
                value: '$_infrastructureCount',
                icon: Icons.location_city),
          ),
          const SizedBox(height: 8),
          if (_infrastructures.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                  'Infrastructures & Sites utiles enregistrés à proximité',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ..._infrastructures.take(3).map(
                  (infra) => Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.place, color: Colors.deepPurple),
                      title: Text(infra.name.isEmpty ? infra.type : infra.name),
                      subtitle: Text(
                          '${infra.type} • ${infra.latitude.toStringAsFixed(4)}, ${infra.longitude.toStringAsFixed(4)}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => widget.onNavigate(1),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
