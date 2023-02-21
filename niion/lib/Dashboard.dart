import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:intl/intl.dart';
import 'package:niion/RideDetails.dart';
import 'package:niion/pojo/RidePojo.dart';
import 'package:niion/pojo/WeatherPojo.dart';
import 'package:niion/Constants.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Globals.dart';
import 'NotificationApi.dart';
import 'RidesDatabase.dart';
import '../ContactUs.dart';
import 'Profile.dart';
import 'RideHistory.dart';
import 'Test.dart';
import 'Test1.dart';
import 'TrackRide.dart';
import 'flutter_flow/flutter_flow_icon_button.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_widgets.dart';

var userName = "",
    userEmail = "",
    userNumber = "",
    _batteryRange = "",
    _batteryResetTime = "Never";
Weather? weather;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initUI();
    NotificationApi.init();
    fetchRides();
  }

  void initUI() async {
    userName = await getLocal(prefUserName);
    fetchBattery();
    if (await handleLocationPermission(context)) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      weather = await getWeather(position.latitude, position.longitude);
      print('qwedwed https:${weather?.current?.condition?.icon}');
      setState(() {});
    }
  }

  Future<void> fetchBattery() async {
    _batteryRange = await getBatteryRange();
    _batteryResetTime = await getBatteryResetTime();
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    RidesDatabase.instance.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initUI();
      setState(() {});
    }
  }

  final _unfocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<RidePojo> rides = [];

  double totalCO2 = 0.0;
  double totalDistance = 0.0;

  Future fetchRides() async {
    rides = await RidesDatabase.instance.getAllRides();
    for (int i = 0; i < rides.length; i++) {
      // print("carbonSavings : ${rides[i].carbonSavings}");
      print("distance : ${rides[i].distance}");
      totalDistance = totalDistance + rides[i].distance;
      totalCO2 = totalCO2 + rides[i].carbonSavings;
      // print("CO2 ${totalCO2}");
      print("Distance+++ ${totalDistance}");
    }
    // print("totalCO2 ${totalCO2}");
    print("totalDistance ${totalDistance}");
    setState(() {});
  }

  double calculateCO2(double rideDistance) {
    double c = 0.0;
    double F1 = rideDistance * 0.011 * 0.85;
    double F2 = (rideDistance / 60) * 2.3;

    double finalValue = c + (F2 - F1);

    return finalValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Color(0xFF030112),
        automaticallyImplyLeading: false,
        title: Text(
          'Niion',
          style: FlutterFlowTheme.of(context).title2.override(
                fontFamily: 'Poppins',
                color: Color(0xFFEDED16),
                fontSize: 22,
              ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 2,
      ),
      drawer: const SideDrawer(),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFF1F4F8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(0, -0.45),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 44, 16, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 30,
                              borderWidth: 1,
                              buttonSize: 44,
                              icon: Icon(
                                Icons.menu_rounded,
                                color: Color(0xFF101213),
                                size: 24,
                              ),
                              onPressed: () {
                                print('IconButton pressed ...');
                                scaffoldKey.currentState?.openDrawer();
                              },
                            ),
                            Text(
                              'Hello,',
                              style:
                                  FlutterFlowTheme.of(context).title1.override(
                                        fontFamily: 'Outfit',
                                        color: Color(0xFF101213),
                                        fontSize: 32,
                                        fontWeight: FontWeight.normal,
                                      ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(2, 0, 0, 0),
                              child: Text(
                                'Maverick',
                                style: FlutterFlowTheme.of(context)
                                    .title1
                                    .override(
                                      fontFamily: 'Outfit',
                                      color: Color(0xFF4B39EF),
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 12, 20, 12),
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              color: Color(0x34090F13),
                              offset: Offset(0, 2),
                            )
                          ],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                              child: Image.asset(
                                'assets/images/Weather.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 0, 10, 0),
                                        child: Text(
                                          "${weather?.current?.tempC ?? ""}°",
                                          style: FlutterFlowTheme.of(context)
                                              .bodyText1
                                              .override(
                                                fontFamily: 'Poppins',
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        "${weather?.current?.condition?.text ?? ""}",
                                        style: FlutterFlowTheme.of(context)
                                            .bodyText1,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${DateFormat('EEEE').format(DateTime.now())}, ',
                                        style: FlutterFlowTheme.of(context)
                                            .subtitle1
                                            .override(
                                              fontFamily: 'Outfit',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            ),
                                      ),
                                      Text(
                                        '${getDateTime(weather?.location?.localtimeEpoch)}',
                                        style: FlutterFlowTheme.of(context)
                                            .subtitle1
                                            .override(
                                              fontFamily: 'Outfit',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 4, 0, 0),
                                    child: Text(
                                      '${weather?.location?.name ?? ""}, ${weather?.location?.region ?? ""}',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyText2
                                          .override(
                                            fontFamily: 'Outfit',
                                            color: Color(0xFF57636C),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w200,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 12, 20, 12),
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Color(0x34090F13),
                        offset: Offset(0, 2),
                      )
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                            child: Image.asset(
                              'assets/images/co2savings.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 0, 10, 0),
                                      child: Text(
                                        '${totalCO2.toStringAsFixed(2)} kms',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyText1
                                            .override(
                                              fontFamily: 'Poppins',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      'Savings',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyText2
                                          .override(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w200,
                                          ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 0, 10, 0),
                                      child: Text(
                                        '${totalDistance.toStringAsFixed(2)} kms',
                                        style: FlutterFlowTheme.of(context)
                                            .subtitle1
                                            .override(
                                              fontFamily: 'Outfit',
                                              color: FlutterFlowTheme.of(context)
                                                  .alternate,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      'Green Rides',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyText2
                                          .override(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w200,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 80),
                          child: FlutterFlowIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 1,
                            borderWidth: 1,
                            buttonSize: 40,
                            icon: Icon(
                              Icons.info_outlined,
                              color: Color(0xFF7C868D),
                              size: 18,
                            ),
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (alertDialogContext) {
                                  return AlertDialog(
                                    title: Text('Carbon Savings'),
                                    content: Text(
                                        'Carbon savings are indicative for equivalent ride with a petrol 2-wheeler such as Activa. This value can be affected by factors such as the riders and bike’s weight, aerodynamics, and rider behavior. This value is not fixed, and it can change depending on the way the scooter/bike is ridden and maintained.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(alertDialogContext),
                                        child: Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 12, 20, 12),
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Color(0x34090F13),
                        offset: Offset(0, 2),
                      )
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                            child: Image.asset(
                              'assets/images/batterynew.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 0, 10, 0),
                                      child: Text(
                                        '$_batteryRange Kms',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyText1
                                            .override(
                                              fontFamily: 'Poppins',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      'Remaining',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyText2
                                          .override(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w200,
                                          ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 0, 10, 0),
                                      child: Text(
                                        '$_batteryResetTime',
                                        style: FlutterFlowTheme.of(context)
                                            .subtitle1
                                            .override(
                                              fontFamily: 'Outfit',
                                              color: FlutterFlowTheme.of(context)
                                                  .alternate,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      'Last Reset',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyText2
                                          .override(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w200,
                                          ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 0, 10, 0),
                                      child: Text(
                                        'Wednesday, 1st Feb',
                                        style: FlutterFlowTheme.of(context)
                                            .subtitle1
                                            .override(
                                              fontFamily: 'Outfit',
                                              color: FlutterFlowTheme.of(context)
                                                  .alternate,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 80),
                          child: FlutterFlowIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 1,
                            borderWidth: 1,
                            buttonSize: 40,
                            icon: Icon(
                              Icons.info_outlined,
                              color: Color(0xFF7C868D),
                              size: 18,
                            ),
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (alertDialogContext) {
                                  return AlertDialog(
                                    title: Text('Battery Capacity'),
                                    content: Text(
                                        'Remaining range (kms) is indicative based on accurate reset of the in-app battery status on full charge; and consistent tracking of rides using the app. The range per remaining battery capacity is also impacted by terrain, weight, riding style and weather conditions.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(alertDialogContext),
                                        child: Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 1, 20, 52),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 10, 10, 0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                await resetBatteryRange();
                                showToast("Battery Reset Successful");
                                await fetchBattery();
                              },
                              text: 'Reset Battery',
                              icon: Icon(
                                Icons.battery_charging_full,
                                size: 15,
                              ),
                              options: FFButtonOptions(
                                width: 170,
                                height: 40,
                                color: Color(0x8DEE8B60),
                                textStyle: FlutterFlowTheme.of(context)
                                    .subtitle2
                                    .override(
                                      fontFamily: 'Poppins',
                                      color: Color(0xFF030112),
                                    ),
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 10, 10, 0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                openScreen(context, const RideHistory());
                              },
                              text: 'Ride History',
                              icon: Icon(
                                Icons.history,
                                size: 15,
                              ),
                              options: FFButtonOptions(
                                width: 170,
                                height: 40,
                                color: Color(0x8DEE8B60),
                                textStyle: FlutterFlowTheme.of(context)
                                    .subtitle2
                                    .override(
                                      fontFamily: 'Poppins',
                                      color: Color(0xFF030112),
                                    ),
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 60, 0, 10),
                        child: FFButtonWidget(
                          onPressed: () async {
                            if (!await handleLocationPermission(context)) {
                            } else {
                              LatLng latLng = await getLoc();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MapRoute(pos: latLng)),
                              ).then((value) => fetchBattery());
                            }
                          },
                          text: 'START RIDE',
                          icon: Icon(
                            Icons.motorcycle_rounded,
                            size: 15,
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//       drawer: const SideDrawer(),
//       appBar: AppBar(
//         title: const Text(appName),
//       ),
//       body: SingleChildScrollView(
//           child: Stack(children: <Widget>[
//         Container(
//           color: Colors.white,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               SizedBox(
//                 height: 200,
//                 width: 165,
//                 // color: Colors.red,
//                 child: GradientCard(
//                   gradient: Gradients.taitanum,
//                   elevation: 8,
//                   shadowColor:
//                       Gradients.taitanum.colors.last.withOpacity(0.25),
//                   margin: const EdgeInsets.symmetric(
//                       vertical: 10, horizontal: 10),
//                   child: SizedBox(
//                     height: 10,
//                     width: 10,
//                     child: Image.network(
//                         'https:${weather?.current?.condition?.icon}',
//                         // width: 150,
//                         // height: 75,
//                         fit: BoxFit.fill),
//                   ),
//                 ),
//               ),
//               // Container(
//               //   height: double.infinity,
//               //   alignment: Alignment.center, // This is needed
//               //   child: Image.network(
//               //     'https:${weather?.current?.condition?.icon}',
//               //     fit: BoxFit.contain,
//               //     width: 300,
//               //   ),
//               // ),
//               Padding(
//                   padding: const EdgeInsets.only(left: 10.0, top: 10),
//                   child: Text(
//                     'Temperature: ${weather?.current?.tempC}° C',
//                     style: const TextStyle(
//                         color: Colors.deepPurple, fontSize: 20),
//                   )),
//               Padding(
//                   padding: const EdgeInsets.only(left: 10.0, top: 10),
//                   child: Text(
//                     'Condition: ${weather?.current?.condition?.text}',
//                     style: const TextStyle(
//                         color: Colors.deepPurple, fontSize: 20),
//                   )),
//               Padding(
//                   padding: const EdgeInsets.only(left: 10.0, top: 10),
//                   child: Text(
//                     'Place: ${weather?.location?.name}, ${weather?.location?.region}',
//                     style: const TextStyle(
//                         color: Colors.deepPurple, fontSize: 20),
//                   )),
//               Padding(
//                   padding: const EdgeInsets.only(left: 10.0, top: 10),
//                   child: Text(
//                     'Date & Time: ${getDateTime(weather?.location?.localtimeEpoch)}',
//                     style: const TextStyle(
//                         color: Colors.deepPurple, fontSize: 20),
//                   )),
//               Padding(
//                   padding: const EdgeInsets.only(left: 10.0, top: 30),
//                   child: Text(
//                     'Battery Range: $_batteryRange Km\nLast Reset: $_batteryResetTime',
//                     style: const TextStyle(
//                         color: Colors.deepPurple, fontSize: 20),
//                   )),
//               Padding(
//                   padding: const EdgeInsets.only(left: 10.0, top: 0),
//                   child: ElevatedButton(
//                       onPressed: () async {
//                         await resetBatteryRange();
//                         showToast("Battery Reset Successful");
//                         await fetchBattery();
//                         // openScreen(context, MyApp());
//                         // openScreen(context, const HomePageWidget1());
//                       },
//                       child: const Text('Reset Battery'))),
//
//               // Padding(
//               //     padding: const EdgeInsets.only(left: 10.0, top: 0),
//               //     child: ElevatedButton(
//               //         onPressed: () async {
//               //           await consumeBattery(12);
//               //         },
//               //         child: const Text('Consume 12km'))),
//               // Padding(
//               //     padding: const EdgeInsets.only(left: 10.0, top: 0),
//               //     child: ElevatedButton(
//               //         onPressed: () async {
//               //           // List<LatLng>? list = <LatLng>[];
//               //           // list.add(const LatLng(0.0, 0.0));
//               //           // await RidesDatabase.instance.createRide(RidePojo(
//               //           //     duration: 347,
//               //           //     distance: 7.49,
//               //           //     avgSpeed: 9.48,
//               //           //     polylines: list,
//               //           //     createdTime: 10230132112));
//               //           // await fetchBattery();
//               //         },
//               //         child: const Text('Get Battery'))),
//               Padding(
//                   padding: const EdgeInsets.only(left: 10.0, top: 0),
//                   child: ElevatedButton(
//                       onPressed: () async {
//                         showAlert(context, true, "Your Total Carbon Savings",
//                             "${(await RidesDatabase.instance.getTotalCarbonSavings()).toStringAsFixed(2)} Kgs");
//                       },
//                       child: const Text('Track Your Carbon Credits'))),
//               Padding(
//                   padding: const EdgeInsets.only(left: 10.0, top: 0),
//                   child: ElevatedButton(
//                       onPressed: () {
//                         launchUrl(
//                             Uri.parse(Uri.encodeFull(shopOurProductsAPI)),
//                             mode: LaunchMode.externalApplication);
//                       },
//                       child: const Text('Shop Our Products'))),
//               Padding(
//                   padding: const EdgeInsets.only(left: 10.0, top: 0),
//                   child: ElevatedButton(
//                       onPressed: () {
//                         openScreen(context, const RideHistory());
//                       },
//                       child: const Text('Ride History'))),
//               Padding(
//                   padding: const EdgeInsets.only(left: 10.0, top: 0),
//                   child: ElevatedButton(
//                       onPressed: () async {
//                         if (!await handleLocationPermission(context)) {
//                         } else {
//                           LatLng latLng = await getLoc();
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => MapRoute(pos: latLng)),
//                           ).then((value) => fetchBattery());
//                         }
//                       },
//                       child: const Text('Start Ride'))),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   Padding(
//                       padding: const EdgeInsets.only(left: 10.0, top: 0),
//                       child: ElevatedButton(
//                           onPressed: () {
//                             launchUrl(
//                                 Uri.parse(Uri.encodeFull(facebookPage)),
//                                 mode: LaunchMode.externalApplication);}, child: const Text('Facebook'))),
//                   Padding(
//                       padding: const EdgeInsets.only(left: 10.0, top: 0),
//                       child: ElevatedButton(
//                           onPressed: () {
//                             launchUrl(
//                                 Uri.parse(Uri.encodeFull(instaPage)),
//                                 mode: LaunchMode.externalApplication);
//                           }, child: const Text('Instagram'))),
//                   Padding(
//                       padding: const EdgeInsets.only(left: 10.0, top: 0),
//                       child: ElevatedButton(
//                           onPressed: () {
//                             launchUrl(
//                                 Uri.parse(Uri.encodeFull(twitterPage)),
//                                 mode: LaunchMode.externalApplication);
//                           }, child: const Text('Twitter'))),
//                 ],
//               )
//             ],
//           ),
//         )
//       ])));
// }
// }
}

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: SingleChildScrollView(
            child: Stack(children: <Widget>[
      Column(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Center(
              child: Text(
                'Hi, $userName!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.deepPurpleAccent),
            title: const Text('Home'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.battery_charging_full,
                color: Colors.deepPurpleAccent),
            title: const Text('Track Your Battery'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading:
                const Icon(Icons.drive_eta, color: Colors.deepPurpleAccent),
            title: const Text('Ride History'),
            onTap: () {
              Navigator.of(context).pop();
              openScreen(context, const RideHistory());
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.notifications, color: Colors.deepPurpleAccent),
            title: const Text('Notification Center'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.deepPurpleAccent),
            title: const Text('Profile'),
            onTap: () async {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Profile()),
              ).then((value) => _DashboardState().initUI());
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.deepPurpleAccent),
            title: const Text('About Us'),
            onTap: () {
              Navigator.of(context).pop();
              launchUrl(Uri.parse(Uri.encodeFull(aboutUsAPI)),
                  mode: LaunchMode.inAppWebView);
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.deepPurpleAccent),
            title: const Text('Call Us'),
            onTap: () {
              Navigator.of(context).pop();
              FlutterPhoneDirectCaller.callNumber("+91$contactNumber");
              // openScreen(context, const ContactUs());
            },
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.deepPurpleAccent),
            title: const Text('Email Us'),
            onTap: () {
              Navigator.of(context).pop();
              FlutterEmailSender.send(Email(
                body: "Hi",
                subject: "Niion App Support",
                recipients: [contactEmail],
                isHTML: false,
              ));
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.privacy_tip, color: Colors.deepPurpleAccent),
            title: const Text('Privacy Policy'),
            onTap: () {
              Navigator.of(context).pop();
              launchUrl(Uri.parse(Uri.encodeFull(ppAPI)),
                  mode: LaunchMode.inAppWebView);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notes, color: Colors.deepPurpleAccent),
            title: const Text('Terms & Conditions'),
            onTap: () {
              Navigator.of(context).pop();
              launchUrl(Uri.parse(Uri.encodeFull(tncAPI)),
                  mode: LaunchMode.inAppWebView);
            },
          ),
          ListTile(
            leading: const Icon(Icons.question_answer,
                color: Colors.deepPurpleAccent),
            title: const Text('FAQ\'s'),
            onTap: () {
              Navigator.of(context).pop();
              launchUrl(Uri.parse(Uri.encodeFull(faqAPI)),
                  mode: LaunchMode.inAppWebView);
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.exit_to_app, color: Colors.deepPurpleAccent),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.of(context).pop();
              await logout();
              closeScreen(context);
            },
          ),
        ],
      ),
    ])));
  }
}
