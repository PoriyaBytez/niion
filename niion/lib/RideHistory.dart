import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niion/pojo/RidePojo.dart';
import 'package:niion/RidesDatabase.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

class RideHistory extends StatefulWidget {

  String address;
  RideHistory({required this.address});
  @override
  State<StatefulWidget> createState() {
    return _RideHistoryState();
  }


}

class _RideHistoryState extends State<RideHistory> {
  List<RidePojo> rides = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    fetchRides();
    super.initState();
    // get();
  }

  Future fetchRides() async {
    rides = await RidesDatabase.instance.getAllRides();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void yourFunction(double latitude, double longitude) async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        var currentLocation = LatLng(latitude, longitude);
        print("ld ${currentLocation.toString()}");
      },
    );
  }

  getTime(int start,int end) {

    DateTime dateTimeStart = DateTime.fromMillisecondsSinceEpoch(start);
    DateTime dateTimEnd = DateTime.fromMillisecondsSinceEpoch(end);
    Duration difference = dateTimEnd.difference(dateTimeStart);
    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);
    // int hours = inputSeconds ~/ 3600;
    // int minutes = (inputSeconds % 3600) ~/ 60;
    return "$hours h $minutes m";
  }

//   List<DateTime> dates = [
//     DateTime.now(),
//     DateTime.now().subtract(Duration(days: 1)),
//     DateTime.now().subtract(Duration(days: 2)),
//     DateTime.now().subtract(Duration(days: 3)),
//     DateTime.now().subtract(Duration(days: 4)),
//     DateTime.now().subtract(Duration(days: 5)),
//     DateTime.now().subtract(Duration(days: 6)),
//     DateTime.now().subtract(Duration(days: 7)),
//     DateTime.now().subtract(Duration(days: 8)),
//     DateTime.now().subtract(Duration(days: 9)),
//     DateTime.now().subtract(Duration(days: 10)),
//   ];
//
//
//   get(){
//     // Get dates for this week and last week
//     DateTime now = DateTime.now();
//     DateTime thisWeekStart =  now.subtract(Duration(days: now.weekday - 1));
//     DateTime lastWeekStart = thisWeekStart.subtract(Duration(days: 7));
//     List<DateTime> thisWeekDates = dates.where((date) => date.isAfter(thisWeekStart.subtract(Duration(days: 1)))).toList();
//     List<DateTime> lastWeekDates = dates.where((date) => date.isAfter(lastWeekStart.subtract(Duration(days: 1))) && date.isBefore(thisWeekStart.subtract(Duration(days: 1)))).toList();
//
// // Sort dates in ascending order
//     thisWeekDates.sort((a, b) => a.compareTo(b));
//     lastWeekDates.sort((a, b) => a.compareTo(b));
//
//     print("This week dates: ${thisWeekDates.length}");
//     print("Last week dates: ${lastWeekDates.length}");
//   }


  List<DateTime> dates = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Color(0xFF030112),
        automaticallyImplyLeading: false,
        title: Text(
          'Ride History',
          style: FlutterFlowTheme.of(context).title1.override(
                fontFamily: 'Poppins',
                color: Color(0xFFEDED16),
              ),
        ),
        leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFFEDED16),
              size: 35,
            )),
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
            child: Icon(
              Icons.filter_alt,
              color: FlutterFlowTheme.of(context).black600,
              size: 24,
            ),
          ),
        ],
        centerTitle: false,
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Padding(
            //   padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
            //   child: ListView(
            //     padding: EdgeInsets.zero,
            //     primary: false,
            //     shrinkWrap: true,
            //     scrollDirection: Axis.vertical,
            //     children: [
            //       Padding(
            //         padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
            //         child: Container(
            //           width: double.infinity,
            //           decoration: BoxDecoration(
            //             color: FlutterFlowTheme.of(context).secondaryBackground,
            //             boxShadow: [
            //               BoxShadow(
            //                 blurRadius: 3,
            //                 color: Color(0x430F1113),
            //                 offset: Offset(0, 1),
            //               )
            //             ],
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //           child: Column(
            //             mainAxisSize: MainAxisSize.max,
            //             children: [
            //               Padding(
            //                 padding:
            //                 EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
            //                 child: Row(
            //                   mainAxisSize: MainAxisSize.max,
            //                   crossAxisAlignment: CrossAxisAlignment.center,
            //                   children: [
            //                     Icon(
            //                       Icons.date_range,
            //                       color: Colors.black,
            //                       size: 20,
            //                     ),
            //                     Padding(
            //                       padding: EdgeInsetsDirectional.fromSTEB(
            //                           5, 4, 0, 0),
            //                       child: Text(
            //                         '01 Feb, 2022',
            //                         style: FlutterFlowTheme.of(context)
            //                             .subtitle2
            //                             .override(
            //                           fontFamily: 'Poppins',
            //                           color: Color(0xFF030112),
            //                         ),
            //                       ),
            //                     ),
            //                     Padding(
            //                       padding: EdgeInsetsDirectional.fromSTEB(
            //                           24, 0, 0, 0),
            //                       child: Icon(
            //                         Icons.location_on_sharp,
            //                         color: Color(0xFF030112),
            //                         size: 20,
            //                       ),
            //                     ),
            //                     Padding(
            //                       padding: EdgeInsetsDirectional.fromSTEB(
            //                           4, 0, 0, 0),
            //                       child: Text(
            //                         'Securendarabad',
            //                         style: FlutterFlowTheme.of(context)
            //                             .subtitle2
            //                             .override(
            //                           fontFamily: 'Poppins',
            //                           color: Color(0xFF030112),
            //                         ),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //               Padding(
            //                 padding:
            //                 EdgeInsetsDirectional.fromSTEB(12, 4, 12, 8),
            //                 child: Row(
            //                   mainAxisSize: MainAxisSize.max,
            //                   children: [
            //                     Padding(
            //                       padding: EdgeInsetsDirectional.fromSTEB(
            //                           0, 0, 0, 4),
            //                       child: Icon(
            //                         Icons.schedule,
            //                         color:
            //                         FlutterFlowTheme.of(context).alternate,
            //                         size: 20,
            //                       ),
            //                     ),
            //                     Padding(
            //                       padding: EdgeInsetsDirectional.fromSTEB(
            //                           4, 0, 0, 0),
            //                       child: Text(
            //                         '8:00 am - 00 h 33 m',
            //                         style: FlutterFlowTheme.of(context)
            //                             .bodyText1
            //                             .override(
            //                           fontFamily: 'Poppins',
            //                           color: FlutterFlowTheme.of(context)
            //                               .alternate,
            //                           fontSize: 16,
            //                         ),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //               Padding(
            //                 padding:
            //                 EdgeInsetsDirectional.fromSTEB(12, 4, 12, 8),
            //                 child: Row(
            //                   mainAxisSize: MainAxisSize.max,
            //                   children: [
            //                     Padding(
            //                       padding: EdgeInsetsDirectional.fromSTEB(
            //                           0, 0, 0, 4),
            //                       child: Icon(
            //                         Icons.speed,
            //                         color: FlutterFlowTheme.of(context)
            //                             .secondaryText,
            //                         size: 20,
            //                       ),
            //                     ),
            //                     Padding(
            //                       padding: EdgeInsetsDirectional.fromSTEB(
            //                           4, 0, 0, 0),
            //                       child: Text(
            //                         '14.5 km/h',
            //                         style: FlutterFlowTheme.of(context)
            //                             .bodyText1
            //                             .override(
            //                           fontFamily: 'Poppins',
            //                           color: FlutterFlowTheme.of(context)
            //                               .secondaryText,
            //                           fontSize: 16,
            //                         ),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Row(
            //   mainAxisSize: MainAxisSize.max,
            //   children: [
            //     Padding(
            //       padding: EdgeInsetsDirectional.fromSTEB(16, 4, 0, 12),
            //       child: Text(
            //         'Last Week',
            //         style: FlutterFlowTheme.of(context).bodyText2.override(
            //           fontFamily: 'Poppins',
            //           fontWeight: FontWeight.w500,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  primary: false,
                  shrinkWrap: true,
                  itemCount: rides.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, int index) {
                    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                        rides[index].createdTime!);

                    // dates.add(dateTime);
                    // DateTime now = DateTime.now();
                    // DateTime thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
                    // DateTime lastWeekStart = thisWeekStart.subtract(Duration(days: 7));
                    // List<DateTime> thisWeekDates = dates.where((date) => date.isAfter(thisWeekStart.subtract(Duration(days: 1)))).toList();
                    // List<DateTime> lastWeekDates = dates.where((date) => date.isAfter(lastWeekStart.subtract(Duration(days: 1))) && date.isBefore(thisWeekStart.subtract(Duration(days: 1)))).toList();
                    //
                    // thisWeekDates.sort((a, b) => a.compareTo(b));
                    // lastWeekDates.sort((a, b) => a.compareTo(b));
                    //
                    // print("This week dates: ${thisWeekDates.length}");
                    // print("Last week dates: ${lastWeekDates.length}");


                    bool thisWeek = false;
                    DateTime dt = DateTime.fromMillisecondsSinceEpoch(
                        rides[index].createdTime!);
                    String formattedDate = DateFormat.yMMMd().format(dt);
                    String formattedDate2 = "";
                    if (index > 0) {
                      String? date2 = index > 0
                          ? DateTime.fromMillisecondsSinceEpoch(
                          rides[index - 1].createdTime! ).toString()
                          : "";
                      DateTime dt2 = DateTime.parse(date2);
                      formattedDate2 = DateFormat.yMMMd().format(dt2);
                    }
                    if (index == 0) {
                      thisWeek = true;
                      formattedDate = "Today";
                    } else {
                      if (formattedDate == formattedDate2) {
                        thisWeek = false;
                      } else {
                        thisWeek = true;
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        thisWeek
                            ? Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16, 12, 0, 12),
                                child: Text(
                                  formattedDate,
                                  style: FlutterFlowTheme.of(context).bodyText2,
                                ),
                              )
                            : Container(),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 3,
                                  color: Color(0x430F1113),
                                  offset: Offset(0, 1),
                                )
                              ],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      12, 4, 12, 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.date_range,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            5, 4, 0, 0),
                                        child: Text(
                                          DateFormat('dd MMM,yyyy')
                                              .format(dateTime),
                                          style: FlutterFlowTheme.of(context)
                                              .subtitle2
                                              .override(
                                                fontFamily: 'Poppins',
                                                color: Color(0xFF030112),
                                              ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            24, 0, 0, 0),
                                        child: Icon(
                                          Icons.location_on_sharp,
                                          color: Color(0xFF030112),
                                          size: 20,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            4, 0, 0, 0),
                                        child: Text(
                                          rides[index].address == "" ? widget.address : rides[index].address,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: FlutterFlowTheme.of(context)
                                              .subtitle2
                                              .override(
                                                fontFamily: 'Poppins',
                                                color: Color(0xFF030112),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      12, 4, 12, 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 0, 0, 4),
                                        child: Icon(
                                          Icons.schedule,
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                          size: 20,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            4, 0, 0, 0),
                                        child: Text(
                                          '${DateFormat('hh:mm a').format(dateTime)} - ${getTime(rides[index].createdTime!,rides[index].duration!)}',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyText1
                                              .override(
                                                fontFamily: 'Poppins',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                fontSize: 16,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      12, 4, 12, 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 0, 0, 4),
                                        child: Icon(
                                          Icons.directions_bike_outlined,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 20,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            4, 0, 0, 0),
                                        child: Text(
                                          '${rides[index].distance.toStringAsFixed(2)} km',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyText1
                                              .override(
                                                fontFamily: 'Poppins',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                fontSize: 16,
                                              ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 0, 0, 4),
                                        child: Icon(
                                          Icons.shutter_speed,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 20,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            4, 0, 0, 0),
                                        child: Text(
                                          '${rides[index].avgSpeed.toStringAsFixed(2)} km/h',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyText1
                                              .override(
                                                fontFamily: 'Poppins',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                fontSize: 16,
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
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// @override
// Widget build(BuildContext context) {
//   Widget cardView(RidePojo ridePojo) => Card(
//       margin: const EdgeInsets.all(10.0),
//       child: Column(children: <Widget>[
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Carbon Savings: ${ridePojo.carbonSavings.toStringAsFixed(2)} Kg${ridePojo.carbonSavings > 1 ? 's' : ''}',
//                 style: const TextStyle(color: Colors.black, fontSize: 12),
//               ),
//             ),
//             Align(
//               alignment: Alignment.centerRight,
//               child: Text(
//                 'Date & Time.: ${getDateTime(ridePojo.createdTime)}',
//                 style: const TextStyle(color: Colors.black, fontSize: 12),
//               ),
//             ),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Dur: ${getTimeFromSeconds(ridePojo.duration!)}',
//                 style: const TextStyle(color: Colors.black, fontSize: 12),
//               ),
//             ),
//             Align(
//               alignment: Alignment.centerRight,
//               child: Text(
//                 'Dist.: ${shrinkDecimal(ridePojo.distance, 2)} Km',
//                 style: const TextStyle(color: Colors.black, fontSize: 12),
//               ),
//             ),
//           ],
//         ),
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//           Align(
//             alignment: Alignment.centerLeft,
//             child: Text(
//               'Other Data: To Add',
//               style: const TextStyle(color: Colors.black, fontSize: 12),
//             ),
//           ),
//           Align(
//             alignment: Alignment.centerRight,
//             child: Text(
//               'Avg Speed: ${shrinkDecimal(ridePojo.avgSpeed, 2)} Km/Hr',
//               style: const TextStyle(color: Colors.black, fontSize: 12),
//             ),
//           )
//         ])
//       ]));
//
//   Widget buildRidesHistory() => ListView.builder(
//         padding: const EdgeInsets.all(12.0),
//         itemCount: rides.length,
//         itemBuilder: (context, position) {
//           return cardView(rides[position]);
//         },
//       );
//
//   return Scaffold(
//       appBar: AppBar(
//         title: const Text(appName),
//       ),
//       body: Container(
//           color: Colors.white, child: Center(child: buildRidesHistory())));
// }
}
