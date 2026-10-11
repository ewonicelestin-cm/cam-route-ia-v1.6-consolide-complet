import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/global_place.dart';

class SelectedPlaceNotifier extends ValueNotifier<GlobalPlace?> {
  SelectedPlaceNotifier() : super(null);
  void set(GlobalPlace? place) => value = place;
}

class GlobalPlaceCatalog {
  static final selected = SelectedPlaceNotifier();

  static const places = <GlobalPlace>[
    // =========================================================================
    // CAMEROUN - COUVERTURE EXHAUSTIVE (10 RÉGIONS, VILLES, COMMUNES, VILLAGES & ZONES RECULÉES)
    // =========================================================================
    // --- Centre ---
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Yaoundé',name:'Yaoundé',type:'Capitale',latitude:3.8480,longitude:11.5021,region:'Centre'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Mbalmayo',name:'Mbalmayo',type:'Ville',latitude:3.5167,longitude:11.5000,region:'Centre'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Bafia',name:'Bafia',type:'Chef-lieu / Commune',latitude:4.7500,longitude:11.2333,region:'Centre'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Ntui',name:'Ntui',type:'Commune rurale',latitude:4.4500,longitude:11.6333,region:'Centre'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Monatélé',name:'Monatélé',type:'Chef-lieu / Commune',latitude:4.4000,longitude:11.2000,region:'Centre'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Esse',name:'Esse',type:'Village / Campagne',latitude:3.9333,longitude:11.9000,region:'Centre'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Mfou',name:'Mfou',type:'Commune rurale',latitude:3.7167,longitude:11.6333,region:'Centre'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Sa\'a',name:'Sa\'a',type:'Commune rurale',latitude:4.3667,longitude:11.4500,region:'Centre'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Obala',name:'Obala',type:'Ville',latitude:4.1667,longitude:11.5333,region:'Centre'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Akonolinga',name:'Akonolinga',type:'Commune rurale',latitude:3.7667,longitude:12.2500,region:'Centre'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Nanga-Eboko',name:'Nanga-Eboko',type:'Chef-lieu / Commune',latitude:4.6833,longitude:12.3667,region:'Centre'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Yoko',name:'Yoko',type:'Zone reculée / Enclave',latitude:5.5333,longitude:12.3167,region:'Centre',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Ngambe-Tikar',name:'Ngambe-Tikar',type:'Zone reculée / Enclave',latitude:5.8333,longitude:11.7500,region:'Centre',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Mbandjock',name:'Mbandjock',type:'Ville',latitude:4.4500,longitude:11.9000,region:'Centre'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Nkoteng',name:'Nkoteng',type:'Commune rurale',latitude:4.5167,longitude:12.0333,region:'Centre'),

    // --- Littoral ---
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Douala',name:'Douala',type:'Ville',latitude:4.0511,longitude:9.7679,region:'Littoral'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Edéa',name:'Edéa',type:'Ville',latitude:3.8000,longitude:10.1333,region:'Littoral'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Nkongsamba',name:'Nkongsamba',type:'Ville',latitude:4.9500,longitude:9.9333,region:'Littoral'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Loum',name:'Loum',type:'Commune rurale',latitude:4.7167,longitude:9.7333,region:'Littoral'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Mbanga',name:'Mbanga',type:'Commune rurale',latitude:4.5000,longitude:9.5667,region:'Littoral'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Yabassi',name:'Yabassi',type:'Zone reculée / Enclave',latitude:4.4500,longitude:9.9667,region:'Littoral',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Mouanko',name:'Mouanko',type:'Village / Campagne',latitude:3.6333,longitude:9.7833,region:'Littoral',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Dizangué',name:'Dizangué',type:'Village / Campagne',latitude:3.7667,longitude:9.9833,region:'Littoral'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Dibombari',name:'Dibombari',type:'Commune rurale',latitude:4.1833,longitude:9.6500,region:'Littoral'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Melong',name:'Melong',type:'Commune rurale',latitude:5.1167,longitude:9.9500,region:'Littoral'),

    // --- Ouest ---
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Bafoussam',name:'Bafoussam',type:'Ville',latitude:5.4781,longitude:10.4179,region:'Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Mbouda',name:'Mbouda',type:'Ville',latitude:5.6333,longitude:10.2500,region:'Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Dschang',name:'Dschang',type:'Ville',latitude:5.4500,longitude:10.0500,region:'Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Foumban',name:'Foumban',type:'Ville',latitude:5.7167,longitude:10.9000,region:'Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Bangangté',name:'Bangangté',type:'Chef-lieu / Commune',latitude:5.1500,longitude:10.5167,region:'Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Bafang',name:'Bafang',type:'Chef-lieu / Commune',latitude:5.1500,longitude:10.1833,region:'Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Bandjoun',name:'Bandjoun',type:'Commune rurale',latitude:5.3500,longitude:10.4167,region:'Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Foumbot',name:'Foumbot',type:'Commune rurale',latitude:5.5167,longitude:10.6333,region:'Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Kouoptamo',name:'Kouoptamo',type:'Village / Campagne',latitude:5.6500,longitude:10.6000,region:'Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Kekem',name:'Kekem',type:'Village / Campagne',latitude:5.1500,longitude:10.0167,region:'Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Galim',name:'Galim',type:'Village / Campagne',latitude:5.6000,longitude:10.4333,region:'Ouest'),

    // --- Nord-Ouest ---
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Bamenda',name:'Bamenda',type:'Ville',latitude:5.9600,longitude:10.1500,region:'Nord-Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Kumbo',name:'Kumbo',type:'Chef-lieu / Commune',latitude:6.2000,longitude:10.6833,region:'Nord-Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Nkambe',name:'Nkambe',type:'Zone reculée / Enclave',latitude:6.5833,longitude:10.6667,region:'Nord-Ouest',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Wum',name:'Wum',type:'Chef-lieu / Commune',latitude:6.3833,longitude:10.0667,region:'Nord-Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Ndop',name:'Ndop',type:'Commune rurale',latitude:6.0000,longitude:10.4167,region:'Nord-Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Fundong',name:'Fundong',type:'Commune rurale',latitude:6.2667,longitude:10.2833,region:'Nord-Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Mbengwi',name:'Mbengwi',type:'Commune rurale',latitude:6.0167,longitude:10.0000,region:'Nord-Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Batibo',name:'Batibo',type:'Village / Campagne',latitude:5.8333,longitude:9.8333,region:'Nord-Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Fur Awa',name:'Fur Awa',type:'Zone reculée / Enclave',latitude:6.8500,longitude:10.0500,region:'Nord-Ouest',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Ako',name:'Ako',type:'Zone reculée / Enclave',latitude:6.8000,longitude:10.7000,region:'Nord-Ouest',isRemote:true),

    // --- Sud-Ouest ---
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Buea',name:'Buea',type:'Ville',latitude:4.1550,longitude:9.2414,region:'Sud-Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Limbe',name:'Limbe',type:'Ville',latitude:4.0200,longitude:9.2100,region:'Sud-Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Kumba',name:'Kumba',type:'Ville',latitude:4.6333,longitude:9.4500,region:'Sud-Ouest'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Mamfe',name:'Mamfe',type:'Zone reculée / Enclave',latitude:5.7500,longitude:9.3167,region:'Sud-Ouest',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Mundemba',name:'Mundemba (Korup)',type:'Zone reculée / Enclave',latitude:4.9667,longitude:8.9667,region:'Sud-Ouest',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Akwaya',name:'Akwaya',type:'Zone reculée / Enclave',latitude:6.2333,longitude:9.1833,region:'Sud-Ouest',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Eyumojock',name:'Eyumojock',type:'Poste frontière',latitude:5.7000,longitude:8.9833,region:'Sud-Ouest',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Idabato',name:'Bakassi (Idabato)',type:'Zone reculée / Enclave',latitude:4.6000,longitude:8.6167,region:'Sud-Ouest',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Bangem',name:'Bangem',type:'Zone de montagne',latitude:5.0833,longitude:9.7167,region:'Sud-Ouest'),

    // --- Adamaoua ---
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Ngaoundéré',name:'Ngaoundéré',type:'Ville',latitude:7.3167,longitude:13.5833,region:'Adamaoua'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Meiganga',name:'Meiganga',type:'Chef-lieu / Commune',latitude:6.5167,longitude:14.3000,region:'Adamaoua'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Tibati',name:'Tibati',type:'Commune rurale',latitude:6.4667,longitude:12.6333,region:'Adamaoua'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Banyo',name:'Banyo',type:'Zone reculée / Enclave',latitude:6.7500,longitude:11.8167,region:'Adamaoua',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Tignère',name:'Tignère',type:'Zone reculée / Enclave',latitude:7.3667,longitude:12.6500,region:'Adamaoua',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Djohong',name:'Djohong',type:'Poste frontière',latitude:6.8333,longitude:14.7000,region:'Adamaoua',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Kontcha',name:'Kontcha',type:'Zone reculée / Enclave',latitude:8.0000,longitude:12.2167,region:'Adamaoua',isRemote:true),

    // --- Nord ---
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Garoua',name:'Garoua',type:'Ville',latitude:9.3000,longitude:13.4000,region:'Nord'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Guider',name:'Guider',type:'Chef-lieu / Commune',latitude:9.9333,longitude:13.9500,region:'Nord'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Poli',name:'Poli',type:'Zone reculée / Enclave',latitude:8.4833,longitude:13.2500,region:'Nord',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Tcholliré',name:'Tcholliré',type:'Commune rurale',latitude:8.4000,longitude:14.1667,region:'Nord',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Touboro',name:'Touboro',type:'Poste frontière',latitude:7.7833,longitude:15.3667,region:'Nord',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Figuil',name:'Figuil',type:'Commune rurale',latitude:9.7667,longitude:13.9667,region:'Nord'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Rey-Bouba',name:'Rey-Bouba',type:'Village / Campagne',latitude:8.6667,longitude:14.1667,region:'Nord',isRemote:true),

    // --- Extrême-Nord ---
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Maroua',name:'Maroua',type:'Ville',latitude:10.5972,longitude:14.3158,region:'Extrême-Nord'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Kousséri',name:'Kousséri',type:'Poste frontière',latitude:12.0769,longitude:15.0306,region:'Extrême-Nord'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Yagoua',name:'Yagoua',type:'Chef-lieu / Commune',latitude:10.3411,longitude:15.2328,region:'Extrême-Nord'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Mokolo',name:'Mokolo',type:'Zone de montagne',latitude:10.7425,longitude:13.8022,region:'Extrême-Nord'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Mora',name:'Mora',type:'Chef-lieu / Commune',latitude:11.0461,longitude:14.1403,region:'Extrême-Nord'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Kaélé',name:'Kaélé',type:'Commune rurale',latitude:10.1089,longitude:14.4508,region:'Extrême-Nord'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Waza',name:'Waza (Parc)',type:'Zone reculée / Enclave',latitude:11.3833,longitude:14.5667,region:'Extrême-Nord',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Kolofata',name:'Kolofata',type:'Poste frontière',latitude:11.1600,longitude:14.0100,region:'Extrême-Nord',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Fotokol',name:'Fotokol (Lac Tchad)',type:'Zone reculée / Enclave',latitude:12.3700,longitude:14.2300,region:'Extrême-Nord',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Blangoua',name:'Blangoua',type:'Zone reculée / Enclave',latitude:12.7800,longitude:14.5500,region:'Extrême-Nord',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Roua',name:'Roua (Monts Mandara)',type:'Zone de montagne',latitude:10.8200,longitude:13.8800,region:'Extrême-Nord',isRemote:true),

    // --- Est ---
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Bertoua',name:'Bertoua',type:'Ville',latitude:4.5833,longitude:13.6833,region:'Est'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Abong-Mbang',name:'Abong-Mbang',type:'Chef-lieu / Commune',latitude:3.9833,longitude:13.1833,region:'Est'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Batouri',name:'Batouri',type:'Chef-lieu / Commune',latitude:4.4333,longitude:14.3667,region:'Est'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Yokadouma',name:'Yokadouma',type:'Zone reculée / Enclave',latitude:3.5167,longitude:15.0500,region:'Est',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Moloundou',name:'Moloundou (Sanga)',type:'Zone reculée / Enclave',latitude:2.0500,longitude:15.2167,region:'Est',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Lomié',name:'Lomié (Dja)',type:'Zone reculée / Enclave',latitude:3.1667,longitude:13.6167,region:'Est',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Garoua-Boulaï',name:'Garoua-Boulaï',type:'Poste frontière',latitude:5.8833,longitude:14.5500,region:'Est'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Betare-Oya',name:'Betare-Oya',type:'Commune rurale',latitude:5.6000,longitude:14.0833,region:'Est'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Ngoyla',name:'Ngoyla',type:'Zone reculée / Enclave',latitude:2.8000,longitude:14.1500,region:'Est',isRemote:true),

    // --- Sud ---
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Ebolowa',name:'Ebolowa',type:'Ville',latitude:2.9000,longitude:11.1500,region:'Sud'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Kribi',name:'Kribi',type:'Ville',latitude:2.9333,longitude:9.9167,region:'Sud'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Sangmélima',name:'Sangmélima',type:'Chef-lieu / Commune',latitude:2.9333,longitude:11.9833,region:'Sud'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Ambam',name:'Ambam',type:'Poste frontière',latitude:2.3833,longitude:11.2833,region:'Sud'),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Campo',name:'Campo',type:'Zone reculée / Enclave',latitude:2.3667,longitude:9.8167,region:'Sud',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Djoum',name:'Djoum',type:'Zone reculée / Enclave',latitude:2.6667,longitude:12.6667,region:'Sud',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Ma\'an',name:'Ma\'an',type:'Zone reculée / Enclave',latitude:2.3500,longitude:10.6167,region:'Sud',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Mintom',name:'Mintom',type:'Zone reculée / Enclave',latitude:2.7000,longitude:13.3000,region:'Sud',isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Cameroun',countryCode:'CM',city:'Lolodorf',name:'Lolodorf',type:'Commune rurale',latitude:3.2333,longitude:10.7333,region:'Sud'),

    // =========================================================================
    // RESTE DE L'AFRIQUE (VILLES, BROUSSE, OASES & PAYS VOISINS)
    // =========================================================================
    GlobalPlace(continent:'Afrique',country:'Nigeria',countryCode:'NG',city:'Lagos',name:'Lagos',type:'Ville',latitude:6.5244,longitude:3.3792),
    GlobalPlace(continent:'Afrique',country:'Nigeria',countryCode:'NG',city:'Abuja',name:'Abuja',type:'Capitale',latitude:9.0765,longitude:7.3986),
    GlobalPlace(continent:'Afrique',country:'Nigeria',countryCode:'NG',city:'Gembu',name:'Mambilla Plateau (Gembu)',type:'Zone de montagne',latitude:6.7167,longitude:11.2500,isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Tchad',countryCode:'TD',city:'N\'Djamena',name:'N\'Djamena',type:'Capitale',latitude:12.1348,longitude:15.0557),
    GlobalPlace(continent:'Afrique',country:'Tchad',countryCode:'TD',city:'Faya-Largeau',name:'Faya-Largeau',type:'Oasis',latitude:17.9256,longitude:19.1042,isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Tchad',countryCode:'TD',city:'Bardai',name:'Bardaï (Monts Tibesti)',type:'Zone reculée / Enclave',latitude:21.3547,longitude:17.0014,isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Centrafrique',countryCode:'CF',city:'Bangui',name:'Bangui',type:'Capitale',latitude:4.3947,longitude:18.5582),
    GlobalPlace(continent:'Afrique',country:'Centrafrique',countryCode:'CF',city:'Birao',name:'Birao',type:'Zone reculée / Enclave',latitude:10.2849,longitude:22.7882,isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Congo',countryCode:'CG',city:'Brazzaville',name:'Brazzaville',type:'Capitale',latitude:-4.2634,longitude:15.2429),
    GlobalPlace(continent:'Afrique',country:'Congo',countryCode:'CG',city:'Impfondo',name:'Impfondo (Cuvette)',type:'Zone reculée / Enclave',latitude:1.6333,longitude:18.0667,isRemote:true),
    GlobalPlace(continent:'Afrique',country:'RDC',countryCode:'CD',city:'Kinshasa',name:'Kinshasa',type:'Capitale',latitude:-4.4419,longitude:15.2663),
    GlobalPlace(continent:'Afrique',country:'RDC',countryCode:'CD',city:'Goma',name:'Goma',type:'Ville',latitude:-1.6585,longitude:29.2230),
    GlobalPlace(continent:'Afrique',country:'RDC',countryCode:'CD',city:'Shabunda',name:'Shabunda (Forêt centrale)',type:'Zone reculée / Enclave',latitude:-2.8333,longitude:27.3333,isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Gabon',countryCode:'GA',city:'Libreville',name:'Libreville',type:'Capitale',latitude:0.4162,longitude:9.4673),
    GlobalPlace(continent:'Afrique',country:'Gabon',countryCode:'GA',city:'Makokou',name:'Makokou',type:'Zone reculée / Enclave',latitude:0.5667,longitude:12.8500,isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Guinée Équatoriale',countryCode:'GQ',city:'Malabo',name:'Malabo',type:'Capitale',latitude:3.7504,longitude:8.7371),
    GlobalPlace(continent:'Afrique',country:'Guinée Équatoriale',countryCode:'GQ',city:'Annobón',name:'Île d\'Annobón',type:'Île isolée',latitude:-1.4300,longitude:5.6300,isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Côte d\'Ivoire',countryCode:'CI',city:'Abidjan',name:'Abidjan',type:'Ville',latitude:5.3600,longitude:-4.0083),
    GlobalPlace(continent:'Afrique',country:'Côte d\'Ivoire',countryCode:'CI',city:'Odienné',name:'Odienné',type:'Commune rurale',latitude:9.5000,longitude:-7.5667),
    GlobalPlace(continent:'Afrique',country:'Sénégal',countryCode:'SN',city:'Dakar',name:'Dakar',type:'Capitale',latitude:14.7167,longitude:-17.4677),
    GlobalPlace(continent:'Afrique',country:'Sénégal',countryCode:'SN',city:'Kédougou',name:'Kédougou (Pays Bassari)',type:'Zone reculée / Enclave',latitude:12.5500,longitude:-12.1833,isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Mali',countryCode:'ML',city:'Tombouctou',name:'Tombouctou',type:'Oasis',latitude:16.7666,longitude:-3.0026,isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Mali',countryCode:'ML',city:'Kidal',name:'Kidal (Adrar)',type:'Zone reculée / Enclave',latitude:18.4411,longitude:1.4078,isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Niger',countryCode:'NE',city:'Agadez',name:'Agadez',type:'Oasis',latitude:16.9739,longitude:7.9908,isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Niger',countryCode:'NE',city:'Bilma',name:'Bilma (Ténéré)',type:'Oasis',latitude:18.6853,longitude:12.9164,isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Kenya',countryCode:'KE',city:'Lodwar',name:'Lodwar (Turkana)',type:'Zone reculée / Enclave',latitude:3.1197,longitude:35.5973,isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Éthiopie',countryCode:'ET',city:'Omorate',name:'Omorate (Omo)',type:'Village / Campagne',latitude:4.8000,longitude:36.0500,isRemote:true),
    GlobalPlace(continent:'Afrique',country:'Madagascar',countryCode:'MG',city:'Maroantsetra',name:'Maroantsetra (Masoala)',type:'Zone reculée / Enclave',latitude:-15.4333,longitude:49.7333,isRemote:true),

    // =========================================================================
    // EUROPE (CAPITALES, COMMUNES RURALES, VILLAGES DE MONTAGNE & ARCTIQUE)
    // =========================================================================
    GlobalPlace(continent:'Europe',country:'France',countryCode:'FR',city:'Paris',name:'Paris',type:'Capitale',latitude:48.8566,longitude:2.3522),
    GlobalPlace(continent:'Europe',country:'France',countryCode:'FR',city:'Saint-Véran',name:'Saint-Véran (Queyras)',type:'Zone de montagne',latitude:44.7000,longitude:6.8667,isRemote:true),
    GlobalPlace(continent:'Europe',country:'France',countryCode:'FR',city:'Île-de-Sein',name:'Île de Sein',type:'Île isolée',latitude:48.0370,longitude:-4.8500,isRemote:true),
    GlobalPlace(continent:'Europe',country:'Suisse',countryCode:'CH',city:'Zermatt',name:'Zermatt (Valais)',type:'Zone de montagne',latitude:46.0207,longitude:7.7491),
    GlobalPlace(continent:'Europe',country:'Norvège',countryCode:'NO',city:'Longyearbyen',name:'Longyearbyen (Svalbard)',type:'Station de recherche / Isolé',latitude:78.2232,longitude:15.6267,isRemote:true),
    GlobalPlace(continent:'Europe',country:'Norvège',countryCode:'NO',city:'Reine',name:'Reine (Lofoten)',type:'Village / Campagne',latitude:67.9331,longitude:13.0886),
    GlobalPlace(continent:'Europe',country:'Géorgie',countryCode:'GE',city:'Ushguli',name:'Ushguli (Haut Caucase)',type:'Zone de montagne',latitude:42.9167,longitude:43.0167,isRemote:true),
    GlobalPlace(continent:'Europe',country:'Portugal',countryCode:'PT',city:'Corvo',name:'Vila do Corvo (Açores)',type:'Île isolée',latitude:39.6739,longitude:-31.1147,isRemote:true),
    GlobalPlace(continent:'Europe',country:'Royaume-Uni',countryCode:'GB',city:'Lerwick',name:'Lerwick (Shetland)',type:'Île isolée',latitude:60.1550,longitude:-1.1450),

    // =========================================================================
    // ASIE & MOYEN-ORIENT (VILLES, VILLAGES HIMALAYENS, OASES & SIBÉRIE)
    // =========================================================================
    GlobalPlace(continent:'Asie',country:'Japon',countryCode:'JP',city:'Tokyo',name:'Tokyo',type:'Capitale',latitude:35.6762,longitude:139.6503),
    GlobalPlace(continent:'Asie',country:'Japon',countryCode:'JP',city:'Aogashima',name:'Aogashima',type:'Île isolée',latitude:32.4572,longitude:139.7675,isRemote:true),
    GlobalPlace(continent:'Asie',country:'Inde',countryCode:'IN',city:'Leh',name:'Leh (Ladakh)',type:'Zone de montagne',latitude:34.1526,longitude:77.5771,isRemote:true),
    GlobalPlace(continent:'Asie',country:'Népal',countryCode:'NP',city:'Namche Bazaar',name:'Namche Bazaar (Everest)',type:'Zone de montagne',latitude:27.8069,longitude:86.7140,isRemote:true),
    GlobalPlace(continent:'Asie',country:'Chine',countryCode:'CN',city:'Lhassa',name:'Lhassa (Tibet)',type:'Zone de montagne',latitude:29.6525,longitude:91.1721),
    GlobalPlace(continent:'Asie',country:'Chine',countryCode:'CN',city:'Tashkurgan',name:'Tashkurgan (Pamir)',type:'Zone reculée / Enclave',latitude:37.7725,longitude:75.2289,isRemote:true),
    GlobalPlace(continent:'Asie',country:'Russie',countryCode:'RU',city:'Oïmiakon',name:'Oïmiakon (Pôle du froid)',type:'Station de recherche / Isolé',latitude:63.4641,longitude:142.7737,isRemote:true),
    GlobalPlace(continent:'Asie',country:'Mongolie',countryCode:'MN',city:'Tavan Bogd',name:'Tavan Bogd (Altai)',type:'Zone reculée / Enclave',latitude:49.1467,longitude:87.8208,isRemote:true),
    GlobalPlace(continent:'Asie',country:'Tadjikistan',countryCode:'TJ',city:'Murghab',name:'Murghab (Pamir)',type:'Zone reculée / Enclave',latitude:38.1706,longitude:73.9667,isRemote:true),
    GlobalPlace(continent:'Asie',country:'Yémen',countryCode:'YE',city:'Hadibu',name:'Socotra (Yémen)',type:'Île isolée',latitude:12.6500,longitude:54.0167,isRemote:true),

    // =========================================================================
    // AMÉRIQUE DU NORD, CENTRALE & CARAÏBES
    // =========================================================================
    GlobalPlace(continent:'Amérique du Nord',country:'États-Unis',countryCode:'US',city:'Utqiagvik',name:'Utqiaġvik / Barrow (Alaska)',type:'Station de recherche / Isolé',latitude:71.2906,longitude:-156.7886,isRemote:true),
    GlobalPlace(continent:'Amérique du Nord',country:'États-Unis',countryCode:'US',city:'Supai',name:'Supai (Grand Canyon)',type:'Zone reculée / Enclave',latitude:36.2369,longitude:-112.6892,isRemote:true),
    GlobalPlace(continent:'Amérique du Nord',country:'Canada',countryCode:'CA',city:'Iqaluit',name:'Iqaluit (Nunavut)',type:'Zone reculée / Enclave',latitude:63.7467,longitude:-68.5170,isRemote:true),
    GlobalPlace(continent:'Amérique du Nord',country:'Canada',countryCode:'CA',city:'Grise Fiord',name:'Grise Fiord (Haut-Arctique)',type:'Station de recherche / Isolé',latitude:76.4167,longitude:-82.8958,isRemote:true),
    GlobalPlace(continent:'Amérique du Nord',country:'Groenland',countryCode:'GL',city:'Ittoqqortoormiit',name:'Ittoqqortoormiit',type:'Station de recherche / Isolé',latitude:70.4833,longitude:-21.9667,isRemote:true),
    GlobalPlace(continent:'Amérique du Nord',country:'Honduras',countryCode:'HN',city:'Puerto Lempira',name:'Puerto Lempira (Mosquitia)',type:'Zone reculée / Enclave',latitude:15.2667,longitude:-83.7833,isRemote:true),

    // =========================================================================
    // AMÉRIQUE DU SUD (AMAZONIE, ANDES & PATAGONIE)
    // =========================================================================
    GlobalPlace(continent:'Amérique du Sud',country:'Brésil',countryCode:'BR',city:'Manaus',name:'Manaus (Amazonie)',type:'Ville',latitude:-3.1190,longitude:-60.0217),
    GlobalPlace(continent:'Amérique du Sud',country:'Brésil',countryCode:'BR',city:'Tefé',name:'Tefé (Cœur Amazonie)',type:'Zone reculée / Enclave',latitude:-3.3542,longitude:-64.7114,isRemote:true),
    GlobalPlace(continent:'Amérique du Sud',country:'Pérou',countryCode:'PE',city:'La Rinconada',name:'La Rinconada (5100m)',type:'Zone de montagne',latitude:-14.6322,longitude:-69.4461,isRemote:true),
    GlobalPlace(continent:'Amérique du Sud',country:'Chili',countryCode:'CL',city:'Puerto Williams',name:'Puerto Williams (Terre de Feu)',type:'Zone reculée / Enclave',latitude:-54.9333,longitude:-67.6167,isRemote:true),
    GlobalPlace(continent:'Amérique du Sud',country:'Chili',countryCode:'CL',city:'Caleta Tortel',name:'Caleta Tortel (Patagonie)',type:'Zone reculée / Enclave',latitude:-47.7961,longitude:-73.5350,isRemote:true),
    GlobalPlace(continent:'Amérique du Sud',country:'Colombie',countryCode:'CO',city:'Leticia',name:'Leticia (Amazonie)',type:'Zone reculée / Enclave',latitude:-4.2153,longitude:-69.9406,isRemote:true),

    // =========================================================================
    // OCÉANIE & PACIFIQUE (OUTBACK, ATOLLS & ÎLES ISOLÉES)
    // =========================================================================
    GlobalPlace(continent:'Océanie',country:'Australie',countryCode:'AU',city:'Kiwirrkurra',name:'Kiwirrkurra (Désert)',type:'Zone reculée / Enclave',latitude:-22.8220,longitude:127.7610,isRemote:true),
    GlobalPlace(continent:'Océanie',country:'Australie',countryCode:'AU',city:'Coober Pedy',name:'Coober Pedy',type:'Oasis',latitude:-29.0136,longitude:134.7544),
    GlobalPlace(continent:'Océanie',country:'Royaume-Uni',countryCode:'PN',city:'Adamstown',name:'Adamstown (Îles Pitcairn)',type:'Île isolée',latitude:-25.0667,longitude:-130.1000,isRemote:true),
    GlobalPlace(continent:'Océanie',country:'Kiribati',countryCode:'KI',city:'Kiritimati',name:'Kiritimati (Christmas Island)',type:'Île isolée',latitude:1.8711,longitude:-157.3631,isRemote:true),

    // =========================================================================
    // ANTARCTIQUE & ZONES LES PLUS INACCESSIBLES DU GLOBE
    // =========================================================================
    GlobalPlace(continent:'Antarctique',country:'Antarctique',countryCode:'AQ',city:'Base Esperanza',name:'Base Esperanza',type:'Station de recherche / Isolé',latitude:-63.3981,longitude:-57.0026,isRemote:true),
    GlobalPlace(continent:'Antarctique',country:'Antarctique',countryCode:'AQ',city:'McMurdo',name:'Station McMurdo',type:'Station de recherche / Isolé',latitude:-77.8460,longitude:166.6760,isRemote:true),
    GlobalPlace(continent:'Antarctique',country:'Antarctique',countryCode:'AQ',city:'Pôle Sud',name:'Amundsen-Scott (Pôle Sud)',type:'Station de recherche / Isolé',latitude:-90.0000,longitude:0.0000,isRemote:true),
    GlobalPlace(continent:'Antarctique',country:'Tristan da Cunha',countryCode:'TA',city:'Seven Seas',name:'Edinburgh of the Seven Seas',type:'Île isolée',latitude:-37.0678,longitude:-12.3113,isRemote:true),
    GlobalPlace(continent:'Antarctique',country:'France',countryCode:'TF',city:'Kerguelen',name:'Port-aux-Français (Kerguelen)',type:'Station de recherche / Isolé',latitude:-49.3500,longitude:70.2167,isRemote:true),
  ];

  static List<String> get continents => places.map((p) => p.continent).toSet().toList();

  static List<String> countries(String continent) =>
      places.where((p) => p.continent == continent).map((p) => p.country).toSet().toList();

  static List<String> get types =>
      places.map((p) => p.type).toSet().toList();

  static List<GlobalPlace> filter({
    String? continent,
    String? country,
    String? type,
    String query = '',
    bool remoteOnly = false,
  }) {
    final q = query.trim().toLowerCase();
    final parsedGps = parseGpsQuery(query);
    final results = <GlobalPlace>[];

    if (parsedGps != null) {
      results.add(parsedGps);
    }

    final matched = places.where((p) {
      final okContinent = continent == null || p.continent == continent;
      final okCountry = country == null || p.country == country;
      final okType = type == null || p.type == type;
      final okRemote = !remoteOnly || p.isRemote;
      final text = '${p.name} ${p.city} ${p.country} ${p.continent} ${p.region ?? ''} ${p.type}'.toLowerCase();
      return okContinent && okCountry && okType && okRemote && (q.isEmpty || text.contains(q));
    }).toList();

    results.addAll(matched);
    return results;
  }

  /// Détecte si la saisie correspond à des coordonnées GPS (ex: "3.8480, 11.5021" ou "-63.398 -57.002")
  static GlobalPlace? parseGpsQuery(String query) {
    final clean = query.trim().replaceAll(';', ',').replaceAll(':', ' ');
    final parts = clean.split(RegExp(r'[\s,]+')).where((s) => s.isNotEmpty).toList();
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0]);
      final lon = double.tryParse(parts[1]);
      if (lat != null && lon != null && lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180) {
        return GlobalPlace(
          continent: 'Position GPS',
          country: 'Coordonnées saisies',
          countryCode: 'GPS',
          city: '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}',
          name: 'Point GPS (${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)})',
          type: 'Coordonnées GPS / Point terrain',
          latitude: lat,
          longitude: lon,
          isRemote: true,
        );
      }
    }
    return null;
  }

  /// Recherche mondiale en direct via OpenStreetMap Nominatim
  static Future<List<GlobalPlace>> searchNominatim(String query, {http.Client? client}) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final httpClient = client ?? http.Client();
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(q)}&format=json&limit=30&addressdetails=1',
      );
      final response = await httpClient.get(
        uri,
        headers: {'User-Agent': 'CamRouteIA/1.6 (contact@camroute.ia)'},
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) {
          final lat = double.tryParse(item['lat'].toString()) ?? 0.0;
          final lon = double.tryParse(item['lon'].toString()) ?? 0.0;
          final displayName = item['display_name'] as String? ?? q;
          final address = item['address'] as Map<String, dynamic>? ?? {};

          final city = address['village'] ??
              address['town'] ??
              address['city'] ??
              address['hamlet'] ??
              address['suburb'] ??
              address['county'] ??
              q;
          final country = address['country'] ?? 'Monde';
          final countryCode = (address['country_code'] as String? ?? 'INT').toUpperCase();
          final state = address['state'] ?? address['region'] ?? '';
          final osmType = item['type'] ?? item['class'] ?? 'Lieu';

          final isVillage = osmType == 'village' || osmType == 'hamlet' || osmType == 'isolated_dwelling';

          return GlobalPlace(
            continent: 'Recherche OSM (Nominatim)',
            country: country,
            countryCode: countryCode,
            city: '$city',
            name: displayName,
            type: isVillage ? 'Village / Campagne' : 'Ville / Localité ($osmType)',
            latitude: lat,
            longitude: lon,
            region: state,
            isRemote: isVillage,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Recherche mondiale en direct via Komoot Photon (OpenStreetMap geocoder extrêmement rapide et couvrant le monde rural)
  static Future<List<GlobalPlace>> searchPhoton(String query, {http.Client? client}) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final httpClient = client ?? http.Client();
    try {
      final uri = Uri.parse('https://photon.komoot.io/api/?q=${Uri.encodeComponent(q)}&limit=30');
      final response = await httpClient.get(
        uri,
        headers: {'User-Agent': 'CamRouteIA/1.6 (contact@camroute.ia)'},
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final features = (data['features'] as List?) ?? [];
        return features.map((f) {
          final geom = f['geometry'] as Map<String, dynamic>? ?? {};
          final coords = (geom['coordinates'] as List?) ?? [0.0, 0.0];
          final lon = (coords[0] as num).toDouble();
          final lat = (coords[1] as num).toDouble();

          final props = f['properties'] as Map<String, dynamic>? ?? {};
          final name = props['name'] as String? ?? q;
          final city = props['city'] ?? props['town'] ?? props['village'] ?? props['hamlet'] ?? name;
          final country = props['country'] as String? ?? 'Monde';
          final countryCode = (props['countrycode'] as String? ?? 'INT').toUpperCase();
          final state = props['state'] as String? ?? '';
          final type = props['type'] as String? ?? 'lieu';

          final isRural = type == 'village' || type == 'hamlet' || type == 'locality';

          return GlobalPlace(
            continent: 'Recherche mondiale (Photon)',
            country: country,
            countryCode: countryCode,
            city: '$city',
            name: '$name, $country',
            type: isRural ? 'Village / Campagne' : 'Localité ($type)',
            latitude: lat,
            longitude: lon,
            region: state,
            isRemote: isRural,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Recherche globale unifiée (Local + GPS + Nominatim + Photon)
  static Future<List<GlobalPlace>> searchGlobal(String query, {
    String? continent,
    String? country,
    String? type,
    bool remoteOnly = false,
  }) async {
    final q = query.trim();
    final local = filter(
      continent: continent,
      country: country,
      type: type,
      query: q,
      remoteOnly: remoteOnly,
    );

    if (q.length < 2) return local;

    final results = <GlobalPlace>[...local];

    final remoteResults = await Future.wait([
      searchNominatim(q),
      searchPhoton(q),
    ]);

    for (final list in remoteResults) {
      for (final r in list) {
        final exists = results.any((c) =>
            (c.latitude - r.latitude).abs() < 0.001 &&
            (c.longitude - r.longitude).abs() < 0.001);
        if (!exists) {
          results.add(r);
        }
      }
    }

    return results;
  }
}
