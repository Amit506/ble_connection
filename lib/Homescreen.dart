import 'package:ble_connection/BluetoothOnScreen.dart';
import 'package:ble_connection/bluetoothOffScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothHomeScreen extends StatefulWidget {
  @override
  _BluetoothHomeScreenState createState() => _BluetoothHomeScreenState();
}

class _BluetoothHomeScreenState extends State<BluetoothHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FlutterBlue.instance.state,
        builder: (context, snap) {
          final data = snap.data;
          if (data == BluetoothState.on) {
            return BluetoothOnScreen();
          }
          return BluetoothOffScreen();
        },
      ),
    );
  }
}
