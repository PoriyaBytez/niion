import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:niion/utils/Constants.dart';
import 'package:niion/utils/Globals.dart';

class MapRoute extends StatefulWidget {
  const MapRoute({super.key, required this.pos});

  final LatLng pos;

  @override
  State<MapRoute> createState() => MapRouteState();
}

class MapRouteState extends State<MapRoute> {
  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  LatLng? currentLocation;
  double totalDistance = 0;

  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = LatLng(location.latitude!, location.longitude!);
        addPolyPoints(currentLocation!);
      },
    );
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = LatLng(newLoc.latitude!, newLoc.longitude!);
        addPolyPoints(currentLocation!);
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 21,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
        setState(() {});
      },
    );
  }

  void addPolyPoints(LatLng latlon2) async {
    // Polyline has some element(s)
    if (polylineCoordinates.isNotEmpty) {
      // Polyline has 1 or more elements
      double currentDistance =
          calculateDistance(getLastPolyLine(polylineCoordinates), latlon2);
      if (currentDistance > initialLocVariation) {
        polylineCoordinates.clear();
      } else {
        totalDistance += currentDistance;
        consumeBattery(currentDistance);
        print("Distz = ${totalDistance.toStringAsFixed(2)}");
      }
    }
    polylineCoordinates.add(
      LatLng(latlon2.latitude, latlon2.longitude),
    );
    setState(() {});
  }

  LatLng getLastPolyLine(polyLineCoords) {
    if (polylineCoordinates.isNotEmpty) {
      LatLng latLngLast = polylineCoordinates[polylineCoordinates.length - 1];
      return LatLng(latLngLast.latitude, latLngLast.longitude);
    } else {
      return const LatLng(0, 0);
    }
  }

  double calculateDistance(LatLng latLon1, LatLng latLon2) {
    double lat1 = latLon1.latitude;
    double lon1 = latLon1.longitude;
    double lat2 = latLon2.latitude;
    double lon2 = latLon2.longitude;
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    currentLocation = widget.pos;
    addPolyPoints(currentLocation!);
    var map = GoogleMap(
      initialCameraPosition: CameraPosition(
        target:
            LatLng(currentLocation!.latitude, currentLocation!.longitude),
        zoom: 21,
      ),
      markers: {
        Marker(
          markerId: const MarkerId("currentLocation"),
          position:
              // currentLocation == null ? sourceLocation :
              LatLng(currentLocation!.latitude, currentLocation!.longitude),
        ),
      },
      onMapCreated: (mapController) {
        _controller.complete(mapController);
      },
      polylines: {
        Polyline(
          polylineId: const PolylineId("route"),
          points: polylineCoordinates,
          color: const Color(0xFF7B61FF),
          width: 6,
        ),
      },
    );
    return Scaffold(
      body:
          // currentLocation == null ? const Center(child: Text("Loading")) :
          map,
    );
  }
}
