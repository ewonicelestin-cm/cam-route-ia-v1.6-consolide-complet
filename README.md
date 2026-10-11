# CAM-ROUTE IA — V1 complète

Application Flutter Android de cartographie, GPS, itinéraires, observations terrain, réseau mobile, infrastructures, historique et analyse IA locale.

## Ossature
- `lib/app/` : navigation et application
- `lib/models/` : modèles de données
- `lib/services/` : GPS, SQLite, OSRM et IA
- `lib/screens/` : toutes les interfaces
- `lib/widgets/` : composants réutilisables
- `lib/theme/` : thème
- `android/` : socle Android
- `test/` : tests Flutter
- `assets/` : ressources locales

## Fonctionnalités V1
1. Dashboard avec compteurs SQLite.
2. Carte OpenStreetMap.
3. Position GPS et recentrage.
4. Sélection d'une destination sur la carte.
5. Calcul d'itinéraire routier avec OSRM.
6. Enregistrement des itinéraires dans SQLite.
7. Historique et suppression des itinéraires.
8. Observations routes : type, état, description et coordonnées.
9. Observations réseau : opérateur, technologie et coordonnées.
10. Infrastructures : pont, péage, station-service, travaux, autre.
11. Affichage cartographique des couches terrain.
12. Analyse IA locale déterministe basée uniquement sur les données enregistrées.
13. Paramètres et informations techniques.

## Intégrité des données
CAM-ROUTE IA ne fabrique pas une mesure GPS, réseau, signal ou état de route. Une donnée non collectée est affichée comme indisponible.

## Préparation Android
Le dossier `android/` est fourni comme ossature. Pour synchroniser automatiquement les fichiers natifs avec la version de Flutter installée sur le PC, exécuter à la racine :

```bash
flutter create --platforms=android .
```

Puis :

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run
```

Pour l'APK release :

```bash
flutter build apk --release
```

APK attendu : `build/app/outputs/flutter-apk/app-release.apk`

## Dépendances principales
- geolocator : GPS
- sqflite + path : stockage local
- flutter_map + latlong2 : cartographie
- http : communication OSRM

## Étape suivante
V1 → Android Beta : validation sur appareil réel, permissions GPS, tests carte/itinéraire, persistance SQLite, puis optimisation hors-ligne et enrichissement IA.


## Extension mondiale préparatoire

Le projet contient maintenant un catalogue géographique préparatoire couvrant plusieurs continents, pays, villes et sites de référence. Il est accessible depuis le menu **Monde**.

Fonctions intégrées :
- sélection par continent ;
- sélection par pays ;
- recherche par ville, pays ou lieu ;
- coordonnées GPS préparatoires ;
- sélection d'un lieu comme destination cartographique ;
- recentrage de la carte sur le lieu sélectionné ;
- utilisation de cette destination avec le moteur de routage OSRM ;
- architecture prête pour l'ajout progressif de nouveaux pays et lieux sans modifier la navigation principale.

Les coordonnées du catalogue sont des points de référence préparatoires. Elles ne constituent pas des mesures terrain et ne remplacent pas les données cartographiques en temps réel.

## Module mondial de corrélation sécurité / environnement

La version préparatoire ajoute une analyse par coordonnées qui peut corréler :
- événements sismiques récents via le catalogue USGS ;
- météo actuelle via une source météo externe ;
- identification administrative de la zone ;
- mesures réseau et observations terrain stockées localement ;
- préparation des couches de couverture mobile et QoS issues de l'ITU Disaster Connectivity Maps ;
- routes et infrastructures sensibles déjà présentes dans CAM-ROUTE IA.

Règle de qualité : une donnée externe, une mesure terrain et une estimation IA sont toujours distinguées. Aucun niveau de couverture ou danger n'est inventé lorsqu'une source manque.


## Corrélation sur un itinéraire complet (v1.2.0)

Depuis **Analyse zone**, saisissez les coordonnées du départ et de l’arrivée, puis lancez **Analyser tout l’itinéraire**. L’application demande un itinéraire routier à OSRM, échantillonne jusqu’à six points le long de la géométrie retournée et recherche pour chaque point les événements sismiques récents USGS et les conditions météo actuelles Open-Meteo. Les résultats par zone sont consultables dans des panneaux dépliables.

Sources externes : OSRM (calcul routier), USGS Earthquake Catalog (événements sismiques), Open-Meteo (météo). Ces services nécessitent Internet et leur disponibilité peut varier. Le calcul public OSRM est fourni sans garantie de disponibilité.

**Limites actuelles :** les points sont des échantillons représentatifs, pas une analyse de chaque mètre du trajet. La couverture cellulaire n’est pas déduite de façon fiable par cette version ; elle reste « non déterminée » en l’absence de cartes opérateur ou de mesures terrain. Les alertes de sécurité doivent être vérifiées auprès des autorités locales.

## V1.4 — Itinéraire intelligent et données réelles

L'analyse d'itinéraire combine désormais, zone par zone :
- le tracé routier OSRM/OpenStreetMap ;
- les événements sismiques observés via USGS ;
- les conditions météo actuelles et la pluie cumulée prévue sur les 6 prochaines heures via Open-Meteo ;
- les mesures réseau réellement enregistrées dans l'application ;
- les observations de routes et infrastructures enregistrées localement.

Les données absentes restent explicitement absentes. Une absence de mesure réseau ne signifie pas absence de couverture. Un événement sismique observé n'est pas une prédiction de séisme.


## Réseau téléphonique V1.5

La version 1.6 ajoute la mesure radio réelle du téléphone Android et un mode de suivi réseau pendant le déplacement. Le suivi fonctionne au premier plan et enregistre une mesure toutes les 30 secondes avec la position GPS. Les valeurs radio sont distinguées des données de couverture externes. Voir `NETWORK_DATA_SOURCES.md`.

## Qualité du routage et secours hors ligne

Le calcul d’itinéraire tente d’abord d’utiliser OSRM/Carto. Si la connexion Internet est indisponible ou si le service ne répond pas, l’application construit désormais une approximation locale géométrique du trajet et affiche explicitement qu’il s’agit d’une estimation hors ligne. Cette estimation est signalée comme telle dans la carte et dans l’analyse de corridor, afin de ne pas la confondre avec une vraie route calculée par le service de navigation.

L’application conserve toujours une séparation claire entre :
- mesure réelle du téléphone ;
- donnée externe (météo, sismologie, cartes de couverture) ;
- estimation locale hors ligne ;
- donnée indisponible.
