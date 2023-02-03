import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:niion/Constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ContactUsState();
  }
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(appName),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Contact Us',
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.bold),
                  )),
              Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 50),
                  child: TextButton(
                    onPressed: () {
                      FlutterPhoneDirectCaller.callNumber("+91$contactNumber");
                    },
                    child: const Text(
                      'Ph: +91$contactNumber',
                      textAlign: TextAlign.center,
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 50),
                  child: TextButton(
                    onPressed: () {
                      FlutterEmailSender.send(Email(
                        body: "Hi",
                        subject: "Niion App Support",
                        recipients: [contactEmail],
                        isHTML: false,
                      ));
                    },
                    child: const Text(
                      'Email: $contactEmail',
                      textAlign: TextAlign.center,
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 10),
                  child: ElevatedButton(
                      onPressed: () {
                        launchUrl(Uri.parse(Uri.encodeFull(whatsappAPI)),
                            mode: LaunchMode.externalApplication);
                      },
                      child: const Text('Whatsapp Us'))),
              Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 10),
                  child: ElevatedButton(
                      onPressed: () {
                        launchUrl(
                            Uri.parse(Uri.encodeFull(
                                'google.navigation:q=$contactLatLon&mode=d')),
                            mode: LaunchMode.externalApplication);
                      },
                      child: const Text('Locate Us'))),
            ],
          ),
        ));
  }
}
