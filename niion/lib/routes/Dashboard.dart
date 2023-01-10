import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:niion/pojo/Weather.dart';
import 'package:niion/utils/Constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/Globals.dart';
import 'ContactUs.dart';

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

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    initUI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const SideDrawer(),
        appBar: AppBar(
          title: const Text(appName),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                'https:${weather?.current?.condition?.icon}',
                width: 100,
                height: 100,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 10),
                  child: Text(
                    'Temperature: ${weather?.current?.tempC}° C',
                    style:
                        const TextStyle(color: Colors.deepPurple, fontSize: 20),
                  )),
              Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 10),
                  child: Text(
                    'Condition: ${weather?.current?.condition?.text}',
                    style:
                        const TextStyle(color: Colors.deepPurple, fontSize: 20),
                  )),
              Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 10),
                  child: Text(
                    'Place: ${weather?.location?.name}, ${weather?.location?.region}',
                    style:
                        const TextStyle(color: Colors.deepPurple, fontSize: 20),
                  )),
              Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 10),
                  child: Text(
                    'Date & Time: ${getDateTime(weather?.location?.localtimeEpoch)}',
                    style:
                        const TextStyle(color: Colors.deepPurple, fontSize: 20),
                  )),
              Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 50),
                  child: Text(
                    'Battery Range: $_batteryRange Km\nLast Reset: $_batteryResetTime',
                    style:
                        const TextStyle(color: Colors.deepPurple, fontSize: 20),
                  )),
              Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 10),
                  child: ElevatedButton(
                      onPressed: () {
                        resetBatteryRange();
                        showToast("Battery Reset Successful");
                        fetchBattery();
                      },
                      child: const Text('Reset Battery'))),
              Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 10),
                  child: ElevatedButton(
                      onPressed: () {
                        consumeBattery(12);
                      },
                      child: const Text('Consume 12km'))),
              Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 10),
                  child: ElevatedButton(
                      onPressed: () {
                        fetchBattery();
                      },
                      child: const Text('Get Battery'))),
              Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 10),
                  child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Track Your Carbon Credits'))),
              Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 10),
                  child: ElevatedButton(
                      onPressed: () {
                        launchUrl(Uri.parse(Uri.encodeFull(shopOurProductsAPI)),
                            mode: LaunchMode.externalApplication);
                      },
                      child: const Text('Shop Our Products'))),
              Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 10),
                  child: ElevatedButton(
                      onPressed: () {}, child: const Text('Ride History'))),
            ],
          ),

          //   Text(
          //   'City: ${weather?.location?.name}',
          //   style: const TextStyle(color: Colors.deepPurple, fontSize: 25),
          // ),]
          // Text(
          //   'City: ${weather?.location?.name}',
          //   style: const TextStyle(color: Colors.deepPurple, fontSize: 25),
          // ),
        ));
  }

  void initUI() async {
    userName = await getLocal(prefUserName);
    fetchBattery();
    if (await handleLocationPermission(context)) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      weather = await getWeather(position.latitude, position.longitude);
      setState(() {});
    }
  }

  void fetchBattery() async {
    _batteryRange = await getBatteryRange();
    _batteryResetTime = await getBatteryResetTime();
    setState(() {});
  }
}

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
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
            onTap: () => {Navigator.of(context).pop()},
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
            onTap: () => {Navigator.of(context).pop()},
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
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.of(context).pop();
              openScreen(context, const ContactUs());
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
            onTap: () {
              Navigator.of(context).pop();
              logout();
            },
          ),
        ],
      ),
    );
  }
}
