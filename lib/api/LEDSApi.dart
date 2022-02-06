import 'package:http/http.dart' as http;

class LEDSApi {
  static Future<String> getLEDConfiguration(String ledsIP, String port) async {
    Uri url = Uri.parse('http://$ledsIP:$port/leds-api-configuration');
    http.Response response;

    try {
      response = await http.get(url,
        headers: {'Content-Type': 'application/json'});

      if (response.statusCode != 200) {
        throw Exception('Failed to retrieve leds configuration.');
      }
    } catch (e) {
      return Future.error('Failed to retrieve leds configuration.');
    }
    
    return response.body;
  }
}
