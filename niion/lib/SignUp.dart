import 'package:flutter/material.dart';
import 'package:niion/Constants.dart';

import 'Dashboard.dart';
import 'Globals.dart';
import 'NotificationApi.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp> {
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    NotificationApi.init();
    NotificationApi.showNtfc(id:0, title: "", body: "", payload: 'n.d');
    NotificationApi.cancelNtfc(id: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appName),
      ),
      body: Container(
        margin: const EdgeInsets.only(right: 20, left: 20),
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Register',
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.bold),
                  )),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: TextField(
                    maxLength: 30,
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Name'),
                  )),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: TextField(
                    maxLength: 50,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Email'),
                  )),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: TextField(
                    maxLength: 10,
                    controller: numberController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Number'),
                  )),
              ElevatedButton(
                  onPressed: () {
                    saveLocal(prefUserName, nameController.text.toString());
                    saveLocal(prefUserEmail, emailController.text.toString());
                    saveLocal(prefUserNumber, numberController.text.toString());
                    setLoggedIn(true);
                    showToast("Registration Done");
                    resetBatteryRange();
                    openCloseScreen(context, const Dashboard());
                  },
                  child: const Text('Sign Up'))
            ],
          ),
        ),
      ),
    );
  }
}
