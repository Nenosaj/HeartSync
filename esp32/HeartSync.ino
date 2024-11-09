#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#define SERVICE_UUID           "12345678-1234-5678-1234-56789abcdef0"
#define CHARACTERISTIC_UUID    "12345678-1234-5678-1234-56789abcdef3"  // Combined Characteristic UUID

BLECharacteristic combinedCharacteristic(CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY);

// Global variables
BLEServer *pServer = nullptr;
BLEAdvertising *pAdvertising = nullptr;
bool deviceConnected = false;
bool advertisingStarted = false;

unsigned long lastConnectionTime = 0;
const unsigned long connectionTimeout = 10000; // 10 seconds

// Custom server callback to manage connection events
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
    advertisingStarted = false; // Reset flag upon connection
    lastConnectionTime = millis(); // Reset connection time

    Serial.println("Device connected.");
  }

  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
    Serial.println("Device disconnected, restarting advertising...");
    delay(100);  // Small delay to allow BLE stack to reset
    BLEDevice::startAdvertising(); // Restart advertising on disconnect
    advertisingStarted = true;     // Update advertising status
  }
};

void setup() {
  Serial.begin(115200);
  BLEDevice::init("ESP32-HeartSync");

  // Set MTU size, but consider lowering if stability issues persist
  BLEDevice::setMTU(247);  // Try 247 for compatibility; use 512 if required

  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks()); // Set connection callback

  BLEService *pService = pServer->createService(SERVICE_UUID);
  pService->addCharacteristic(&combinedCharacteristic);
  pService->start();

  pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // Advertise settings
  pAdvertising->setMinPreferred(0x12);  
  BLEDevice::startAdvertising();
  advertisingStarted = true;  // Set flag to indicate advertising has started

  Serial.println("BLE advertising started...");
}

void loop() {
  int heartRate = random(60, 100);       // Simulated heart rate
  int stressLevel = random(2, 70);       // Simulated stress level

  // Combine heart rate and stress level into a single payload (e.g., two bytes)
  uint8_t combinedData[2];
  combinedData[0] = heartRate;           // First byte for heart rate
  combinedData[1] = stressLevel;         // Second byte for stress level

  combinedCharacteristic.setValue(combinedData, 2);  // Set combined data

  if (deviceConnected) {
        lastConnectionTime = millis();
    combinedCharacteristic.notify(); // Notify connected devices
    Serial.print("Notified - Heart Rate: ");
    Serial.print(heartRate);
    Serial.print(" | Stress Level: ");
    Serial.println(stressLevel);
  } else if ((millis() - lastConnectionTime) > connectionTimeout && !advertisingStarted) {
        Serial.println("Re-advertising after connection timeout...");

    Serial.println("Re-advertising after disconnect...");
    BLEDevice::startAdvertising();
    advertisingStarted = true; // Update advertisingStarted flag
  } else {
    Serial.println("No device connected.");
  }

  delay(3000);  // Update every 3 seconds
}
