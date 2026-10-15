import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service to communicate with ESP32 Future Speaker via Wi-Fi HTTP API.
/// Fully compatible with Web, Android, iOS, Windows, macOS, and Linux.
class EspService {
  final http.Client _client = http.Client();

  /// Fetch status from ESP32
  Future<Map<String, dynamic>?> getStatus(String ip) async {
    return _sendRequest(ip, '/api/status');
  }

  /// Toggle Play / Pause
  Future<Map<String, dynamic>?> togglePlay(String ip) async {
    return _sendRequest(ip, '/api/toggle');
  }

  /// Play
  Future<Map<String, dynamic>?> play(String ip) async {
    return _sendRequest(ip, '/api/play');
  }

  /// Pause
  Future<Map<String, dynamic>?> pause(String ip) async {
    return _sendRequest(ip, '/api/pause');
  }

  /// Next song
  Future<Map<String, dynamic>?> next(String ip) async {
    return _sendRequest(ip, '/api/next');
  }

  /// Previous song
  Future<Map<String, dynamic>?> prev(String ip) async {
    return _sendRequest(ip, '/api/prev');
  }

  /// Select specific song by index
  Future<Map<String, dynamic>?> selectSong(String ip, int index) async {
    return _sendRequest(ip, '/api/select?id=$index');
  }

  /// Restart playback / system
  Future<Map<String, dynamic>?> restart(String ip) async {
    return _sendRequest(ip, '/api/restart');
  }

  /// Helper to send GET request and decode JSON response
  Future<Map<String, dynamic>?> _sendRequest(String ip, String path) async {
    final cleanIp = ip.trim().replaceAll('http://', '').replaceAll('/', '');
    final uri = Uri.parse('http://$cleanIp$path');

    try {
      final response = await _client.get(uri).timeout(
            const Duration(milliseconds: 2500),
          );

      if (response.statusCode == 200) {
        final body = response.body;
        if (body.isNotEmpty) {
          final decoded = jsonDecode(body);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
        }
      }
      return null;
    } catch (e) {
      // Offline, network timeout, or socket exception
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}
