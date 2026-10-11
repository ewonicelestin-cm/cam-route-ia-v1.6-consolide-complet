import 'package:flutter/material.dart';
import '../screens/ai_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/field_observation_screen.dart';
import '../screens/gps_screen.dart';
import '../screens/global_places_screen.dart';
import '../screens/history_screen.dart';
import '../screens/infrastructure_screen.dart';
import '../screens/map_screen.dart';
import '../screens/network_screen.dart';
import '../screens/roads_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/zone_intelligence_screen.dart';
import '../theme/app_theme.dart';

class CamRouteApp extends StatelessWidget {
  const CamRouteApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'CAM-ROUTE IA',
    theme: AppTheme.lightTheme,
    home: const MainNavigation(),
  );
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  late final List<Widget> pages = [
    DashboardScreen(onNavigate: (i) => setState(() => index = i)),
    const MapScreen(),
    const GpsScreen(),
    const GlobalPlacesScreen(),
    const NetworkScreen(),
    const RoadsScreen(),
    const HistoryScreen(),
    const InfrastructureScreen(),
    const FieldObservationScreen(),
    const ZoneIntelligenceScreen(),
    const AiScreen(),
    const SettingsScreen(),
  ];

  final titles = const [
    'Dashboard', 'Cartographie', 'GPS', 'Monde', 'Réseau mobile', 'Routes',
    'Historique', 'Infrastructures', 'Observation terrain', 'Analyse zone', 'Intelligence IA', 'Paramètres',
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(titles[index]),
      actions: [
        PopupMenuButton<int>(
          onSelected: (value) {
            if (value < 100) {
              setState(() => index = value);
            } else if (value == 100) {
              _showDataSourcesDialog(context);
            } else if (value == 101) {
              _showAppInfoDialog(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 0, child: Text('Tableau de bord')),
            const PopupMenuItem(value: 1, child: Text('Cartographie')),
            const PopupMenuItem(value: 5, child: Text('Itinéraires & Routes')),
            const PopupMenuItem(value: 4, child: Text('Réseau mobile')),
            const PopupMenuItem(value: 9, child: Text('Intelligence des zones')),
            const PopupMenuItem(value: 7, child: Text('Infrastructures')),
            const PopupMenuItem(value: 6, child: Text('Historique')),
            const PopupMenuItem(value: 11, child: Text('Paramètres')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 100, child: Text('Sources de données')),
            const PopupMenuItem(value: 101, child: Text("Informations de l'application")),
          ],
        ),
      ],
    ),
    body: IndexedStack(index: index, children: pages),
    drawer: Drawer(
      child: SafeArea(
        child: ListView(children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.map, color: Colors.white, size: 42),
                SizedBox(height: 8),
                Text('CAM-ROUTE IA', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text('Cartographie & mobilité', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          _item(Icons.dashboard, 'Accueil', 0), _item(Icons.map, 'Carte', 1),
          _item(Icons.gps_fixed, 'GPS', 2), _item(Icons.public, 'Monde', 3),
          _item(Icons.network_cell, 'Réseau', 4), _item(Icons.route, 'Routes', 5),
          _item(Icons.history, 'Historique', 6), _item(Icons.location_city, 'Infrastructures', 7),
          _item(Icons.edit_location_alt, 'Terrain', 8), _item(Icons.analytics, 'Analyse zone', 9), _item(Icons.auto_awesome, 'IA', 10),
          const Divider(), _item(Icons.settings, 'Paramètres', 11),
        ]),
      ),
    ),
  );

  Widget _item(IconData icon, String label, int value) => ListTile(
    leading: Icon(icon), title: Text(label), selected: index == value,
    onTap: () { setState(() => index = value); Navigator.pop(context); },
  );

  void _showDataSourcesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sources de Données'),
        content: const SingleChildScrollView(
          child: Text(
            '• Cartographie : OpenStreetMap (Tiles & Nominatim)\n\n'
            '• Routage : OSRM (Open Source Routing Machine) avec repli géométrique hors-ligne\n\n'
            '• Météo & Climat : Open-Meteo API\n\n'
            '• Sismologie : USGS & EMSC FDSNWS\n\n'
            '• Réseau Téléphonique : Android TelephonyManager (CellInfo GSM, WCDMA, LTE, NR) & tests de latence HTTP Cloudflare.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("À propos de CAM-ROUTE-IA"),
        content: const Text(
          'CAM-ROUTE-IA V1.6\n\n'
          'Application dédiée à la cartographie intelligente, au suivi GPS, à l’analyse de la qualité des réseaux mobiles et à la sécurité des déplacements routiers (priorité Cameroun & Afrique Centrale).\n\n'
          'Développée en Flutter & Dart.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }
}
