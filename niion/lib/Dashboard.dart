import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const SideDrawer(),
        appBar: AppBar(
          title: const Text(appName),
        ),
        body: SingleChildScrollView(
            child: Stack(children: <Widget>[
          Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 200,
                  width: 165,
                  // color: Colors.red,
                  child: GradientCard(
                    gradient: Gradients.taitanum,
                    elevation: 8,
                    shadowColor:
                        Gradients.taitanum.colors.last.withOpacity(0.25),
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: SizedBox(
                      height: 10,
                      width: 10,
                      child: Image.network(
                          'https:${weather?.current?.condition?.icon}',
                          // width: 150,
                          // height: 75,
                          fit: BoxFit.fill),
                    ),
                  ),
                ),
                // Container(
                //   height: double.infinity,
                //   alignment: Alignment.center, // This is needed
                //   child: Image.network(
                //     'https:${weather?.current?.condition?.icon}',
                //     fit: BoxFit.contain,
                //     width: 300,
                //   ),
                // ),
                Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 10),
                    child: Text(
                      'Temperature: ${weather?.current?.tempC}° C',
                      style: const TextStyle(
                          color: Colors.deepPurple, fontSize: 20),
                    )),
                Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 10),
                    child: Text(
                      'Condition: ${weather?.current?.condition?.text}',
                      style: const TextStyle(
                          color: Colors.deepPurple, fontSize: 20),
                    )),
                Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 10),
                    child: Text(
                      'Place: ${weather?.location?.name}, ${weather?.location?.region}',
                      style: const TextStyle(
                          color: Colors.deepPurple, fontSize: 20),
                    )),
                Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 10),
                    child: Text(
                      'Date & Time: ${getDateTime(weather?.location?.localtimeEpoch)}',
                      style: const TextStyle(
                          color: Colors.deepPurple, fontSize: 20),
                    )),
                Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 30),
                    child: Text(
                      'Battery Range: $_batteryRange Km\nLast Reset: $_batteryResetTime',
                      style: const TextStyle(
                          color: Colors.deepPurple, fontSize: 20),
                    )),
                Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 0),
                    child: ElevatedButton(
                        onPressed: () async {
                          await resetBatteryRange();
                          showToast("Battery Reset Successful");
                          await fetchBattery();
                          // openScreen(context, MyApp());
                          // openScreen(context, const HomePageWidget1());
                        },
                        child: const Text('Reset Battery'))),

                // Padding(
                //     padding: const EdgeInsets.only(left: 10.0, top: 0),
                //     child: ElevatedButton(
                //         onPressed: () async {
                //           await consumeBattery(12);
                //         },
                //         child: const Text('Consume 12km'))),
                // Padding(
                //     padding: const EdgeInsets.only(left: 10.0, top: 0),
                //     child: ElevatedButton(
                //         onPressed: () async {
                //           // List<LatLng>? list = <LatLng>[];
                //           // list.add(const LatLng(0.0, 0.0));
                //           // await RidesDatabase.instance.createRide(RidePojo(
                //           //     duration: 347,
                //           //     distance: 7.49,
                //           //     avgSpeed: 9.48,
                //           //     polylines: list,
                //           //     createdTime: 10230132112));
                //           // await fetchBattery();
                //         },
                //         child: const Text('Get Battery'))),
                Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 0),
                    child: ElevatedButton(
                        onPressed: () async {
                          showAlert(context, true, "Your Total Carbon Savings",
                              "${(await RidesDatabase.instance.getTotalCarbonSavings()).toStringAsFixed(2)} Kgs");
                        },
                        child: const Text('Track Your Carbon Credits'))),
                Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 0),
                    child: ElevatedButton(
                        onPressed: () {
                          launchUrl(
                              Uri.parse(Uri.encodeFull(shopOurProductsAPI)),
                              mode: LaunchMode.externalApplication);
                        },
                        child: const Text('Shop Our Products'))),
                Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 0),
                    child: ElevatedButton(
                        onPressed: () {
                          openScreen(context, const RideHistory());
                        },
                        child: const Text('Ride History'))),
                Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 0),
                    child: ElevatedButton(
                        onPressed: () async {
                          if (!await handleLocationPermission(context)) {
                          } else {
                            LatLng latLng = await getLoc();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MapRoute(pos: latLng)),
                            ).then((value) => fetchBattery());
                          }
                        },
                        child: const Text('Start Ride'))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 0),
                        child: ElevatedButton(
                            onPressed: () {
                              launchUrl(
                                  Uri.parse(Uri.encodeFull(facebookPage)),
                                  mode: LaunchMode.externalApplication);}, child: const Text('Facebook'))),
                    Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 0),
                        child: ElevatedButton(
                            onPressed: () {
                              launchUrl(
                                  Uri.parse(Uri.encodeFull(instaPage)),
                                  mode: LaunchMode.externalApplication);
                            }, child: const Text('Instagram'))),
                    Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 0),
                        child: ElevatedButton(
                            onPressed: () {
                              launchUrl(
                                  Uri.parse(Uri.encodeFull(twitterPage)),
                                  mode: LaunchMode.externalApplication);
                            }, child: const Text('Twitter'))),
                  ],
                )
              ],
            ),
          )
        ])));
  }
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
