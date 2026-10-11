# CAM-ROUTE IA V1.6 — Inventaire des implémentations

Cette archive est la consolidation des implémentations préparées jusqu'à V1.6. Elle conserve l'ossature Flutter initiale et ajoute les modules mondiaux, la corrélation de corridor et l'analyse réseau.

## 1. Cartographie et routage
- OpenStreetMap via `flutter_map`.
- Calcul d'itinéraire routier via OSRM.
- Géométrie, distance et durée du trajet.
- Destination par sélection sur la carte.
- Affichage des observations locales.

## 2. Itinéraire intelligent
- Découpage de l'itinéraire en zones successives.
- Analyse de chaque zone.
- Corrélation sismologie + météo + réseau local + routes + infrastructures.
- Rapport de corridor complet.
- Notes de qualité et limitations.

## 3. Sismologie
- Requête d'événements récents auprès de l'USGS.
- Magnitude, profondeur, heure et localisation.
- Rayon d'analyse configurable dans le service.
- Les événements observés ne sont jamais présentés comme une prédiction.

## 4. Météo
- Conditions disponibles au point analysé.
- Température, vent et précipitations.
- Prévision de précipitations lorsque la source la fournit.
- Source et limites affichées.

## 5. Réseau téléphonique — priorité V1.6
- Mesure native Android lorsque l'appareil et Android exposent l'information.
- Opérateur.
- Technologie 2G / 3G / 4G-LTE / 5G lorsque détectable.
- Intensité radio en dBm lorsque disponible.
- RSRQ / qualité radio lorsque disponible.
- Test HTTP de latence.
- Horodatage de chaque mesure.
- Enregistrement local des mesures.
- Suivi périodique préparé côté application.
- Aucune couverture n'est affirmée lorsqu'elle n'est pas mesurée ou fournie par une source externe.

## 6. Sources de couverture externe
- Architecture documentaire pour données ITU/GSMA et autres sources.
- Les données externes sont distinguées des mesures du téléphone.
- Les dates, sources et limites doivent être conservées lors d'une future connexion à une API de couverture.

## 7. Données terrain
- Observations de routes.
- État des routes.
- Réseau observé.
- Infrastructures : ponts, péages, stations-service, travaux, etc.
- Coordonnées et horodatage SQLite.

## 8. Monde
- Catalogue préparatoire multi-continent.
- Pays, villes et lieux avec coordonnées.
- Architecture prête à étendre le catalogue sans changer les écrans principaux.

## 9. Base locale
- SQLite.
- Positions GPS.
- Routes analysées.
- Observations de routes.
- Mesures réseau.
- Infrastructures.
- Historique.

## 10. Qualité des données
Les états suivants doivent rester distincts :
- mesure réelle locale ;
- donnée externe ;
- donnée indisponible ;
- estimation du moteur de routage ;
- observation ancienne.

Une absence de mesure réseau ne signifie pas une absence de réseau. Une absence d'événement sismique dans une requête ne signifie pas une absence de risque. Une durée OSRM ne constitue pas une garantie de temps de trajet.

## 11. Android
- Ossature Android incluse.
- Permissions Internet et localisation incluses.
- `MainActivity.kt` expose un canal Flutter natif pour les informations radio disponibles.

## 12. Validation
Cette archive contient le code source consolidé. La compilation finale et les tests doivent être exécutés avec Flutter/Android SDK sur la machine de développement :

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --release
```

Aucune donnée externe non vérifiée ne doit être ajoutée comme mesure réelle.
