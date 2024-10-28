import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';



class BluetoothConnection {
  bool isConnected = false;
  Timer? dataTimer;

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;

  final Function(bool) onConnectionChanged;
  final Function(int, int) onDataReceived;

  BluetoothConnection({
    required this.onConnectionChanged,
    required this.onDataReceived,
  });

  // Toggle the Bluetooth connection
  void toggleBluetoothConnection({required BuildContext context, bool useSimulated = true}) {

    isConnected = !isConnected;
    onConnectionChanged(isConnected);

    if (useSimulated) {
      _toggleSimulatedConnection();
    } else {
      _checkBluetoothAndPermissions(context);
    }
  }

    void _toggleSimulatedConnection() {
 
    if (isConnected) {
      startSendingSimulatedData();
    } else {
      stopSendingData();
    }
  }
  

     // Check if Bluetooth is on, and request necessary permissions
  Future<void> _checkBluetoothAndPermissions(BuildContext context) async {
    // Check if Bluetooth is on
   FlutterBluePlus.adapterState.first.then((state) {
    if (state != BluetoothAdapterState.on) {
      // ignore: avoid_print
      print("Bluetooth is not enabled. Prompting user to enable Bluetooth.");
      FlutterBluePlus.turnOn();  // This opens Bluetooth settings on Android
      return;
    } else {
      // If Bluetooth is on, check permissions
      _checkPermissionsAndConnect(context);
    }
  });
  }

  // Check for permissions (Bluetooth, location)
  Future<void> _checkPermissionsAndConnect(BuildContext context) async {
    if (await _requestPermissions()) {
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
      Permission.locationWhenInUse,  // Required for BLE on some devices
    ].request();
    
    bool allGranted = statuses.values.every((status) => status.isGranted);
    return allGranted;

    
  }


// Scanning for available devices and displaying them in a list
  Future<void> _scanForDevices(BuildContext context) async {
    List<BluetoothDevice> scannedDevices = [];

    // Start scanning for devices
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // Listen for scan results
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!scannedDevices.contains(result.device)) {
          scannedDevices.add(result.device);  // Add unique devices to the list
        }
      }
    });

    // Stop scanning after the timeout
    await FlutterBluePlus.isScanning.where((scanning) => scanning == false).first;

    // Show the list of scanned devices to the user
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose a Bluetooth Device'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: scannedDevices.length,
              itemBuilder: (BuildContext context, int index) {
                BluetoothDevice device = scannedDevices[index];
                return ListTile(
                  title: Text(device.remoteId.toString()), // Show device name or ID
                  onTap: () {
                    Navigator.pop(context); // Close the dialog on selection
                    connectToDevice(device); // Connect to the selected device
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

   // Connect to a specific device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await FlutterBluePlus.stopScan(); // Stop scanning once a device is chosen
      // ignore: avoid_print
      print('Connecting to device: ${device.remoteId}');
      await device.connect();
      connectedDevice = device;
      isConnected = true;
      onConnectionChanged(isConnected);
      // ignore: avoid_print
      print('Connected to device: ${device.remoteId}');
      discoverServicesAndCharacteristics(); // Discover services after connecting
    } catch (e) {
      // ignore: avoid_print
      print('Error connecting to device: $e');
    }
  }

   // Discover services and characteristics from the connected device
   void discoverServicesAndCharacteristics() async {
  if (connectedDevice == null) return;

  // ignore: avoid_print
  print("Discovering services...");
  List<BluetoothService> services = await connectedDevice!.discoverServices();
  
  for (BluetoothService service in services) {
    // ignore: avoid_print
    print('Service: ${service.uuid}');
    
    // Loop through characteristics of the service
    for (BluetoothCharacteristic char in service.characteristics) {
      // ignore: avoid_print
      print('Characteristic: ${char.uuid}');
      
      // No need to process characteristic data, just display the available ones
      // Connect successfully and check if this characteristic has read or notify properties
      if (char.properties.notify) {
        await char.setNotifyValue(true);  // Enable notifications
        // ignore: avoid_print
        print("Subscribed to notifications for characteristic: ${char.uuid}");
      }
      if (char.properties.read) {
        var value = await char.read();  // Read the characteristic value
        // ignore: avoid_print
        print('Read characteristic: ${char.uuid}, value: $value');
      }
    }
  }
}


  /*  void discoverServicesAndCharacteristics() async {
    if (connectedDevice == null) return;

    List<BluetoothService> services = await connectedDevice!.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic char in service.characteristics) {
        characteristic = char;
        if (characteristic!.properties.notify) {
          await characteristic!.setNotifyValue(true);
          characteristic!.onValueReceived.listen((value) {
            int heartRate = value.isNotEmpty ? value[0] : 0;
            int stressLevel = value.length > 1 ? value[1] : 0;
            onDataReceived(heartRate, stressLevel);
          });
        }
      }
    }
  }
*/ // ! mao ni sa tinuod... kung maka test na ugma i uncomment ni


  // Disconnect from the connected device
  void disconnectFromDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      // ignore: avoid_print
      print('Disconnected from ${connectedDevice!.remoteId}');
      isConnected = false;
      onConnectionChanged(isConnected);
    }
  }



  // Start sending simulated data at regular intervals
  void startSendingSimulatedData() {
    stopSendingData(); // Stop any previous timer
    dataTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final simulatedData = generateSimulatedData(timer.tick);
      // ignore: avoid_print
      print("Simulated Data - Heart Rate: ${simulatedData['heartRate']}, Stress Level: ${simulatedData['stressLevel']}"); // Debugging

      onDataReceived(simulatedData['heartRate']!, simulatedData['stressLevel']!); // Notify the UI
    });
  }

  // Stop the simulated data stream
  void stopSendingData() {
    dataTimer?.cancel();
  }

  // Generate simulated heart rate and stress level
  Map<String, int> generateSimulatedData(int tick) {
    int simulatedHeartRate = 60 + tick % 40; // Simulate heart rate between 60 and 100
    int simulatedStressLevel = 2 + (tick * 5) % 60; // Simulate stress level between 2 and 60
    return {
      'heartRate': simulatedHeartRate,
      'stressLevel': simulatedStressLevel,
    };
  }

  Map <String, int> realData() {
    int realHeartRate = 0;
    int realStressLevel = 0;
    return {
      'hearRate': realHeartRate,
      'stressLevel':realStressLevel,
    };

  }

  // Clean up resources (call this when you don't need the class anymore)
  void dispose() {
    dataTimer?.cancel();
  }
}




