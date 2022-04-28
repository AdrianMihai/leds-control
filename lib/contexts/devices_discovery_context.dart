import 'dart:collection';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:led_strip_control/api/LEDSApi.dart';
import 'package:led_strip_control/models/discovered_device.dart';
import 'package:network_info_plus/network_info_plus.dart';

class DevicesDiscoveryContext extends ChangeNotifier {
  String port = '';
  bool isPortValid = false;
  double searchProgress = 0.0;
  final List<DiscoveredDevice> _discoveredLEDsStrips = [];

  UnmodifiableListView<DiscoveredDevice> get discoveredLEDS =>
      UnmodifiableListView(_discoveredLEDsStrips);

  void resetDevicesList() {
    _discoveredLEDsStrips.clear();
    notifyListeners();
  }

  void updateSearchProgress(double newValue) {
    searchProgress = newValue;
    notifyListeners();
  }

  Future<Stream<HostModel>> startDevicesSearch() async {
    String wifiIP = (await (NetworkInfo().getWifiIP())) as String;
    final subnet = ipToSubnet(wifiIP);

    updateSearchProgress(0.001);
    return LanScanner().icmpScan(subnet, scanSpeeed: 30,
        progressCallback: (progress) {
      final searchProgress = double.parse(progress);

      if (searchProgress > 0) {
        updateSearchProgress(searchProgress);
      }
    });
  }

  void discoverDevices() async {
    resetDevicesList();
    final stream = await startDevicesSearch();

    stream.listen((HostModel device) async {
      try {
        var configuration =
            jsonDecode(await LEDSApi.getLEDConfiguration(device.ip, port))
                as Map<String, dynamic>;

        _discoveredLEDsStrips.add(DiscoveredDevice.ledStrip(
            device.ip, int.tryParse(port)!, configuration));
      } catch (error) {
        debugPrint(error.toString());
        _discoveredLEDsStrips.add(DiscoveredDevice(device.ip));
      }
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
