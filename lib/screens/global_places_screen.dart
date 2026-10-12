import 'package:flutter/material.dart';
import '../models/global_place.dart';
import '../services/global_place_catalog.dart';

class GlobalPlacesScreen extends StatefulWidget {
  const GlobalPlacesScreen({super.key});

  @override
  State<GlobalPlacesScreen> createState() => _GlobalPlacesScreenState();
}

class _GlobalPlacesScreenState extends State<GlobalPlacesScreen> {
  String? _continent;
  String? _country;
  String? _type;
  String _query = '';
  bool _remoteOnly = false;
  bool _searching = false;
  List<GlobalPlace> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _updateResults();
  }

  Future<void> _updateResults() async {
    final local = GlobalPlaceCatalog.filter(
      continent: _continent,
      country: _country,
      type: _type,
      query: _query,
      remoteOnly: _remoteOnly,
    );
    setState(() => _searchResults = local);

    if (_query.trim().length >= 2) {
      setState(() => _searching = true);
      final global = await GlobalPlaceCatalog.searchGlobal(
        _query,
        continent: _continent,
        country: _country,
        type: _type,
        remoteOnly: _remoteOnly,
      );
      if (mounted) {
        setState(() {
          _searchResults = global;
          _searching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final continents = GlobalPlaceCatalog.continents;
    final countries = _continent == null
        ? <String>[]
        : GlobalPlaceCatalog.countries(_continent!);
    final types = GlobalPlaceCatalog.types;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText:
                          'Rechercher ville, village, campagne, enclave ou coordonnées GPS',
                      hintText:
                          'Ex: "Kousséri", "Yokadouma", "Mundemba" ou "3.848, 11.502"',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_query.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() => _query = '');
                                _updateResults();
                              },
                            ),
                          if (_searching)
                            const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            ),
                        ],
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      setState(() => _query = v);
                      _updateResults();
                    },
                  ),
                  const SizedBox(height: 10),
                  // Filtres rapides en puces (Chips)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Toutes'),
                          selected: _continent == null &&
                              _country == null &&
                              !_remoteOnly &&
                              _type == null,
                          onSelected: (_) {
                            setState(() {
                              _continent = null;
                              _country = null;
                              _type = null;
                              _remoteOnly = false;
                            });
                            _updateResults();
                          },
                        ),
                        const SizedBox(width: 6),
                        FilterChip(
                          avatar: const Text('🇨🇲',
                              style: TextStyle(fontSize: 12)),
                          label: const Text('Cameroun complet'),
                          selected: _country == 'Cameroun',
                          onSelected: (selected) {
                            setState(() {
                              _continent = selected ? 'Afrique' : null;
                              _country = selected ? 'Cameroun' : null;
                            });
                            _updateResults();
                          },
                        ),
                        const SizedBox(width: 6),
                        FilterChip(
                          avatar: const Icon(Icons.agriculture, size: 16),
                          label: const Text('Campagnes & Villages'),
                          selected: _type == 'Village / Campagne' ||
                              _type == 'Commune rurale',
                          onSelected: (selected) {
                            setState(() {
                              _type = selected ? 'Village / Campagne' : null;
                            });
                            _updateResults();
                          },
                        ),
                        const SizedBox(width: 6),
                        FilterChip(
                          avatar: const Icon(Icons.terrain, size: 16),
                          label: const Text('Zones reculées / Accès difficile'),
                          selected: _remoteOnly,
                          onSelected: (selected) {
                            setState(() => _remoteOnly = selected);
                            _updateResults();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          // ignore: deprecated_member_use
                          value: _continent,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Continent',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                          ),
                          items: continents
                              .map((x) => DropdownMenuItem(
                                  value: x,
                                  child:
                                      Text(x, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _continent = v;
                              _country = null;
                            });
                            _updateResults();
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          // ignore: deprecated_member_use
                          value: _country,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Pays',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                          ),
                          items: countries
                              .map((x) => DropdownMenuItem(
                                  value: x,
                                  child:
                                      Text(x, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: _continent == null
                              ? null
                              : (v) {
                                  setState(() => _country = v);
                                  _updateResults();
                                },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          // ignore: deprecated_member_use
                          value: _type,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                          ),
                          items: types
                              .map((x) => DropdownMenuItem(
                                  value: x,
                                  child:
                                      Text(x, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (v) {
                            setState(() => _type = v);
                            _updateResults();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.public, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${_searchResults.length} localités accessibles (villes, campagnes, zones isolées)',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _continent = null;
                            _country = null;
                            _type = null;
                            _remoteOnly = false;
                            _query = '';
                          });
                          _updateResults();
                        },
                        child: const Text('Réinitialiser'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: _searchResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text(
                        'Aucune localité trouvée pour cette recherche.',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Astuce : Tape des coordonnées GPS (ex: 3.848, 11.502) ou le nom du village.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) =>
                      _placeCard(context, _searchResults[index]),
                ),
        ),
      ],
    );
  }

  Widget _placeCard(BuildContext context, GlobalPlace place) {
    final selected = identical(GlobalPlaceCatalog.selected.value, place);
    final isRemote = place.isRemote;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isRemote
              ? Colors.orange.shade100
              : Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            place.countryCode.isNotEmpty ? place.countryCode : 'INT',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isRemote
                  ? Colors.orange.shade900
                  : Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          place.label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                Chip(
                  label: Text(place.type, style: const TextStyle(fontSize: 10)),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                if (isRemote) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 12, color: Colors.orange),
                        SizedBox(width: 2),
                        Text('Zone reculée / Accès difficile',
                            style:
                                TextStyle(fontSize: 10, color: Colors.orange)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${place.continent} • GPS: ${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: selected
            ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
            : const Icon(Icons.chevron_right),
        onTap: () {
          GlobalPlaceCatalog.selected.set(place);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${place.name} (${place.country}) sélectionné pour la cartographie & routage.'),
              backgroundColor: Colors.green.shade800,
            ),
          );
        },
      ),
    );
  }
}
