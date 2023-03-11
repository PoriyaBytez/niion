import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:location/location.dart' as a;
import 'package:niion/AlertIntface.dart';
import 'package:niion/main.dart';
import 'package:niion/pojo/RidePojo.dart';
import 'package:niion/pojo/WeatherPojo.dart' as b;
import 'package:permission_handler/permission_handler.dart';

import '../Constants.dart';
import 'NotificationApi.dart';
import 'RidesDatabase.dart';

showToast(String message) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      fontSize: 16.0);
}

showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
  ));
}

showAlert(BuildContext context, bool cancelable, String title, String message) {
  // Create button
  Widget okButton = ElevatedButton(
    child: const Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [okButton],
  );

  // show the dialog
  showDialog(
    context: context,
    barrierDismissible: cancelable,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showAlertIntFace(BuildContext context, bool cancelable, String title,
    String message, AlertIntface alertIntface) {
  // Create button
  Widget okButton = ElevatedButton(
    child: const Text("Yes"),
    onPressed: () {
      Navigator.of(context).pop();
      alertIntface.onClick();
    },
  );

  Widget noButton = OutlinedButton(
    child: const Text("No"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [okButton, noButton],
  );

  // show the dialog
  showDialog(
    context: context,
    barrierDismissible: cancelable,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

openScreen(BuildContext context, Widget widget) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => widget),
  );
}

openCloseScreen(BuildContext context, Widget widget) {
  closeScreen(context);
  openScreen(context, widget);
}

closeScreen(BuildContext context) {
  Navigator.pop(context);
}

dynamic getLocal(String key) async {
  await storage.ready;
  return await storage.getItem(key);
}

saveLocal(String key, var value) async {
  await storage.ready;
  await storage.setItem(key, value);
}

Future<b.Weather?> getWeather(double lat, double lon) async {
  var response = await postRequestList(
      "https://api.weatherapi.com/v1/current.json",
      <String>["key", apiKeyWeather, "q", "$lat,$lon"]);
  return b.weatherFromJson(response.body);
}

Map<String, dynamic> createMap(List<String> s) {
  var map = <String, dynamic>{};
  for (int i = 0; i < s.length; i++) {
    map[s[i]] = map[++i];
  }
  return map;
}

Future<http.Response> postRequestList(String url, List<String> list) async {
  var map = <String, dynamic>{};
  for (int i = 0; i < list.length; i++) {
    map[list[i]] = list[++i];
  }
  return await postRequestMap(url, map);
}

Future<http.Response> postRequestMap(
    String url, Map<String, dynamic> map) async {
  return await http
      .post(Uri.parse(url), // headers: {"Content-Type": "application/json"},
          body: map)
      .then((http.Response response) {
    if (kDebugMode) {
      log("BaseOFPType ${response.request?.method}");
      log("BaseOFPURL ${response.request?.url}");
      log("BaseOFPHeads ${response.request?.headers.toString()}");
      log("BaseOFPParams ${map.toString()}");
      log("BaseOFPResp ${response.body}");
    }
    return response;
  });
}

Future<bool> handleLocationPermission(BuildContext context) async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    showSnack(context, gpsMsg);
    enableGPS();
    return false;
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      showSnack(context, locationPermDenied);
      return false;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    showToast(locationPermRejected);
    openAppSettings();
    return false;
  }
  return true;
}

Future<LatLng> getLoc() async {
  var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);
  return LatLng(position.latitude, position.longitude);
}

Future enableGPS() async {
  var location = a.Location();
  if (!await location.serviceEnabled()) {
    location.requestService();
  } else {
    showToast("GPS Enabled!");
  }
}

resetBatteryRange() async {
  await saveLocal(prefBatteryRange, batteryRange);
  await saveLocal(prefBatteryResetDate, getDateTime(getTS()));
  await saveLocal(prefBatteryResetTime, getTime(getTS()));
  await saveLocal(prefBatteryThresholdState, 0);
}

bool isAlert = false;

Future<void> consumeBattery(double km, BuildContext context) async {
  var range = await getLocal(prefBatteryRange) - km;
  if (range < 0) range = 0;
  await saveLocal(prefBatteryRange, range);
  var localSlab = await getLocal(prefBatteryThresholdState);
  var currentSlab =
      (range > batteryThreshold1) ? 0 : ((range > batteryThreshold2) ? 1 : 2);
  if (localSlab != currentSlab) {
    await saveLocal(prefBatteryThresholdState, currentSlab);
    if (currentSlab > 0 && !(localSlab == 2 && currentSlab == 1)) {
      int a;
      if(range <= 5.0){
        a = 5;
      }else {
        a = 10;
      }
      showBatteryNtfc(a);
      await RidesDatabase.instance.createNotification(NotificationPojo(
          createdTime: getTS(),
          message:
              "You have less than $a km${range > 1.0 ? 's' : ''} of battery remaining. Please charge your battery."));
      final player = AudioPlayer();
      player.setAsset('assets/audios/Niion-alert-notification.wav');
      player.play();
      _showMyDialog(context, a);
    }
  }
}

Future<void> _showMyDialog(BuildContext context, var km) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Battery Alert'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                  'You have less than $km km${km > 1.0 ? 's' : ''} of battery remaining. Please charge your battery.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void showBatteryNtfc(var range) {
  print("fire=========================Notification");
  // String title = "Battery${(currentSlab > 1) ? " Critically" : ""} Low";
  String title = "Battery Alert";
  // String body = "${range.toStringAsFixed(2)} Km Left. Please charge now!";
  // double km = double.parse(range.toStringAsFixed(2));
  int a;
  if(range <= 5.0){
    a = 5;
  }else {
    a = 10;
  }
  String body =
      "You have less than $a km${range > 1.0 ? 's' : ''} of battery remaining. Please charge your battery.";
  NotificationApi.showNtfc(title: title, body: body, payload: 'nik.red');
}

Future showAlertIfBatteryLess() async {
  var range = await getLocal(prefBatteryRange);
  if (range < batteryThreshold1) {
    showBatteryNtfc(range);
  }
}

Future<String> getBatteryRange() async {
  return shrinkDecimal(await getLocal(prefBatteryRange), 2);
}

String shrinkDecimal(var s, int count) {
  return s.toStringAsFixed(count);
}

Future<String> getBatteryResetTime() async {
  return await getLocal(prefBatteryResetDate);
}

Future<String> getBatteryTime() async {
  return await getLocal(prefBatteryResetTime);
}

Future<bool> isLoggedIn() async {
  return await getLocal(prefIsLoggedIn) ?? false;
}

void setLoggedIn(value) async {
  await saveLocal(prefIsLoggedIn, value);
}

int getTS() {
  return DateTime.now().millisecondsSinceEpoch;
}

String getDateTime(int? localtimeEpoch) {
  localtimeEpoch ??= getTS();
  if (localtimeEpoch.toString().length <= 10) {
    localtimeEpoch = localtimeEpoch * 1000;
  }
  var dt = DateTime.fromMillisecondsSinceEpoch((localtimeEpoch));
  return DateFormat('dd MMM yyyy').format(dt);
  // return DateFormat('dd MM, hh:mm a').format(dt);
}

String getTime(int? localtimeEpoch) {
  localtimeEpoch ??= getTS();
  if (localtimeEpoch.toString().length <= 10) {
    localtimeEpoch = localtimeEpoch * 1000;
  }
  var dt = DateTime.fromMillisecondsSinceEpoch((localtimeEpoch));
  print(" Time dsad ${DateFormat('hh:mm a').format(dt)}");
  return DateFormat('hh:mm a').format(dt);
}

String getTimeFromSeconds(int seconds) {
  return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
}

Future<void> logout() async {
  await storage.clear();
}

double _electricEmission(double km) {
  return km * eEmissionFactor;
}

double _fossilEmission(double km) {
  return km * pEmissionFactor;
}

double carbonSavings(double km) {
  return _fossilEmission(km) - _electricEmission(km);
}
