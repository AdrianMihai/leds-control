import 'dart:convert';

class DiscoveredDevice {
  String deviceIp = '';
  int ledsPort = 0;
  final Map<String, String> ledsAPIConfig = <String, String>{};

  DiscoveredDevice(String ip) {
    deviceIp = ip;
  }

  DiscoveredDevice.ledStrip(
      String ip, int port, Map<String, dynamic> apiConfig) {
    deviceIp = ip;
    ledsPort = port;

    apiConfig.forEach((key, value) {
      ledsAPIConfig[key] = value as String;
    });
  }

  factory DiscoveredDevice.fromJson(Map<String, dynamic> json) {
    DiscoveredDevice device = DiscoveredDevice.ledStrip(
        json['ip'], json['port'], jsonDecode(json['apiConfig']));
    return device;
  }

  bool get isLEDStrip => ledsAPIConfig.isNotEmpty;

  String get deviceHash => '$deviceIp:$ledsPort';

  @override
  String toString() {
    String areLEDSString = isLEDStrip ? '(is LEDs strip)' : '';
    return '$deviceIp $areLEDSString';
  }

  Map<String, dynamic> toMap() {
    return {
      'ip': deviceIp,
      'port': ledsPort,
      'apiConfig': jsonEncode(ledsAPIConfig)
    };
  }
}
