import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

import 'BluetoothStateManager.dart';

class ConnectionScreen extends StatefulWidget {
  final BluetoothDevice device;

  const ConnectionScreen({Key key, @required this.device}) : super(key: key);

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final ble = Get.put(Bluetooth());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          StreamBuilder<BluetoothDeviceState>(
            stream: widget.device.state,
            builder: (context, snap) {
              final data = snap.data;
              if (snap.hasData) {
                return Text(snap.data.toString());
              } else {
                return Text(' not connected');
              }
            },
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder<List<BluetoothService>>(
          future: widget.device.discoverServices(),
          builder: (context, service) {
            if (service.hasData) {
              return ListView.builder(
                  itemCount: service.data.length,
                  itemBuilder: (context, i) {
                    return Container(
                      height: 100,
                      child: ListView.builder(
                          itemCount: service.data[i].characteristics.length,
                          itemBuilder: (context, l) {
                            final c =
                                service.data[i].characteristics[l].isNotifying;
                            return ListTile(
                              title: Text(service
                                  .data[i].characteristics[l].uuid
                                  .toString()),
                              subtitle: Row(
                                children: [
                                  StreamBuilder(
                                      stream: service
                                          .data[i].characteristics[l].value,
                                      builder: (context, d) {
                                        if (d.hasData) {
                                          return Text(d.data.toString());
                                        } else {
                                          return Text(' reading..');
                                        }
                                      }),
                                  TextButton(
                                    onPressed: () async {
                                      print(c.toString());

                                      await service.data[i].characteristics[l]
                                          .setNotifyValue(true);
                                      final t = await service
                                          .data[i].characteristics[l]
                                          .read();
                                      print(t.toString());
                                    },
                                    child: Text('notify'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final t = await service
                                          .data[i].characteristics[l]
                                          .read();
                                      print(t.toString());
                                    },
                                    child: Text('read'),
                                  ),
                                ],
                              ),
                              trailing: TextButton(
                                onPressed: () async {
                                  final sp = getRandomBytes();
                                  print(sp.toString());
                                  await service.data[i].characteristics[l]
                                      .write(sp, withoutResponse: true);
                                  final t = await service
                                      .data[i].characteristics[l]
                                      .read();
                                  print(t.toString());
                                },
                                child: Text('write'),
                              ),
                            );
                          }),
                    );
                  });
            } else {
              return Text('loading');
            }
          },
        ),
      ),
    );
  }

  List<int> getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }
}
