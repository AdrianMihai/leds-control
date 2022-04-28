import 'package:flutter/material.dart';
import 'package:led_strip_control/storage/leds_devices_storage.dart';
import 'package:provider/provider.dart';
import 'package:led_strip_control/contexts/devices_discovery_context.dart';

class DevicesSearchScreen extends StatelessWidget {
  const DevicesSearchScreen({Key? key}) : super(key: key);

  bool isSearchButtonDisabled(DevicesDiscoveryContext devicesDiscoveryContext) {
    return (devicesDiscoveryContext.searchProgress > 0.0 &&
            devicesDiscoveryContext.searchProgress < 1.0) ||
        !devicesDiscoveryContext.isPortValid;
  }

  void onSearchButtonClick(DevicesDiscoveryContext devicesDiscoveryContext) {
    if (isSearchButtonDisabled(devicesDiscoveryContext)) {
      return;
    }

    devicesDiscoveryContext.discoverDevices();
  }

  void handlePortInputValueUpdate(
      DevicesDiscoveryContext devicesDiscoveryContext, String? portValue) {
    devicesDiscoveryContext.updatePortValue(portValue!);
  }

  @override
  Widget build(BuildContext context) {
    Color getSearchButtonColor(Set<MaterialState> states) {
      if (isSearchButtonDisabled(
          Provider.of<DevicesDiscoveryContext>(context))) {
        return const Color(0x00a5a3a8);
      }

      return Colors.blue;
    }

    return Scaffold(
        body: Consumer<DevicesDiscoveryContext>(
      builder: (context, ledsStripsContext, child) => Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
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
              ],
            ),
            ElevatedButton(
              onPressed: () => onSearchButtonClick(ledsStripsContext),
              child: const Text('Look for devices'),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.resolveWith(getSearchButtonColor)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              child: LinearProgressIndicator(
                value: ledsStripsContext.searchProgress,
              ),
            ),
            Expanded(
                child: ListView.builder(
              shrinkWrap: true,
              itemCount: ledsStripsContext.discoveredLEDS.length,
              itemBuilder: (context, index) {
                var item = ledsStripsContext.discoveredLEDS[index];
                var addButton = IconButton(
                    onPressed: () async {
                      saveNewDevice(item);
                    },
                    icon: const Icon(Icons.add_box_outlined));

                var listTile = ListTile(
                  selected: false,
                  title: Text(item.deviceIp),
                  trailing: item.isLEDStrip ? addButton : null,
                );

                if (!item.isLEDStrip) {
                  return listTile;
                }

                return Tooltip(
                  message: 'This device returned an LED configuration',
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: const Duration(seconds: 5),
                  child: ColoredBox(
                    color: Colors.green[400]!,
                    child: listTile,
                  ),
                );
              },
            ))
          ],
        ),
      )),
    ));
  }
}
