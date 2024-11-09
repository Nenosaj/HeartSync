import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class BluetoothConnection {
  bool isConnected = false;
  bool isSync = false;
  Timer? dataTimer;

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;
  StreamSubscription<BluetoothConnectionState>? connectionSubscription;

  final Function(bool) onConnectionChanged;
  final Function(int, int) onDataReceived;

  BluetoothConnection({
    required this.onConnectionChanged,
    required this.onDataReceived,
  });

  // Check if Bluetooth is on, and request necessary permissions
  Future<void> checkBluetoothAndPermissions(BuildContext context) async {
    FlutterBluePlus.adapterState.first.then((state) {
      if (state != BluetoothAdapterState.on) {
        // ignore: avoid_print
        print("Bluetooth is not enabled. Prompting user to enable Bluetooth.");
        FlutterBluePlus.turnOn();
      } else {
        // ignore: use_build_context_synchronously
        _checkPermissionsAndConnect(context);
      }
    });
  }

  // Check for permissions (Bluetooth, location)
  Future<void> _checkPermissionsAndConnect(BuildContext context) async {
    if (await _requestPermissions()) {
      // ignore: use_build_context_synchronously
      _scanForDevices(context);
    } else {
      // ignore: avoid_print
      print('Permissions denied');
    }
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  // Scanning for available devices and displaying them in a list
  Future<void> _scanForDevices(BuildContext context) async {
    List<BluetoothDevice> scannedDevices = [];
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    await FlutterBluePlus.isScanning.where((scanning) => scanning == false).first;


    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!scannedDevices.any((device) => device.remoteId == result.device.remoteId)) {
          scannedDevices.add(result.device);
        }
      }
    }, onError: (error) {
      // ignore: avoid_print
      print("Scan error: $error");
    });


   showModalBottomSheet(
    // ignore: use_build_context_synchronously
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose a Bluetooth Device',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,  // Removes default padding around the ListView
                shrinkWrap: true,
                itemCount: scannedDevices.length,
                itemBuilder: (BuildContext context, int index) {
                  BluetoothDevice device = scannedDevices[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4.0),  // Adjusts spacing between items
                    title: Text(
                      device.platformName.isNotEmpty ? device.platformName : device.remoteId.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      connectToDevice(device);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
  }

  // Connect to a specific device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await FlutterBluePlus.stopScan();
      // ignore: avoid_print
      print('Connecting to device: ${device.remoteId}');
      await device.connect(autoConnect: false);
      connectedDevice = device;
      isConnected = true;
      onConnectionChanged(isConnected);
      // ignore: avoid_print
      print('Connected to device: ${device.remoteId}');
      _monitorConnectionState(device);
      await _discoverServicesAndCharacteristics();
    } catch (e) {
      // ignore: avoid_print
      print('Error connecting to device: $e');
      isConnected = false;
      onConnectionChanged(isConnected);
    }
  }

  Future<void> _discoverServicesAndCharacteristics() async {
    if (connectedDevice == null) {
      // ignore: avoid_print
      print('Device disconnected before service discovery.');
      isConnected = false;
      onConnectionChanged(isConnected);
      return;
    }

    List<BluetoothService> services = await connectedDevice!.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == "12345678-1234-5678-1234-56789abcdef0") {
        // ignore: avoid_print
        print("Found HeartSync Service");
        for (BluetoothCharacteristic char in service.characteristics) {
          if (char.uuid.toString() == "12345678-1234-5678-1234-56789abcdef3") {
            // ignore: avoid_print
            print("Found Combined Characteristic");
            await char.setNotifyValue(true);
            char.onValueReceived.listen((value) {
              int heartRate = value.isNotEmpty ? value[0] : 0;
              int stressLevel = value.length > 1 ? value[1] : 0;
              // ignore: avoid_print
              print("Heart Rate: $heartRate, Stress Level: $stressLevel");
              onDataReceived(heartRate, stressLevel);
            });
            characteristic = char;
          }
        }
      }
    }
  }

  // Disconnect from the connected device
  Future<void> disconnectFromDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      isConnected = false;
      onConnectionChanged(isConnected);
      connectedDevice = null;
      characteristic = null;
      connectionSubscription?.cancel();
    } else {
      // ignore: avoid_print
      print('No device is connected.');
    }
  }

  void toggleBluetoothConnection({required BuildContext context}) {
    if (!isConnected) {
      checkBluetoothAndPermissions(context);
    } else {
      disconnectFromDevice();
    }
  }

  void _monitorConnectionState(BluetoothDevice device) {
    connectionSubscription = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.connected) {
        // ignore: avoid_print
        print('Device is connected.');
      } else if (state == BluetoothConnectionState.disconnected) {
        // ignore: avoid_print
        print('Device is disconnected.');
        isConnected = false;
        onConnectionChanged(isConnected);
        connectedDevice = null;
        characteristic = null;
      }
    });
  }
}
