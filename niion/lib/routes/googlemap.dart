import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../pojo/LatLon.dart';

class MapRoute extends StatefulWidget {
  const MapRoute({super.key, required this.pos});

  final LatLon pos;

  @override
  State<MapRoute> createState() => MapRouteState();
}

class MapRouteState extends State<MapRoute> {
  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  LatLon? currentLocation;

  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = LatLon(location.latitude, location.longitude);
        addPolyPoints(currentLocation!);
      },
    );
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = LatLon(newLoc.latitude, newLoc.longitude);
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

  void addPolyPoints(LatLon latlon) async {
    polylineCoordinates.add(
      LatLng(latlon.lat!, latlon.lon!),
    );
    setState(() {});
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // currentLocation = widget.pos;
    var map = GoogleMap(
      initialCameraPosition: CameraPosition(
        target:
            // sourceLocation,
            LatLng(currentLocation!.lat!, currentLocation!.lon!),
        zoom: 21,
      ),
      markers: {
        // const Marker(
        //   markerId: MarkerId("source"),
        //   position: sourceLocation,
        // ),
        Marker(
          markerId: const MarkerId("currentLocation"),
          position:
              // currentLocation == null ? sourceLocation :
              LatLng(currentLocation!.lat!, currentLocation!.lon!),
        ),
        // const Marker(
        //   markerId: MarkerId("destination"),
        //   position: destination,
        // ),
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
