import 'package:flutter/material.dart';
import 'package:niion/Constants.dart';

import 'Globals.dart';

var userName = "", userEmail = "", userNumber = "";

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initUI();
  }

  void initUI() async {
    userName = await getLocal(prefUserName);
    userEmail = await getLocal(prefUserEmail);
    userNumber = await getLocal(prefUserNumber);
    nameController.text = userName;
    emailController.text = userEmail;
    numberController.text = userNumber;
    setState(() {});
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
                    'Profile',
                    style: TextStyle(
                        fontSize: 30,
                        decoration: TextDecoration.underline,
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
                    showToast("Updated Profile Successfully");
                    closeScreen(context);
                  },
                  child: const Text('Update'))
            ],
          ),
        ),
      ),
    );
  }
}
