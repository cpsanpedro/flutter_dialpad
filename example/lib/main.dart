import 'package:flutter/material.dart';
import 'package:flutter_dialpad/flutter_dialpad.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: DialPad(
              enableDtmf: true,
              sizeFactorMultiplier: 0.1,
              //outputMask: "(000) 000-0000",
              backspaceButtonIconColor: Colors.red,
              buttonTextColor: Colors.white,
              dialOutputTextColor: Colors.white,
              keyPressed: (value) {
                print('$value was pressed');
              },
              makeCall: (number) {
                print(number);
              }),
        )),
      ),
    );
  }
}
