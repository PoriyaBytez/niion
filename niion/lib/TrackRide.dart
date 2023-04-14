import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:niion/AlertIntface.dart';
import 'package:niion/Constants.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Globals.dart';
import 'NotificationApi.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_widgets.dart';
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
  late LatLng currentLocation = widget.pos, sourceLocation = widget.pos;
  int duration = 0;
  bool isStarted = false;
  StreamSubscription<LocationData>? locationSubscription;

  @override
  void initState() {
    getCurrentLocation();
    NotificationApi.init();
    showAlertIfBatteryLess();

    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    locationSubscription?.cancel();
    super.dispose();
  }

  getAddress() async {
    geo.Position position = await _getGeoLocationPosition();
    await GetAddressFromLatLong(position);
  }

  Future<geo.Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    geo.LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await geo.Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == geo.LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high);
  }

  String street = "";

  // Chintan
  Future<void> GetAddressFromLatLong(geo.Position position) async {
    List<geocoding.Placemark> placemarks = await geocoding
        .placemarkFromCoordinates(position.latitude, position.longitude);
    // print(placemarks);
    geocoding.Placemark place = placemarks[0];
    print(
        "adress '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}'");
    street = place.subLocality!;
    setState(() {});
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

  // Future<bool> enableBackgroundMode() async {
  //   // await Permission.locationAlways.request();
  //   // if (  await Permission.locationAlways.isGranted ) {
  //   //   // Either the permission was already granted before or the user just granted it.
  //   // }
  //
  //   Location location = Location();
  //   location.enableBackgroundMode(enable: true);
  //   // bool _bgModeEnabled = await location.isBackgroundModeEnabled();
  //   // if (_bgModeEnabled) {
  //   //   return true;
  //   // } else {
  //   //   try {
  //   //     await location.enableBackgroundMode();
  //   //   } catch (e) {
  //   //     debugPrint(e.toString());
  //   //   }
  //   //   try {
  //   //     _bgModeEnabled = await location.enableBackgroundMode();
  //   //   } catch (e) {
  //   //     debugPrint(e.toString());
  //   //   }
  //   //   print(" bbbbbb ${_bgModeEnabled}"); //True!
  //   //   return _bgModeEnabled;
  //   // }
  // }

  void getCurrentLocation() async {
    weatherDialog = await getLocal(weatherDialogKEY);
    var status = await Permission.locationAlways.request();
    if (status.isGranted) {
      // You can access the user's location in the background now
    }
    Location location = Location();
    location.enableBackgroundMode(enable: true);
    location.getLocation().then(
      (location) {
        currentLocation = LatLng(location.latitude!, location.longitude!);
        if (isStarted) {
          addPolyPoints(currentLocation);
        }
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
      }

      if (isStarted) {
        addPolyPoints(currentLocation);
      }
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 20,
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
        consumeBattery(currentDistance, context);
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

  int startDateTime = 0;
  bool isDiaload = false;
  String weatherDialog = "";
  @override
  Widget build(BuildContext context) {
    print("----============build================");
    // currentLocation = widget.pos;
    // addPolyPoints(currentLocation);
    var map = GoogleMap(
      buildingsEnabled: false,
      initialCameraPosition: CameraPosition(
        target: currentLocation,
        zoom: 20,
      ),
      markers: {
        (isStarted)
            ? Marker(
                markerId: const MarkerId("sourceLocation"),
                position: sourceLocation,
              )
            : Marker(
                markerId: const MarkerId("sourceLocation"),
                position: currentLocation,
              ),
        Marker(
            markerId: const MarkerId("currentLocation"),
            position: currentLocation),
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
                  // duration: duration,
                  duration: getTS(),
                  distance: totalDistance,
                  avgSpeed: avgSpeed,
                  carbonSavings: carbonSavings(totalDistance),
                  polylines: polylineCoordinates,
                  address: street,
                  createdTime: startDateTime));
              setState(() {
                Navigator.pop(context);
                Navigator.pop(context, 1);
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
            flex: 8,
            child: map,
          ),
          Expanded(
              flex: 5,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${getTimeFromSeconds(duration)}',
                                  style: FlutterFlowTheme.of(context)
                                      .title1
                                      .override(
                                        fontFamily: 'Lexend Deca',
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                Icon(
                                  Icons.watch_later_outlined,
                                  size: 40,
                                  color: Colors.black,
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${shrinkDecimal(totalDistance, 2)} km',
                                  style: FlutterFlowTheme.of(context)
                                      .title1
                                      .override(
                                        fontFamily: 'Lexend Deca',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                Icon(
                                  Icons.directions_bike_rounded,
                                  size: 40,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${double.parse(shrinkDecimal(currentSpeed, 2)) < 0.0 ? 0.00 : shrinkDecimal(currentSpeed, 2)} km/h',
                                  style: FlutterFlowTheme.of(context)
                                      .title1
                                      .override(
                                        fontFamily: 'Lexend Deca',
                                        color: Color(0x8D622206),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                Icon(
                                  Icons.speed,
                                  size: 40,
                                  color: Colors.black,
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${double.parse(shrinkDecimal(avgSpeed, 2)) < 0.0 ? 0.00 : shrinkDecimal(avgSpeed, 2)} km/h',
                                  // '${shrinkDecimal(avgSpeed, 2)} km/h',
                                  style: FlutterFlowTheme.of(context)
                                      .title1
                                      .override(
                                        fontFamily: 'Lexend Deca',
                                        color: Color(0x8DEE8B60),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                Icon(
                                  Icons.shutter_speed,
                                  size: 40,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ],
                        ),
                        if (!isStarted)
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 20, 0, 10),
                            child: FFButtonWidget(
                              onPressed: () {
                                setState(() {
                                  if (weatherDialog == "") {
                                    setState(() {
                                      isDiaload = true;
                                    });
                                  } else {
                                    setState(() {
                                      isStarted = true;
                                      startTimer();
                                      // LatLng latLng =
                                      //     getLastPolyLine(polylineCoordinates);
                                      // polylineCoordinates.clear();
                                      // polylineCoordinates.add(latLng);
                                      startDateTime = getTS();
                                      getAddress();
                                    });
                                  }
                                });
                              },
                              text: 'START RIDE',
                              icon: Icon(
                                Icons.motorcycle_rounded,
                                size: 25,
                              ),
                              options: FFButtonOptions(
                                width: 230,
                                height: 50,
                                color: Color(0xFFEDED16),
                                textStyle: FlutterFlowTheme.of(context).title1,
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        if (isStarted)
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 20, 0, 10),
                            child: FFButtonWidget(
                              onPressed: () {
                                setState(() {
                                  showDialog(
                                      context: context,
                                      builder: (_) {
                                        return a1;
                                      });
                                });
                              },
                              text: 'STOP RIDE',
                              icon: Icon(
                                Icons.stop_circle,
                                size: 25,
                              ),
                              options: FFButtonOptions(
                                width: 230,
                                height: 50,
                                color: Color(0xFFEDED16),
                                textStyle: FlutterFlowTheme.of(context).title1,
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              )),
          // Expanded(
          //   flex: 1,
          //   child: Container(
          //     color: Colors.blue,
          //     child: Container(
          //         margin: const EdgeInsets.all(10.0),
          //         child: Stack(
          //           children: [
          //             if (!isStarted)
          //               Center(
          //                 // margin: EdgeInsets.only(left: 20.0, right: 20.0),
          //                 child: ElevatedButton(
          //                     onPressed: () {
          //                       setState(() {
          //                         isStarted = true;
          //                         startTimer();
          //                         LatLng latLng =
          //                             getLastPolyLine(polylineCoordinates);
          //                         polylineCoordinates.clear();
          //                         polylineCoordinates.add(latLng);
          //                         getAddress();
          //                       });
          //                     },
          //                     child: const Text('Start Ride')),
          //               ),
          //             if (isStarted)
          //               Align(
          //                 alignment: Alignment.topLeft,
          //                 // margin: EdgeInsets.only(left: 20.0, right: 20.0),
          //                 child: Text(
          //                   'Current Speed: ${shrinkDecimal(currentSpeed, 2)} Km/Hr',
          //                   style: const TextStyle(
          //                       color: Colors.red, fontSize: 12),
          //                 ),
          //               ),
          //             if (isStarted)
          //               Align(
          //                 alignment: Alignment.topRight,
          //                 // margin: EdgeInsets.only(left: 20.0, right: 20.0),
          //                 child: Text(
          //                   'Avg Speed: ${shrinkDecimal(avgSpeed, 2)} Km/Hr',
          //                   style: const TextStyle(
          //                       color: Colors.black45, fontSize: 12),
          //                 ),
          //               ),
          //             if (isStarted)
          //               Align(
          //                 alignment: Alignment.bottomLeft,
          //                 // margin: EdgeInsets.only(left: 20.0, right: 20.0),
          //                 child: Text(
          //                   'Dur: ${getTimeFromSeconds(duration)}',
          //                   style: const TextStyle(
          //                       color: Colors.red, fontSize: 15),
          //                 ),
          //               ),
          //             if (isStarted)
          //               Align(
          //                 alignment: Alignment.bottomRight,
          //                 // margin: EdgeInsets.only(left: 20.0, right: 20.0),
          //                 child: Text(
          //                   'Dist.: ${shrinkDecimal(totalDistance, 2)} Km',
          //                   style: const TextStyle(
          //                       color: Colors.deepOrangeAccent, fontSize: 15),
          //                 ),
          //               ),
          //             if (isStarted)
          //               Align(
          //                 alignment: Alignment.bottomCenter,
          //                 child: ElevatedButton(
          //                     onPressed: () {
          //                       showDialog(
          //                           context: context,
          //                           builder: (_) {
          //                             return a1;
          //                           });
          //                     },
          //                     child: const Text('Stop Ride')),
          //               )
          //             // Center(
          //             //     child: Text(
          //             //   'Temperature: C',
          //             //       textAlign: TextAlign.right,
          //             //   style: TextStyle(color: Colors.white, fontSize: 20),
          //             // )),
          //           ],
          //         )),
          //   ),
          // ),
        ]));

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF030112),
          elevation: 0.0,
          leading: InkWell(
              onTap: () {
                if (isStarted == true) {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return a1;
                      });
                } else {
                  Navigator.pop(context);
                }
              },
              child: Icon(
                Icons.arrow_back,
                color: Color(0xFFEDED16),
                size: 35,
              )),
        ),
        body: WillPopScope(
            onWillPop: () async {
              if (isStarted == true) {
                showDialog(
                    context: context,
                    builder: (_) {
                      return a1;
                    });
              } else {
                Navigator.pop(context);
              }
              // var n1 = AlertIntface();
              // showAlertIntFace(context, true, "", "", n1():{
              //
              // });
              return false;
            },
            child: Stack(
              children: [
                b1,
                isDiaload == false
                    ? Container()
                    : Container(
                        color: Colors.black54,
                        height: double.infinity,
                        width: double.infinity,
                        child: Center(
                            child: Card(
                          color: Colors.transparent,
                          elevation: 100.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0))),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text("Permission",
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'This app collects location data to enable weather info. smooth ebike ride experience even when the app is closed or not in use.',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 100),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              child: Text(
                                                "DENY",
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              isDiaload = false;
                                              setState(() {});
                                            },
                                            child: Container(
                                              child: Text("ACCEPT",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )),
                      ),
              ],
            )),
      ),
    );
  }
}
