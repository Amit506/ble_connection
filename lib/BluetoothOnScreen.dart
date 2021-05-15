import 'package:ble_connection/BluetoothStateManager.dart';
import 'package:ble_connection/ConnectionScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

class BluetoothOnScreen extends StatefulWidget {
  @override
  _BluetoothOnScreenState createState() => _BluetoothOnScreenState();
}

class _BluetoothOnScreenState extends State<BluetoothOnScreen> {
  final ble = Get.put(Bluetooth());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('connected devices'),
        actions: [
          IconButton(
              icon: Icon(Icons.refresh_outlined),
              onPressed: () {
                ble.getConnectedDevices();
              }),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GetX<Bluetooth>(
          builder: (ble) {
            return ListView.builder(
                itemCount: ble.connectedDevices.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    onTap: () {
                      Get.to(() => ConnectionScreen(
                            device: ble.connectedDevices[i],
                          ));
                    },
                    title: Text(ble.connectedDevices[i].name == ''
                        ? 'unknown'
                        : ble.connectedDevices[i].name),
                    subtitle: Text(ble.connectedDevices[i].id.toString()),
                    trailing: StreamBuilder<BluetoothDeviceState>(
                      stream: ble.connectedDevices[i].state,
                      builder: (context, snap) {
                        final data = snap.data;
                        if (snap.hasData) {
                          return Text(snap.data.toString());
                        } else {
                          return Text(' not connected');
                        }
                      },
                    ),
                  );
                });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => Searchpage()),
        child: Icon(Icons.search_rounded),
      ),
    );
  }
}

class Searchpage extends StatefulWidget {
  @override
  _SearchpageState createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  final ble = Get.find<Bluetooth>();
  @override
  void initState() {
    super.initState();
    ble.searchDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GetX<Bluetooth>(builder: (ble) {
          if (ble.isScan.value == true) {
            return Text('Scanning in progress');
          } else {
            return Text('Scanning is finished');
          }
        }),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GetX<Bluetooth>(builder: (ble) {
          return ListView.builder(
            itemCount: ble.scanResults.length,
            itemBuilder: (context, i) {
              return ListTile(
                title: Text(ble.scanResults.toList()[i].device.name == ''
                    ? 'unknown'
                    : ble.scanResults.toList()[i].device.name),
                subtitle:
                    Text(ble.scanResults.toList()[i].device.id.toString()),
                onTap: () {
                  ble.scanResults
                      .toList()[i]
                      .device
                      .connect(
                          autoConnect: false, timeout: Duration(seconds: 10))
                      .then((value) {
                    ble.getConnectedDevices();
                    Get.to(BluetoothOnScreen());
                  }).timeout(Duration(seconds: 10),
                          onTimeout: () => showSnackBar('time out', context));
                },
              );
            },
          );
        }),
      ),
    );
  }

  showSnackBar(msg, context) {
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: new Text(
          msg,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        duration: new Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        elevation: 3.0,
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
