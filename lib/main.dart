// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:led_strip_control/devices_search.dart';
import 'package:led_strip_control/contexts/devices_discovery_context.dart';
import 'package:led_strip_control/storage/leds_devices_storage.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;

// ignore: constant_identifier_names
const String TASK_NAME = 'LEDS_TOGGLE';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    Uri url = Uri.parse(inputData?["serverAddress"] + "/toggle-lights");

    try {
      var response = await http.post(url,
          body: jsonEncode({'on': true}),
          headers: {'Content-Type': 'application/json'});
      print(response.body);
    } catch (err) {
      print(err.toString());
      throw Exception(err);
    }

    return Future.value(true);
  });
}

void manageLEDSTasks() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await Workmanager().cancelAll();
  // await Workmanager().registerPeriodicTask("1", TASK_NAME,
  //     inputData: {"serverAddress": "http://192.168.100.15:3000"},
  //     constraints: Constraints(
  //       networkType: NetworkType.connected,
  //     ));
}

void printSavedDevices() async {
  // await deleteAllSavedDevices();

  (await getAllSavedDevices()).forEach((element) {
    debugPrint(element.toString());
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  manageLEDSTasks();
  printSavedDevices();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => DevicesDiscoveryContext(),
      )
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {'/': (context) => DevicesSearchScreen()});
  }
}

class SwitchLEDSButton extends StatefulWidget {
  const SwitchLEDSButton({Key? key}) : super(key: key);

  @override
  State<SwitchLEDSButton> createState() => _SwitchLEDSButtonState();
}

class _SwitchLEDSButtonState extends State<SwitchLEDSButton> {
  bool areLightsOn = false;

  Future<void> notifyLEDS(bool areLEDSOn) async {
    Uri url = Uri.parse('http://192.168.100.15:3000/toggle-lights');
    var response = await http.post(url,
        body: jsonEncode({'on': areLEDSOn}),
        headers: {'Content-Type': 'application/json'});

    print(response.body);
  }

  void _toggleLights() async {
    bool newLEDSState = !areLightsOn;

    try {
      await notifyLEDS(newLEDSState);
    } catch (error) {
      print(error.toString());
    }

    setState(() {
      areLightsOn = newLEDSState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: _toggleLights,
                child: Text(areLightsOn ? 'Turn LEDs Off' : 'Turn LEDs On'))
          ],
        ),
      ),
    );
  }
}
