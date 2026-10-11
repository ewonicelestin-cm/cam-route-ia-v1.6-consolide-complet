import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class FieldObservationScreen extends StatefulWidget {
  const FieldObservationScreen({super.key});

  @override
  State<FieldObservationScreen> createState() => _FieldObservationScreenState();
}

class _FieldObservationScreenState extends State<FieldObservationScreen> {
  final LocationService _loc = LocationService();
  final DatabaseService _db = DatabaseService();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _signalController = TextEditingController();
  final TextEditingController _qualityController = TextEditingController();

  String _category = 'Route';
  String _roadType = 'Bitumée';
  String _condition = 'Bon';
  String _operatorName = 'Non renseigné';
  String _technology = 'Non renseigné';
  String _infrastructureType = 'Pont';

  Future<void> _save() async {
    final p = await _loc.getCurrentPosition();
    if (p == null) {
      _msg('Position GPS indisponible.');
      return;
    }
    final now = DateTime.now();
    if (_category == 'Route') {
      await _db.insertRoadObservation(
        RoadObservation(
          latitude: p.latitude,
          longitude: p.longitude,
          roadType: _roadType,
          condition: _condition,
          description: _description.text.trim(),
          timestamp: now,
        ),
      );
    } else if (_category == 'Réseau') {
      final sig = double.tryParse(_signalController.text.trim().replaceAll(',', '.'));
      final qual = double.tryParse(_qualityController.text.trim().replaceAll(',', '.'));
      await _db.insertNetworkMeasurement(
        NetworkMeasurement(
          latitude: p.latitude,
          longitude: p.longitude,
          operator: _operatorName,
          technology: _technology,
          signalStrength: sig,
          quality: qual,
          timestamp: now,
        ),
      );
    } else {
      await _db.insertInfrastructure(
        InfrastructurePoint(
          latitude: p.latitude,
          longitude: p.longitude,
          type: _infrastructureType,
          name: _name.text.trim(),
          description: _description.text.trim(),
          timestamp: now,
        ),
      );
    }
    _description.clear();
    _name.clear();
    _signalController.clear();
    _qualityController.clear();
    if (mounted) _msg('Observation enregistrée.');
  }

  void _msg(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _category,
            decoration: const InputDecoration(labelText: 'Catégorie'),
            items: const ['Route', 'Réseau', 'Infrastructure']
                .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _category = v);
            },
          ),
          const SizedBox(height: 10),
          if (_category == 'Route') ...[
            _drop('Type de route', _roadType, ['Bitumée', 'Latérite', 'Piste', 'Autre'], (v) => _roadType = v),
            _drop('État', _condition, ['Bon', 'Moyen', 'Mauvais'], (v) => _condition = v),
          ],
          if (_category == 'Réseau') ...[
            _drop('Opérateur', _operatorName, ['Non renseigné', 'MTN', 'Orange', 'Camtel', 'Nexttel'], (v) => _operatorName = v),
            _drop('Technologie', _technology, ['Non renseigné', '2G', '3G', '4G', '5G'], (v) => _technology = v),
            TextField(
              controller: _signalController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(labelText: 'Intensité signal optionnelle (dBm, ex: -85)'),
            ),
            TextField(
              controller: _qualityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(labelText: 'Qualité signal optionnelle (dB/RSRQ)'),
            ),
          ],
          if (_category == 'Infrastructure') ...[
            _drop('Type', _infrastructureType, ['Pont', 'Péage', 'Station-service', 'Travaux', 'Autre'], (v) => _infrastructureType = v),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nom')),
          ],
          TextField(
            controller: _description,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Enregistrer avec GPS'),
          ),
        ],
      );

  Widget _drop(String l, String v, List<String> a, ValueChanged<String> f) => DropdownButtonFormField<String>(
        // ignore: deprecated_member_use
        value: v,
        decoration: InputDecoration(labelText: l),
        items: a.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
        onChanged: (x) {
          if (x != null) setState(() => f(x));
        },
      );

  @override
  void dispose() {
    _description.dispose();
    _name.dispose();
    _signalController.dispose();
    _qualityController.dispose();
    super.dispose();
  }
}
