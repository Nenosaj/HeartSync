import 'package:flutter/material.dart';
import 'package:heartsync/bluetooth/bluetooth_connection.dart';
import 'package:heartsync/screens/heartratedisplay.dart';
import 'package:heartsync/screens/stressleveldisplay.dart';
import 'package:heartsync/screens/connectiondisplay.dart';
import 'package:heartsync/screens/sync.dart';
import 'package:heartsync/screens/heartsynclogo.dart';
import 'package:heartsync/screens/simulationsync.dart';
import 'package:heartsync/bluetooth/simulateddata.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool isConnected = false; // Track the Bluetooth connection status
   int heartRate = 0; // Initialize to 0, but will update with real data
  int stressLevel = 0; // Initialize to 0, but will update with real data
  String stressState = "Unknown"; // Initialize with a default state 
  bool isAnimating = false; // Control animation start/stop

  
  List<int> timeData = []; 
  List<int> stressLevelData = []; // New: Track actual stress levels over time


  late BluetoothConnection bluetoothConnection;
  late SimulatedData simulatedData;

   @override
  void initState() {
    super.initState();

    // Initialize the Simulated instance
    simulatedData = SimulatedData(
      onConnectionChangedSimulated: (connected) {
        setState(() {
            ("Connection Changed: $isConnected");
          isConnected = connected; // Update UI when connection status changes
          isAnimating = connected; // Start animation only when connected

        });
      },
      onDataSimulatedReceived: (newHeartRate, newStressLevel) {
        // ignore: avoid_print
        print("Data Received - Heart Rate: $newHeartRate, Stress Level: $newStressLevel"); // Debugging

        setState(() {
          heartRate = newHeartRate; // Update heart rate with new data
          stressLevel = newStressLevel; // Update stress level with new data

         // Add the current stress level to stressLevelData for plotting
          stressLevelData.add(newStressLevel); 
          if (stressLevelData.length > 5) {
            stressLevelData.removeAt(0); 
          }

          // Add the current minute to timeData
          timeData.add(timeData.isEmpty ? 1 : timeData.last + 1); 
          if (timeData.length > 5) {
            timeData.removeAt(0); 
          }
          updateStressState(newStressLevel); // Update stress state based on new stress 
          
      
        });
      },
    );

    bluetoothConnection = BluetoothConnection(
      onConnectionChanged: (connected) {
        setState(() {
            ("Connection Changed: $isConnected");

          isConnected = connected; // Update UI when connection status changes
          isAnimating = connected; // Start animation only when connected

        });
      },
      onDataReceived: (newHeartRate, newStressLevel) {
        // ignore: avoid_print
        print("Data Received - Heart Rate: $newHeartRate, Stress Level: $newStressLevel"); // Debugging

        setState(() {
          heartRate = newHeartRate; // Update heart rate with new data
          stressLevel = newStressLevel; // Update stress level with new data

         // Add the current stress level to stressLevelData for plotting
          stressLevelData.add(newStressLevel); 
          if (stressLevelData.length > 5) {
            stressLevelData.removeAt(0); 
          }

          // Add the current minute to timeData
          timeData.add(timeData.isEmpty ? 1 : timeData.last + 1); 
          if (timeData.length > 5) {
            timeData.removeAt(0); 
          }
          updateStressState(newStressLevel); // Update stress state based on new stress 
          
      
        });
      },
    );


  }





  void updateStressState(int newStressLevel) {
    if (newStressLevel >= 2 && newStressLevel <= 15) {
      stressState = "Highly Tense";
    } else if (newStressLevel >= 16 && newStressLevel <= 25) {
      stressState = "Slightly Tense";
    } else if (newStressLevel >= 26 && newStressLevel <= 52) {
      stressState = "Mildly Calm";
    } else if (newStressLevel >= 53 && newStressLevel <= 60) {
      stressState = "Quietly Relaxed";
    } else if (newStressLevel > 60) {
      stressState = "Deeply Relaxed";
    }
  }
  
   @override
  /*void dispose() {
    // Clean up the Bluetooth connection resources when the screen is disposed
    bluetoothConnection.dispose();
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        scrolledUnderElevation: 0, // Prevent shadow on scroll

        leading: const Padding(
            padding: EdgeInsets.all(8.0),
            child: HeartSyncIcon(), // Use the heart icon widget here

        ),
        title: const Text('HeartSync', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              child: IconButton(
                icon:  const Icon(Icons.person), // Default profile icon
                onPressed: () {
                  // Handle profile icon click
                  // ignore: avoid_print
                  print('Profile icon clicked');
                },
              ),
          ),
      )
      ],
      ),
      body: 
      SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const SizedBox(height: 20),

            HeartDisplay(heartRate: heartRate, isAnimating: isAnimating),
            const SizedBox(height: 20),

            StressLevelDisplay(stressLevel: stressLevel, stressState: stressState, timeData: timeData, stressLevelData: stressLevelData),
            const SizedBox(height: 20),

            ConnectionStatus(isConnected: isConnected),
            const SizedBox(height: 20),


           SimulationSync(onPressed: () {

                  simulatedData.toggleSimulatedConnection();
            }),

            const SizedBox(height: 10),

           Sync(
              isConnected: isConnected, // Pass the connection status
                onPressed: () {
                    bluetoothConnection.toggleBluetoothConnection(context: context);
                  
                },
              ),



            const SizedBox(height: 20), // Adjust the height to add space below the button


          ],
        ),
      ),
    ));
  }
}
