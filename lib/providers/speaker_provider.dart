import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/esp_service.dart';

/// Manages all speaker state – playlist, playback, sensor, Wi-Fi connection, settings.
class SpeakerProvider extends ChangeNotifier {
  final EspService _espService = EspService();

  // ─── Connection State (Clear & Unambiguous) ───────
  ConnectionState _connectionState = ConnectionState.disconnected;
  ConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == ConnectionState.connected;
  bool get isConnecting => _connectionState == ConnectionState.connecting;
  bool get isDisconnected => _connectionState == ConnectionState.disconnected;

  bool _isRealEspConnected = false;
  bool get isRealEspConnected => _isRealEspConnected;

  int _missedPolls = 0;

  // ─── Settings ────────────────────────────────────
  DeviceSettings _settings = DeviceSettings();
  DeviceSettings get settings => _settings;

  // ─── Playlist (Familiar Songs matching ESP32) ─────
  final List<Song> _playlist = const [
    Song(
      id: 0,
      title: 'Super Mario',
      artist: 'Koji Kondo',
      notes: [],
      duration: Duration(seconds: 18),
    ),
    Song(
      id: 1,
      title: 'Minecraft',
      artist: 'C418 (Wet Hands)',
      notes: [],
      duration: Duration(seconds: 24),
    ),
    Song(
      id: 2,
      title: 'Tetris',
      artist: 'Korobeiniki',
      notes: [],
      duration: Duration(seconds: 19),
    ),
    Song(
      id: 3,
      title: 'Star Wars',
      artist: 'Imperial March',
      notes: [],
      duration: Duration(seconds: 16),
    ),
    Song(
      id: 4,
      title: 'Pac-Man',
      artist: 'Arcade Theme',
      notes: [],
      duration: Duration(seconds: 14),
    ),
    Song(
      id: 5,
      title: 'Pirates',
      artist: "He's a Pirate",
      notes: [],
      duration: Duration(seconds: 18),
    ),
    Song(
      id: 6,
      title: 'Harry Potter',
      artist: "Hedwig's Theme",
      notes: [],
      duration: Duration(seconds: 19),
    ),
    Song(
      id: 7,
      title: 'Pokemon',
      artist: 'Gotta Catch Em All',
      notes: [],
      duration: Duration(seconds: 18),
    ),
  ];
  List<Song> get playlist => _playlist;

  // ─── Playback ────────────────────────────────────
  int _currentSongIndex = 0;
  int get currentSongIndex => _currentSongIndex;
  Song get currentSong => _playlist[_currentSongIndex];

  bool _isPlaying = true;
  bool get isPlaying => _isPlaying;

  Duration _currentPosition = Duration.zero;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => currentSong.duration;

  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0;
    return (_currentPosition.inMilliseconds / totalDuration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  String get currentTimeStr => _formatDuration(_currentPosition);
  String get totalTimeStr => _formatDuration(totalDuration);

  // ─── Sensor ──────────────────────────────────────
  SensorReading _sensorReading = SensorReading(
    distanceCm: 999,
    objectDetected: false,
    timestamp: DateTime.now(),
  );
  SensorReading get sensorReading => _sensorReading;

  // ─── Timers & Internal ───────────────────────────
  Timer? _playbackTimer;
  Timer? _syncTimer;

  SpeakerProvider() {
    _startPlaybackTimer();
    _startSyncTimer();
    // Probe immediately at launch
    probeEsp();
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _syncTimer?.cancel();
    _espService.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════
  // Playback Controls (Optimized for Fast Latency)
  // ═══════════════════════════════════════════════════

  Future<void> togglePlay() async {
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _startPlaybackTimer();
    } else {
      _playbackTimer?.cancel();
    }
    notifyListeners();

    if (_isRealEspConnected) {
      final res = await _espService.togglePlay(_settings.espIp);
      if (res != null) _applyEspStatus(res);
    }
  }

  Future<void> nextSong() async {
    _currentSongIndex = (_currentSongIndex + 1) % _playlist.length;
    _currentPosition = Duration.zero;
    if (_isPlaying) {
      _startPlaybackTimer();
    }
    notifyListeners();

    if (_isRealEspConnected) {
      final res = await _espService.next(_settings.espIp);
      if (res != null) _applyEspStatus(res);
    }
  }

  Future<void> previousSong() async {
    _currentSongIndex =
        (_currentSongIndex - 1 + _playlist.length) % _playlist.length;
    _currentPosition = Duration.zero;
    if (_isPlaying) {
      _startPlaybackTimer();
    }
    notifyListeners();

    if (_isRealEspConnected) {
      final res = await _espService.prev(_settings.espIp);
      if (res != null) _applyEspStatus(res);
    }
  }

  Future<void> selectSong(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentSongIndex = index;
      _currentPosition = Duration.zero;
      _isPlaying = true;
      _startPlaybackTimer();
      notifyListeners();

      if (_isRealEspConnected) {
        final res = await _espService.selectSong(_settings.espIp, index);
        if (res != null) _applyEspStatus(res);
      }
    }
  }

  void seekTo(double fraction) {
    _currentPosition = Duration(
      milliseconds: (totalDuration.inMilliseconds * fraction).round(),
    );
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════
  // Wi-Fi Connection (Real & Clear Status)
  // ═══════════════════════════════════════════════════

  /// Probe ESP32 Wi-Fi API quietly
  Future<bool> probeEsp() async {
    final status = await _espService.getStatus(_settings.espIp);
    if (status != null) {
      _missedPolls = 0;
      _isRealEspConnected = true;
      _connectionState = ConnectionState.connected;
      _applyEspStatus(status);
      notifyListeners();
      return true;
    } else {
      if (_isRealEspConnected) {
        _isRealEspConnected = false;
        _connectionState = ConnectionState.disconnected;
        notifyListeners();
      }
      return false;
    }
  }

  /// Sambung Koneksi (Connect via Wi-Fi)
  Future<bool> connect([String? newIp]) async {
    if (newIp != null && newIp.trim().isNotEmpty) {
      _settings = _settings.copyWith(espIp: newIp.trim());
    }

    _connectionState = ConnectionState.connecting;
    notifyListeners();

    final status = await _espService.getStatus(_settings.espIp);
    if (status != null) {
      _missedPolls = 0;
      _isRealEspConnected = true;
      _connectionState = ConnectionState.connected;
      _applyEspStatus(status);
      _startPlaybackTimer();
      notifyListeners();
      return true;
    } else {
      _missedPolls = 0;
      _isRealEspConnected = false;
      _connectionState = ConnectionState.disconnected;
      notifyListeners();
      return false;
    }
  }

  /// Restart Koneksi (Reset ESP playback & reconnect)
  Future<bool> restartConnection() async {
    _connectionState = ConnectionState.connecting;
    notifyListeners();

    if (_isRealEspConnected) {
      await _espService.restart(_settings.espIp);
    }

    await Future.delayed(const Duration(milliseconds: 600));
    final ok = await connect();
    return ok;
  }

  /// Putuskan Koneksi
  Future<void> disconnect() async {
    _connectionState = ConnectionState.disconnected;
    _isPlaying = false;
    _isRealEspConnected = false;
    _playbackTimer?.cancel();
    _sensorReading = SensorReading(
      distanceCm: 999,
      objectDetected: false,
      timestamp: DateTime.now(),
    );
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════
  // Settings
  // ═══════════════════════════════════════════════════

  void updateSettings(DeviceSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  void setDeviceName(String name) {
    _settings = _settings.copyWith(deviceName: name);
    notifyListeners();
  }

  void setEspIp(String ip) {
    _settings = _settings.copyWith(espIp: ip.trim());
    notifyListeners();
  }

  void setSensorEnabled(bool enabled) {
    _settings = _settings.copyWith(sensorEnabled: enabled);
    if (!enabled) {
      _sensorReading = SensorReading(
        distanceCm: 999,
        objectDetected: false,
        timestamp: DateTime.now(),
      );
    }
    notifyListeners();
  }

  void setSensitivity(int value) {
    _settings = _settings.copyWith(sensitivity: value);
    notifyListeners();
  }

  void setDetectionDistance(int value) {
    _settings = _settings.copyWith(detectionDistance: value);
    notifyListeners();
  }

  void setGestureSound(bool value) {
    _settings = _settings.copyWith(gestureSound: value);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════
  // Synchronisation & Realtime Timers
  // ═══════════════════════════════════════════════════

  void _applyEspStatus(Map<String, dynamic> status) {
    final bool espPlaying = status['playing'] == true;
    final int? espSongIndex = status['song_index'] as int?;
    final num? kiri = status['kiri'] as num?;
    final num? kanan = status['kanan'] as num?;

    if (espPlaying != _isPlaying) {
      _isPlaying = espPlaying;
    }
    if (espSongIndex != null &&
        espSongIndex >= 0 &&
        espSongIndex < _playlist.length &&
        espSongIndex != _currentSongIndex) {
      _currentSongIndex = espSongIndex;
      _currentPosition = Duration.zero;
    }

    // Ultrasonic sensor reading
    final double distKanan = kanan?.toDouble() ?? 999.0;
    final double distKiri = kiri?.toDouble() ?? 999.0;
    final double activeDist = distKanan < distKiri ? distKanan : distKiri;
    final bool detected = activeDist < _settings.detectionDistance;

    _sensorReading = SensorReading(
      distanceCm: activeDist > 200 ? 999.0 : activeDist,
      objectDetected: detected,
      timestamp: DateTime.now(),
    );

    notifyListeners();
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) async {
      if (isConnecting) return;

      final status = await _espService.getStatus(_settings.espIp);
      if (status != null) {
        _missedPolls = 0;
        if (!_isRealEspConnected || _connectionState != ConnectionState.connected) {
          _isRealEspConnected = true;
          _connectionState = ConnectionState.connected;
          _startPlaybackTimer();
        }
        _applyEspStatus(status);
      } else {
        if (_isRealEspConnected) {
          _missedPolls++;
          // After 3 failed attempts (~3 seconds), mark clearly as disconnected
          if (_missedPolls >= 3) {
            _isRealEspConnected = false;
            _connectionState = ConnectionState.disconnected;
            notifyListeners();
          }
        }
      }
    });
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPlaying) return;
      _currentPosition += const Duration(seconds: 1);
      if (_currentPosition >= totalDuration) {
        nextSong();
      }
      notifyListeners();
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
