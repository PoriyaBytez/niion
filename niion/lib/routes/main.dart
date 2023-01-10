import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:niion/routes/Dashboard.dart';
import 'package:niion/utils/Globals.dart';

import '../utils/Constants.dart';
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