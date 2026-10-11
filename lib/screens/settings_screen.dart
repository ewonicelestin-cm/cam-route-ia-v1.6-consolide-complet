import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(12),
    children: const [
      Card(
        child: ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('CAM-ROUTE IA'),
          subtitle: Text('Version 1.6.0 — Cartographie & Mobilité Intelligente'),
        ),
      ),
      Card(
        child: ListTile(
          leading: Icon(Icons.public),
          title: Text('Couverture Géographique'),
          subtitle: Text('Couverture globale étendue : grandes métropoles, communes rurales, villages de brousse, enclaves & zones d\'accès difficile (Cameroun, Afrique & Monde)'),
        ),
      ),
      Card(
        child: ListTile(
          leading: Icon(Icons.map),
          title: Text('Cartographie'),
          subtitle: Text('OpenStreetMap (Tiles, Nominatim & Photon Geocoder) avec parsing GPS direct'),
        ),
      ),
      Card(
        child: ListTile(
          leading: Icon(Icons.alt_route),
          title: Text('Routage & Corridor'),
          subtitle: Text('OSRM avec estimation géométrique locale hors-ligne pour zones non répertoriées'),
        ),
      ),
      Card(
        child: ListTile(
          leading: Icon(Icons.storage),
          title: Text('Stockage'),
          subtitle: Text('SQLite local'),
        ),
      ),
    ],
  );
}
