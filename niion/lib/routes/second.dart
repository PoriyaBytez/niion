import 'package:flutter/material.dart';
import 'package:niion/routes/main.dart';
import 'package:niion/utils/Globals.dart';

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    print(getLocal("key3"));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
            closeScreen(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
