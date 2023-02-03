import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';

import 'Constants.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TestState();
  }
}

class _TestState extends State<Test> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var myOutline = BoxDecoration(
      border: Border.all(width: 1, color: Colors.white),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(appName),
      ),
      body: Container(
        color: Colors.black,
        height: double.infinity,
        child: FractionallySizedBox(
          widthFactor: 1,
          alignment: Alignment.topCenter,
          heightFactor: 0.15,
          child: GradientCard(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            gradient: Gradients.taitanum,
            elevation: 8,
            shadowColor: Gradients.taitanum.colors.last.withOpacity(0.25),
            child: Container(
              decoration: myOutline,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                child: Image.network(
                  'https://cdn.weatherapi.com/weather/64x64/day/113.png',
                  // width: 100,
                  height: 100,
                  // fit: BoxFit.fill
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
