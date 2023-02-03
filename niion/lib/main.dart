import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import 'Dashboard.dart';
import 'Constants.dart';
import 'Globals.dart';
import 'SignUp.dart';

dynamic storage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  storage ??= LocalStorage(localDbName);
  bool status = await isLoggedIn();

  runApp(MaterialApp(
    home: status ? const Dashboard() : const SignUp(),
    debugShowCheckedModeBanner: false,
  ));
}