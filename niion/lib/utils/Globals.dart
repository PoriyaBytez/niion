import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:location/location.dart' as a;
import 'package:niion/pojo/LatLon.dart';
import 'package:niion/pojo/Weather.dart' as b;
import 'package:permission_handler/permission_handler.dart';

import 'Constants.dart';

dynamic storage;

initFlutter() {
  storage ??= LocalStorage(localDbName);
}

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
  Widget okButton = FlatButton(
    child: const Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  Widget noButton = FlatButton(
    child: const Text("No"),
    onPressed: () {
      Navigator.of(context).pop();
      showAlert(context, cancelable, title, message);
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

closeScreen(BuildContext context) {
  Navigator.pop(context);
}

dynamic getLocal(String key) {
  return storage.getItem(key);
}

saveLocal(String key, var value) {
  storage.setItem(key, value);
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
    showSnack(context, 'Location services are disabled! Please enable.');
    enableGPS();
    return false;
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      showSnack(context, 'Location Permission Denied!');
      return false;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    showToast(
        'Location Permission Permanently Denied! Please grant from Settings.');
    openAppSettings();
    return false;
  }
  return true;
}

Future<LatLon> getLoc() async {
  var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);
  return LatLon(position.latitude, position.longitude);
}

Future enableGPS() async {
  var location = a.Location();
  if (!await location.serviceEnabled()) {
    location.requestService();
  } else {
    showToast("GPS Enabled!");
  }
}
