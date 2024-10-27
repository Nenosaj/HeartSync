import 'dart:async';
// ignore: unused_import
import 'package:flutter_blue_plus/flutter_blue_plus.dart';


class BluetoothConnection {
  bool isConnected = false;
  Timer? dataTimer;
  final Function(bool) onConnectionChanged;
  final Function(int, int) onDataReceived;

  BluetoothConnection({
    required this.onConnectionChanged,
    required this.onDataReceived,
  });

  // Toggle the Bluetooth connection
  void toggleBluetoothConnection() {
    isConnected = !isConnected;
    onConnectionChanged(isConnected); // Notify the parent widget about the connection status

    if (isConnected) {
      startSendingSimulatedData(); // Start sending simulated data
    } else {
      stopSendingData(); // Stop sending data when disconnected
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


   // ! Toggle the Bluetooth connection tinuod nani
  /*void toggleBluetoothConnection() async {
    if (isConnected) {
      disconnectFromDevice();
    } else {
      // Start scanning and connect to the device
      connectToDevice();
    }
  }*/

 // Start scanning for Bluetooth devices
 

// !Start scanning for Bluetooth devices bag-ohon gyapon
 /* void connectToDevice() async {
    // Start scanning for nearby devices
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // Listen for scan results
   FlutterBluePlus.scanResults.listen((results) async {
      // Iterate through scan results and find your specific device
      for (ScanResult result in results) {
        // For now, we'll connect to the first device we find
        connectedDevice = result.device;

        // Stop scanning once a device is found
        FlutterBluePlus.stopScan();

        // Connect to the device
        await connectedDevice!.connect();
        print('Connected to ${connectedDevice!.name}');

        // Discover services and characteristics
        discoverServicesAndCharacteristics();
        break;
      }
    });
  }*/

  // !Discover services and characteristics of the connected device pagtuon og plus 
  /*Future<void> discoverServicesAndCharacteristics() async {
    if (connectedDevice != null) {
      List<BluetoothService> services = await connectedDevice!.discoverServices();

      for (BluetoothService service in services) {
        // Loop through all the characteristics of the service
        for (BluetoothCharacteristic char in service.characteristics) {
          // We'll use the first characteristic we find for data transfer
          characteristic = char;

          // Subscribe to notifications for this characteristic (if applicable)
          if (characteristic!.properties.notify) {
            await characteristic!.setNotifyValue(true);
            characteristic!.value.listen((value) {
              // Simulate data processing from Bluetooth characteristic (real data in your case)
              int heartRate = value.isNotEmpty ? value[0] : 0; // Assuming the first byte contains heart rate
              int stressLevel = value.length > 1 ? value[1] : 0; // Second byte for stress level
              onDataReceived(heartRate, stressLevel); // Send data to UI
            });
          }
        }
      }

      // Change the connection state and notify UI
      isConnected = true;
      onConnectionChanged(isConnected);
    }
  }*/
 // !Disconnect from the connected Bluetooth device i change pa nato ni
  /*void disconnectFromDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      print('Disconnected from ${connectedDevice!.name}');
      isConnected = false;
      onConnectionChanged(isConnected);
    }
  }*/
}




