import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class Bluetooth extends GetxController {
  FlutterBlue blue = FlutterBlue.instance;
  BluetoothDevice d;
  var connectedDevices = List<BluetoothDevice>().obs;
  var scanResults = Set<ScanResult>().obs;
  var bleState = BluetoothState.off.obs;
  var isScan = false.obs;
  @override
  void onInit() async {
    super.onInit();
    final perb = await Permission.bluetooth.status.isGranted;
    final perL = await Permission.location.status.isGranted;
    if (perb && perL) {
      getConnectedDevices();
      // scannedDevices();
      isScanning();
    } else {
      await Permission.bluetooth.request();
      await Permission.location.request();
    }
  }

  getConnectedDevices() async {
    final connectedDevice = await blue.connectedDevices;
    connectedDevices.value = connectedDevice;
    return connectedDevice;
  }

  // scannedDevices() {
  //   blue.scanResults.listen((event) {
  //     print(event.toString());
  //     scanResults.value = event;
  //   });
  // }

  searchDevices() {
    blue.scanResults.listen((event) {
      print('------------------');
      print(event.toString());
      event.forEach((element) {
        scanResults.add(element);
      });
    });
    blue.startScan(timeout: Duration(seconds: 10)).then((value) {});
  }

  isScanning() {
    blue.isScanning.listen((event) {
      print(event.toString());
      isScan.value = event;
    });
  }

  state() {
    blue.state.listen((event) {
      bleState.value = event;
    });
  }
}
