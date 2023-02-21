import 'package:google_maps_flutter/google_maps_flutter.dart';

const String tableRides = 'rides';
const String tablePolylines = 'polylines';

class RideFields {
  static const String id = '_id';
  static const String duration = 'duration';
  static const String distance = 'distance';
  static const String avgSpeed = 'avgSpeed';
  static const String carbonSavings = 'carbonSavings';
  static const String polylines = 'polylines';
  static const String createdTime = 'createdTime';
  static const String address = 'address';

  static const String ride_id = 'ride_id';
  static const String ride_lat = 'ride_lat';
  static const String ride_lon = 'ride_lon';

  static final List<String> tbRideColumns = [
    id,
    duration,
    distance,
    avgSpeed,
    carbonSavings,
    polylines,
    createdTime,address
  ];

  static final List<String> tbPolylineColumns = [
    ride_id,
    ride_lat,
    ride_lon,
  ];
}

class RidePojo {
  final int? id, duration, createdTime;
  final double distance, avgSpeed, carbonSavings;
  final List<LatLng> polylines;
  final String address ;

  const RidePojo({
    this.id,
    required this.duration,
    required this.distance,
    required this.avgSpeed,
    required this.carbonSavings,
    required this.polylines,
    required this.createdTime,
    required this.address,
  });

  RidePojo copy(
          {int? id,
          required int duration,
          required double distance,
          required double avgSpeed,
          required double carbonSavings,
          required List<LatLng> polylines,
          required int createdTime ,required String address}) =>
      RidePojo(
        id: id ?? this.id,
        duration: duration,
        distance: distance,
        avgSpeed: avgSpeed,
        carbonSavings: carbonSavings,
        polylines: polylines,
        createdTime: createdTime,
        address: address,
      );

  static RidePojo fromJson(
      Map<String, Object?> jsonRide, List<Map<String, Object?>>? jsonPolyline) {
    List<LatLng> polylines = [];
    if (jsonPolyline != null) {
      for (var element in jsonPolyline) {
        polylines.add(LatLng(element[RideFields.ride_lat] as double,
            element[RideFields.ride_lon] as double));
      }
    }
    return RidePojo(
        id: jsonRide[RideFields.id] as int?,
        duration: jsonRide[RideFields.duration] as int,
        distance: jsonRide[RideFields.distance] as double,
        avgSpeed: jsonRide[RideFields.avgSpeed] as double,
        carbonSavings: jsonRide[RideFields.carbonSavings] as double,
        polylines: polylines,
        createdTime: jsonRide[RideFields.createdTime] as int,
        address: jsonRide[RideFields.address] as String);
  }

  Map<String, Object?> toJson() => {
        RideFields.id: id,
        RideFields.duration: duration,
        RideFields.distance: distance,
        RideFields.avgSpeed: avgSpeed,
        RideFields.carbonSavings: carbonSavings,
        RideFields.createdTime: createdTime,
        RideFields.address: address,
      };
}
