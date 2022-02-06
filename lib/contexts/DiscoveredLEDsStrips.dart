import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';

class DiscoveredLEDsStrips extends ChangeNotifier {
  String port = '';
  bool isPortValid = false;
  double searchProgress = 0.0;
  List<String> _discoveredLEDsStrips = [];

  UnmodifiableListView<String> get discoveredLEDS =>
      UnmodifiableListView(_discoveredLEDsStrips);

  void discoverDevices() async {
    String wifiIP = (await (NetworkInfo().getWifiIP())) as String;
    final subnet = ipToSubnet(wifiIP);

    final stream = LanScanner().icmpScan(subnet, scanSpeeed: 30,
        progressCallback: (progress) {
      searchProgress = double.parse(progress);
      notifyListeners();
    });

    stream.listen((HostModel device) {
      _discoveredLEDsStrips.add(device.ip);
    });
  }

  void validatePortValue() {
    var valueNumber = int.tryParse(port, radix: 10);

    if (valueNumber == null || valueNumber < 1 || valueNumber > 65535) {
      isPortValid = false;
      return;
    }

    isPortValid = true;
  }

  void updatePortValue(String portValue) {
    port = portValue;
    validatePortValue();
    notifyListeners();
  }
}
