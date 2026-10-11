# Sources et qualité des données réseau

CAM-ROUTE IA distingue strictement trois niveaux :

1. **Mesure locale du téléphone** : opérateur, technologie, intensité radio (dBm) et, lorsque Android l'expose, paramètre radio de qualité (dB). Une mesure est enregistrée avec GPS et horodatage.
2. **Performance Internet mesurée** : latence HTTP vers une destination de test. Cette latence n'est pas une mesure pure du signal radio et ne doit pas être interprétée comme telle.
3. **Données externes de couverture** : les cartes ITU/GSMA peuvent servir de contexte mondial. Elles sont affichées comme données externes et non comme mesure locale.

Références officielles consultées pour la conception :
- ITU Disaster Connectivity Map : https://dcm.itu.int/
- ITU Connectivity Maps : https://www.itu.int/en/ITU-D/Emergency-Telecommunications/Pages/EW4ALL/Connectivity-maps.aspx
- GSMA Coverage Maps : https://www.gsma.com/coverage/

Important : une zone sans mesure locale n'est pas considérée comme une zone sans réseau. Les cartes externes peuvent avoir des dates, résolutions et sources différentes. L'application doit conserver la source et l'horodatage afin d'éviter toute confusion.
