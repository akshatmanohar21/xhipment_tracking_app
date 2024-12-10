import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class TrackingService {
  static const String apiUrl = "https://test-api.xhipment.com/api/v1/utils/publictracking";

  Future<List<dynamic>> getTrackingData(String trackingNumber) async {
    try {
      log('Fetching tracking data for: $trackingNumber');
      final response = await http.get(
        Uri.parse("$apiUrl?track=$trackingNumber"),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      log('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Response data: $data');
        return data['result']['milestones'] ?? [];
      } else {
        log('API Error: ${response.body}');
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      log('Exception in getTrackingData', error: e);
      rethrow;
    }
  }
}
