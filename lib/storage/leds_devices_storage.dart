// ignore_for_file:  constant_identifier_names

import 'dart:convert';

import 'package:led_strip_control/models/discovered_device.dart';
import 'package:shared_preferences/shared_preferences.dart';

const SAVED_DEVICES_STORAGE_KEY = 'ledsDevices';

Future<void> deleteAllSavedDevices() async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.remove(SAVED_DEVICES_STORAGE_KEY);
}

Future<List<DiscoveredDevice>> getAllSavedDevices() async {
  final preferences = await SharedPreferences.getInstance();
  List<String> savedDevices =
      preferences.getStringList(SAVED_DEVICES_STORAGE_KEY) != null
          ? preferences.getStringList(SAVED_DEVICES_STORAGE_KEY)!
          : <String>[];

  List<DiscoveredDevice> result = [];
  savedDevices.forEach((element) {
    result.add(DiscoveredDevice.fromJson(jsonDecode(element)));
  });

  return result;
}

void saveNewDevice(DiscoveredDevice ledDevice) async {
  final devicesList = await getAllSavedDevices();
  int idx = devicesList.indexWhere(
      (element) => element.deviceHash.compareTo(ledDevice.deviceHash) == 0);

  if (idx > -1) {
    devicesList[idx] = ledDevice;
  } else {
    devicesList.add(ledDevice);
  }

  List<String> result = [];
  devicesList.forEach((element) {
    result.add(jsonEncode(element.toMap()));
  });

  final preferences = await SharedPreferences.getInstance();
  preferences.setStringList(SAVED_DEVICES_STORAGE_KEY, result);
}
