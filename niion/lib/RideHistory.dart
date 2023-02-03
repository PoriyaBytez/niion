import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niion/pojo/RidePojo.dart';
import 'package:niion/RidesDatabase.dart';

import 'Constants.dart';
import 'Globals.dart';

class RideHistory extends StatefulWidget {
  const RideHistory({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RideHistoryState();
  }
}

class _RideHistoryState extends State<RideHistory> {
  List<RidePojo> rides = [];

  @override
  void initState() {
    fetchRides();
    super.initState();
  }

  Future fetchRides() async {
    rides = await RidesDatabase.instance.getAllRides();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget cardView(RidePojo ridePojo) => Card(
        margin: const EdgeInsets.all(10.0),
        child: Column(children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Carbon Savings: ${ridePojo.carbonSavings.toStringAsFixed(2)} Kg${ridePojo.carbonSavings > 1 ? 's' : ''}',
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Date & Time.: ${getDateTime(ridePojo.createdTime)}',
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dur: ${getTimeFromSeconds(ridePojo.duration!)}',
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Dist.: ${shrinkDecimal(ridePojo.distance, 2)} Km',
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Other Data: To Add',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Avg Speed: ${shrinkDecimal(ridePojo.avgSpeed, 2)} Km/Hr',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            )
          ])
        ]));

    Widget buildRidesHistory() => ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: rides.length,
          itemBuilder: (context, position) {
            return cardView(rides[position]);
          },
        );

    return Scaffold(
        appBar: AppBar(
          title: const Text(appName),
        ),
        body: Container(
            color: Colors.white, child: Center(child: buildRidesHistory())));
  }
}
