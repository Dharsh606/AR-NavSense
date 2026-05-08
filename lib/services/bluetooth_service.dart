import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  Future<void> requestPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  Stream<List<ScanResult>> scan({Duration timeout = const Duration(seconds: 8)}) async* {
    await requestPermissions();
    await FlutterBluePlus.stopScan();
    await FlutterBluePlus.startScan(timeout: timeout);
    yield* FlutterBluePlus.scanResults;
  }

  Future<void> stopScan() => FlutterBluePlus.stopScan();

  Future<void> connect(BluetoothDevice device) async {
    await requestPermissions();
    await device.connect(timeout: const Duration(seconds: 12), autoConnect: false);
  }

  Future<void> disconnect(BluetoothDevice device) => device.disconnect();
}
