import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:niion/Globals.dart';
import 'package:niion/pojo/RidePojo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RidesDatabase {
  static final RidesDatabase instance = RidesDatabase._init();
  static Database? _database;

  RidesDatabase._init();

  Future<Database?> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rides.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = ' INTEGER PRIMARY KEY AUTOINCREMENT';
    const numberType = ' INTEGER NOT NULL';
    const doubleType = ' FLOAT NOT NULL';
    const textType = ' TEXT NOT NULL';
    const textTypeNull = ' TEXT NULL';

    await db.execute('''
    CREATE TABLE $tableRides(
    ${RideFields.id} $idType, 
    ${RideFields.duration} $numberType, 
    ${RideFields.distance} $doubleType, 
    ${RideFields.avgSpeed} $doubleType, 
    ${RideFields.carbonSavings} $doubleType, 
    ${RideFields.polylines} $textTypeNull, 
    ${RideFields.createdTime} $numberType 
    )
    ''');

    await db.execute('''
    CREATE TABLE $tablePolylines(
    ${RideFields.ride_id} $numberType, 
    ${RideFields.ride_lat} $doubleType, 
    ${RideFields.ride_lon} $doubleType 
    )
    ''');
  }

  Future<int?> createRide(RidePojo ridePojo) async {
    final db = await instance.database;
    final id = await db?.insert(tableRides, ridePojo.toJson());
    Batch batch = db!.batch();
    for (var element in ridePojo.polylines) {
      batch.insert(tablePolylines, {
        RideFields.ride_id: id,
        RideFields.ride_lat: element.latitude,
        RideFields.ride_lon: element.longitude
      });
    }
    await batch.commit(noResult: true);
    return id;
  }

  Future<RidePojo> getRide(int id) async {
    final db = await instance.database;
    final rides = await db?.query(tableRides,
        columns: RideFields.tbRideColumns,
        where: '${RideFields.id}=?',
        whereArgs: [id]);

    final polylines = await db?.query(tablePolylines,
        columns: RideFields.tbPolylineColumns,
        where: '${RideFields.ride_id}=?',
        whereArgs: [id]);

    if (rides!.isNotEmpty) {
      return RidePojo.fromJson(rides.first, polylines!);
    } else {
      throw Exception('ID:$id not found');
    }
  }

  Future<List<RidePojo>> getAllRides() async {
    final db = await instance.database;
    const orderBy = '${RideFields.createdTime} DESC';
    final result = await db!.query(tableRides, orderBy: orderBy);
    return result.map((json) => RidePojo.fromJson(json, null)).toList();
  }

  Future<double> getTotalCarbonSavings() async {
    final db = await instance.database;
    final result = await db!.rawQuery("SELECT SUM(${RideFields.carbonSavings}) FROM $tableRides");
    return result[0]["SUM(${RideFields.carbonSavings})"] as double;
  }

  Future<int> updateRide(RidePojo ridePojo) async {
    final db = await instance.database;
    return db!.update(tableRides, ridePojo.toJson(),
        where: '${RideFields.id} = ?', whereArgs: [ridePojo.id]);
  }

  Future<int> deleteRide(RidePojo ridePojo) async {
    final db = await instance.database;
    return db!.delete(tableRides,
        where: '${RideFields.id} = ?', whereArgs: [ridePojo.id]);
  }

  Future close() async {
    final db = await instance.database;
    db?.close();
  }
}
