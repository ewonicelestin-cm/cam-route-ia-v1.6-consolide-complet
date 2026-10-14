import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/app_data.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();
  factory DatabaseService() => instance;

  Database? _db;

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    if (kIsWeb) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      return openDatabase(inMemoryDatabasePath,
          version: 4, onCreate: _create, onUpgrade: _upgrade);
    }
    return openDatabase(
      join(await getDatabasesPath(), 'cam_route_ia.db'),
      version: 4,
      onCreate: _create,
      onUpgrade: _upgrade,
    );
  }

  Future<void> _create(Database db, int v) async {
    await db.execute(
        'CREATE TABLE locations (id INTEGER PRIMARY KEY AUTOINCREMENT,latitude REAL NOT NULL,longitude REAL NOT NULL,altitude REAL,accuracy REAL,speed REAL,heading REAL,timestamp TEXT NOT NULL)');
    await db.execute(
        'CREATE TABLE road_observations (id INTEGER PRIMARY KEY AUTOINCREMENT,latitude REAL NOT NULL,longitude REAL NOT NULL,road_type TEXT,condition TEXT,description TEXT,timestamp TEXT NOT NULL)');
    await db.execute(
        'CREATE TABLE network_measurements (id INTEGER PRIMARY KEY AUTOINCREMENT,latitude REAL NOT NULL,longitude REAL NOT NULL,operator TEXT,technology TEXT,signal_strength REAL,quality REAL,timestamp TEXT NOT NULL)');
    await _routes(db);
    await _infra(db);
    await _incidents(db);
  }

  Future<void> _upgrade(Database db, int old, int n) async {
    if (old < 2) await _routes(db);
    if (old < 3) await _infra(db);
    if (old < 4) await _incidents(db);
  }

  Future<void> _routes(Database db) async => db.execute(
      'CREATE TABLE routes (id INTEGER PRIMARY KEY AUTOINCREMENT,start_latitude REAL NOT NULL,start_longitude REAL NOT NULL,destination_latitude REAL NOT NULL,destination_longitude REAL NOT NULL,distance_meters REAL NOT NULL,duration_seconds REAL NOT NULL,created_at TEXT NOT NULL)');

  Future<void> _infra(Database db) async => db.execute(
      'CREATE TABLE infrastructures (id INTEGER PRIMARY KEY AUTOINCREMENT,latitude REAL NOT NULL,longitude REAL NOT NULL,type TEXT NOT NULL,name TEXT,description TEXT,timestamp TEXT NOT NULL)');

  Future<void> _incidents(Database db) async => db.execute(
      'CREATE TABLE incidents (id INTEGER PRIMARY KEY AUTOINCREMENT,latitude REAL NOT NULL,longitude REAL NOT NULL,type TEXT NOT NULL,description TEXT,timestamp TEXT NOT NULL)');

  Future<int> insertLocation(LocationRecord x) async =>
      (await database).insert('locations', {
        'latitude': x.latitude,
        'longitude': x.longitude,
        'altitude': x.altitude,
        'accuracy': x.accuracy,
        'speed': x.speed,
        'heading': x.heading,
        'timestamp': x.timestamp.toIso8601String()
      });

  Future<int> getLocationCount() async =>
      Sqflite.firstIntValue(
          await (await database).rawQuery('SELECT COUNT(*) FROM locations')) ??
      0;

  Future<int> insertRoadObservation(RoadObservation x) async =>
      (await database).insert('road_observations', {
        'latitude': x.latitude,
        'longitude': x.longitude,
        'road_type': x.roadType,
        'condition': x.condition,
        'description': x.description,
        'timestamp': x.timestamp.toIso8601String()
      });

  Future<List<RoadObservation>> getRoadObservations() async =>
      (await (await database)
              .query('road_observations', orderBy: 'timestamp DESC'))
          .map(RoadObservation.fromMap)
          .toList();

  Future<int> getRoadObservationCount() async =>
      Sqflite.firstIntValue(await (await database)
          .rawQuery('SELECT COUNT(*) FROM road_observations')) ??
      0;

  Future<int> insertNetworkMeasurement(NetworkMeasurement x) async =>
      (await database).insert('network_measurements', {
        'latitude': x.latitude,
        'longitude': x.longitude,
        'operator': x.operator,
        'technology': x.technology,
        'signal_strength': x.signalStrength,
        'quality': x.quality,
        'timestamp': x.timestamp.toIso8601String()
      });

  Future<List<NetworkMeasurement>> getNetworkMeasurements() async =>
      (await (await database)
              .query('network_measurements', orderBy: 'timestamp DESC'))
          .map(NetworkMeasurement.fromMap)
          .toList();

  Future<int> getNetworkMeasurementCount() async =>
      Sqflite.firstIntValue(await (await database)
          .rawQuery('SELECT COUNT(*) FROM network_measurements')) ??
      0;

  Future<int> insertInfrastructure(InfrastructurePoint x) async =>
      (await database).insert('infrastructures', {
        'latitude': x.latitude,
        'longitude': x.longitude,
        'type': x.type,
        'name': x.name,
        'description': x.description,
        'timestamp': x.timestamp.toIso8601String()
      });

  Future<List<InfrastructurePoint>> getInfrastructures() async =>
      (await (await database)
              .query('infrastructures', orderBy: 'timestamp DESC'))
          .map(InfrastructurePoint.fromMap)
          .toList();

  Future<int> getInfrastructureCount() async =>
      Sqflite.firstIntValue(await (await database)
          .rawQuery('SELECT COUNT(*) FROM infrastructures')) ??
      0;

  Future<int> insertIncident(CommunityIncident x) async =>
      (await database).insert('incidents', {
        'latitude': x.latitude,
        'longitude': x.longitude,
        'type': x.type,
        'description': x.description,
        'timestamp': x.timestamp.toIso8601String()
      });

  Future<List<CommunityIncident>> getIncidents() async =>
      (await (await database).query('incidents', orderBy: 'timestamp DESC'))
          .map(CommunityIncident.fromMap)
          .toList();

  Future<int> getIncidentCount() async =>
      Sqflite.firstIntValue(
          await (await database).rawQuery('SELECT COUNT(*) FROM incidents')) ??
      0;

  Future<int> insertRoute(
          {required double startLatitude,
          required double startLongitude,
          required double destinationLatitude,
          required double destinationLongitude,
          required double distanceMeters,
          required double durationSeconds,
          required DateTime createdAt}) async =>
      (await database).insert('routes', {
        'start_latitude': startLatitude,
        'start_longitude': startLongitude,
        'destination_latitude': destinationLatitude,
        'destination_longitude': destinationLongitude,
        'distance_meters': distanceMeters,
        'duration_seconds': durationSeconds,
        'created_at': createdAt.toIso8601String()
      });

  Future<List<Map<String, dynamic>>> getRoutes() async =>
      (await database).query('routes', orderBy: 'created_at DESC');

  Future<int> getRouteCount() async =>
      Sqflite.firstIntValue(
          await (await database).rawQuery('SELECT COUNT(*) FROM routes')) ??
      0;

  Future<int> deleteRoute(int id) async =>
      (await database).delete('routes', where: 'id=?', whereArgs: [id]);

  Future<void> deleteAllRoutes() async {
    await (await database).delete('routes');
  }
}
