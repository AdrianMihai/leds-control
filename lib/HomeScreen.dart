import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:led_strip_control/contexts/DiscoveredLEDsStrips.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<String> discoveredLEDsStrips = [];

  void handlePortInputValueUpdate(
      DiscoveredLEDsStrips ledsStripContext, String? portValue) {
    ledsStripContext.updatePortValue(portValue!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<DiscoveredLEDsStrips>(
      builder: (context, ledsStripsContext, child) => Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                        errorText: (ledsStripsContext.port.isNotEmpty &&
                                !ledsStripsContext.isPortValid)
                            ? 'Invalid port data (use numbers between 1 and 65353)'
                            : null,
                        border: const OutlineInputBorder(),
                        hintText: 'Enter the port of the LEDS server'),
                    onChanged: (String? value) {
                      handlePortInputValueUpdate(ledsStripsContext, value);
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed: ledsStripsContext.discoverDevices,
                    child: const Text('Look for devices'))
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
              child: LinearProgressIndicator(
                value: ledsStripsContext.searchProgress,
              ),
            ),
            Expanded(
                child: ListView.builder(
              shrinkWrap: true,
              itemCount: ledsStripsContext.discoveredLEDS.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(ledsStripsContext.discoveredLEDS[index]),
                );
              },
            ))
          ],
        ),
      )),
    ));
  }
}
