import 'dart:async';

class SimulatedData {
  bool isConnected = false;
  Timer? dataTimer;

  final Function(bool) onConnectionChangedSimulated;
  final Function(int, int) onDataSimulatedReceived;

  SimulatedData({
    required this.onConnectionChangedSimulated,
    required this.onDataSimulatedReceived,
  });

  
    void toggleSimulatedConnection() {

      isConnected = !isConnected;
      onConnectionChangedSimulated(isConnected);

    if (isConnected) {
      startSendingSimulatedData();
    } else {
      stopSendingData();
    }
  }

  
  void startSendingSimulatedData() {
    stopSendingData(); // Stop any previous timer
    dataTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final simulatedData = generateSimulatedData(timer.tick);
      // ignore: avoid_print
      print("Simulated Data - Heart Rate: ${simulatedData['heartRate']}, Stress Level: ${simulatedData['stressLevel']}"); // Debugging

      onDataSimulatedReceived(simulatedData['heartRate']!, simulatedData['stressLevel']!); // Notify the UI
    });
  }

  
  void stopSendingData() {
    dataTimer?.cancel();
  }

   Map<String, int> generateSimulatedData(int tick) {
    int simulatedHeartRate = 60 + tick % 40; // Simulate heart rate between 60 and 100
    int simulatedStressLevel = 2 + (tick * 5) % 60; // Simulate stress level between 2 and 60
    return {
      'heartRate': simulatedHeartRate,
      'stressLevel': simulatedStressLevel,
    };
  }


}