import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:niion/AlertIntface.dart';
import 'package:niion/Constants.dart';

import 'Globals.dart';
import 'NotificationApi.dart';
import 'pojo/RidePojo.dart';
import 'RidesDatabase.dart';

class MapRoute extends StatefulWidget {
  const MapRoute({super.key, required this.pos});

  final LatLng pos;

  @override
  State<MapRoute> createState() => MapRouteState();
}

class MapRouteState extends State<MapRoute> {
  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  List<double> currentSpeeds = [];
  double currentSpeed = 0.0, avgSpeed = 0.0, totalDistance = 0;
  LatLng? currentLocation, sourceLocation;
  int duration = 0;
  bool isStarted = false;
  StreamSubscription<LocationData>? locationSubscription;

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
    NotificationApi.init();
    showAlertIfBatteryLess();
  }

  @override
  void dispose() {
    _timer.cancel();
    locationSubscription?.cancel();
    super.dispose();
  }

  late Timer _timer;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          duration++;
        });
      },
    );
  }

  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = LatLng(location.latitude!, location.longitude!);
        addPolyPoints(currentLocation!);
      },
    );
    GoogleMapController googleMapController = await _controller.future;
    locationSubscription = location.onLocationChanged.listen((newLoc) {
      currentLocation = LatLng(newLoc.latitude!, newLoc.longitude!);
      if (isStarted) {
        currentSpeed = (newLoc.speed)! * 1.609;
        currentSpeeds.add(currentSpeed);
        double tempSpeed = 0.0;
        for (var element in currentSpeeds) {
          tempSpeed += element;
        }
        avgSpeed = tempSpeed / currentSpeeds.length;
        print("sdfcdsfvdgv $avgSpeed");
      }
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
    });
  }

  void addPolyPoints(LatLng latlon2) async {
    // Polyline has some element(s)
    if (polylineCoordinates.isEmpty) {
      sourceLocation = latlon2;
    } else {
      // Polyline has 1 or more elements
      double currentDistance =
          calculateDistance(getLastPolyLine(polylineCoordinates), latlon2);
      if (currentDistance > initialLocVariation &&
          polylineCoordinates.length == 1) {
        print("Distz = ifcond $currentDistance");
        polylineCoordinates.clear();
        sourceLocation = latlon2;
      } else {
        currentLocation = latlon2;
      }
      print("Distz = else cond $currentDistance");
      if (isStarted) {
        totalDistance += currentDistance;
        consumeBattery(currentDistance);
      }
      print("Distz = ${totalDistance.toStringAsFixed(2)}");
    }
    polylineCoordinates.add(latlon2);
    setState(() {});
  }

  LatLng getLastPolyLine(polyLineCoords) {
    if (polylineCoordinates.isNotEmpty) {
      return polylineCoordinates[polylineCoordinates.length - 1];
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
  Widget build(BuildContext context) {
    // currentLocation = widget.pos;
    // addPolyPoints(currentLocation!);
    var map = GoogleMap(
      initialCameraPosition: CameraPosition(
        target: currentLocation!,
        zoom: 21,
      ),
      markers: {
        Marker(
          markerId: const MarkerId("sourceLocation"),
          position: sourceLocation!,
        ),
        Marker(
            markerId: const MarkerId("currentLocation"),
            position: currentLocation!),
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

    var a1 = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      title: const Text('Are you sure you want to end your ride?'),
      actions: [
        TextButton(
            onPressed: () async {
              await RidesDatabase.instance.createRide(RidePojo(
                  duration: duration,
                  distance: totalDistance,
                  avgSpeed: avgSpeed,
                  carbonSavings: carbonSavings(totalDistance),
                  polylines: polylineCoordinates,
                  createdTime: getTS()));
              setState(() {
                Navigator.pop(context);
                closeScreen(context);
              });
            },
            child: const Text("Yes")),
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text("No")),
      ],
    );

    var b1 = Material(
        type: MaterialType.transparency,
        child: Column(children: [
          Expanded(
            flex: 9,
            child: map,
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue,
              child: Container(
                  margin: const EdgeInsets.all(10.0),
                  child: Stack(
                    children: [
                      if (!isStarted)
                        Center(
                          // margin: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isStarted = true;
                                  startTimer();
                                  LatLng latLng =
                                      getLastPolyLine(polylineCoordinates);
                                  polylineCoordinates.clear();
                                  polylineCoordinates.add(latLng);
                                });
                              },
                              child: const Text('Start Ride')),
                        ),
                      if (isStarted)
                        Align(
                          alignment: Alignment.topLeft,
                          // margin: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Text(
                            'Current Speed: ${shrinkDecimal(currentSpeed, 2)} Km/Hr',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      if (isStarted)
                        Align(
                          alignment: Alignment.topRight,
                          // margin: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Text(
                            'Avg Speed: ${shrinkDecimal(avgSpeed, 2)} Km/Hr',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      if (isStarted)
                        Align(
                          alignment: Alignment.bottomLeft,
                          // margin: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Text(
                            'Dur: ${getTimeFromSeconds(duration)}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                        ),
                      if (isStarted)
                        Align(
                          alignment: Alignment.bottomRight,
                          // margin: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Text(
                            'Dist.: ${shrinkDecimal(totalDistance, 2)} Km',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                        ),
                      if (isStarted)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (_) {
                                      return a1;
                                    });
                              },
                              child: const Text('Stop Ride')),
                        )
                      // Center(
                      //     child: Text(
                      //   'Temperature: C',
                      //       textAlign: TextAlign.right,
                      //   style: TextStyle(color: Colors.white, fontSize: 20),
                      // )),
                    ],
                  )),
            ),
          ),
        ]));
    return WillPopScope(
        onWillPop: () async {
          showDialog(
              context: context,
              builder: (_) {
                return a1;
              });
          // var n1 = AlertIntface();
          // showAlertIntFace(context, true, "", "", n1():{
          //
          // });
          return false;
        },
        child: b1);
  }
}
