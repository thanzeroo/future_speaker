/// Song data model matching the ESP32 playlist
class Song {
  final int id;
  final String title;
  final String artist;
  final List<Note> notes;
  final Duration duration;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.notes,
    required this.duration,
  });
}

/// A single note with frequency and duration
class Note {
  final int frequency;
  final int durationMs;

  const Note(this.frequency, this.durationMs);
}

/// Connection state for ESP32
enum ConnectionState {
  connected,
  connecting,
  disconnected,
}

/// Sensor reading from HC-SR04
class SensorReading {
  final double distanceCm;
  final bool objectDetected;
  final String sensorType;
  final DateTime timestamp;

  const SensorReading({
    required this.distanceCm,
    required this.objectDetected,
    this.sensorType = 'HC-SR04',
    required this.timestamp,
  });
}

/// Device settings model
class DeviceSettings {
  String deviceName;
  bool sensorEnabled;
  int sensitivity; // 1=Rendah, 2=Sedang, 3=Tinggi
  int detectionDistance; // 2-20 cm
  bool gestureSound;
  String wifiName;
  String espIp;
  bool wifiConnected;
  bool bluetoothReady;

  DeviceSettings({
    this.deviceName = 'Future Speaker',
    this.sensorEnabled = true,
    this.sensitivity = 3,
    this.detectionDistance = 15,
    this.gestureSound = true,
    this.wifiName = 'FutureSpeaker',
    this.espIp = '192.168.4.1',
    this.wifiConnected = true,
    this.bluetoothReady = true,
  });

  DeviceSettings copyWith({
    String? deviceName,
    bool? sensorEnabled,
    int? sensitivity,
    int? detectionDistance,
    bool? gestureSound,
    String? wifiName,
    String? espIp,
    bool? wifiConnected,
    bool? bluetoothReady,
  }) {
    return DeviceSettings(
      deviceName: deviceName ?? this.deviceName,
      sensorEnabled: sensorEnabled ?? this.sensorEnabled,
      sensitivity: sensitivity ?? this.sensitivity,
      detectionDistance: detectionDistance ?? this.detectionDistance,
      gestureSound: gestureSound ?? this.gestureSound,
      wifiName: wifiName ?? this.wifiName,
      espIp: espIp ?? this.espIp,
      wifiConnected: wifiConnected ?? this.wifiConnected,
      bluetoothReady: bluetoothReady ?? this.bluetoothReady,
    );
  }

  String get sensitivityLabel {
    switch (sensitivity) {
      case 1:
        return 'Rendah';
      case 2:
        return 'Sedang';
      case 3:
        return 'Tinggi';
      default:
        return 'Sedang';
    }
  }
}
